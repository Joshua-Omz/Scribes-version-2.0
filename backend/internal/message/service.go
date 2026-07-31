package message

import (
	"context"
	"database/sql"
	"errors"
	"sync"
	"time"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

type Service struct {
	repo       *Repository
	clients    map[uuid.UUID]map[chan *generated.Message]bool
	clientsMux sync.RWMutex
}

func NewService(repo *Repository) *Service {
	return &Service{
		repo:    repo,
		clients: make(map[uuid.UUID]map[chan *generated.Message]bool),
	}
}

// ── Real-time Pub/Sub (SSE) ────────────────────

func (s *Service) Subscribe(conversationID uuid.UUID) chan *generated.Message {
	s.clientsMux.Lock()
	defer s.clientsMux.Unlock()
	
	ch := make(chan *generated.Message, 20)
	if s.clients[conversationID] == nil {
		s.clients[conversationID] = make(map[chan *generated.Message]bool)
	}
	s.clients[conversationID][ch] = true
	return ch
}

func (s *Service) Unsubscribe(conversationID uuid.UUID, ch chan *generated.Message) {
	s.clientsMux.Lock()
	defer s.clientsMux.Unlock()
	
	if subs, ok := s.clients[conversationID]; ok {
		delete(subs, ch)
		close(ch)
		if len(subs) == 0 {
			delete(s.clients, conversationID)
		}
	}
}

func (s *Service) broadcast(msg *generated.Message) {
	s.clientsMux.RLock()
	defer s.clientsMux.RUnlock()
	
	if subs, ok := s.clients[msg.ConversationID]; ok {
		for ch := range subs {
			select {
			case ch <- msg:
			default:
				// If client cannot keep up, drop the message. 
				// They can fetch missed messages via REST.
			}
		}
	}
}

// ── Message Requests ───────────────────────────

func (s *Service) SendRequest(ctx context.Context, fromUserID, toUserID uuid.UUID, firstMessage string) (generated.MessageRequest, error) {
	// In a complete implementation, we'd check if they are already mutual followers.
	// If they are mutuals, we might directly create a conversation.
	// For this sprint, we assume this is the path for non-mutuals.
	return s.repo.CreateMessageRequest(ctx, fromUserID, toUserID, firstMessage)
}

func (s *Service) GetPendingRequests(ctx context.Context, userID uuid.UUID) ([]generated.MessageRequest, error) {
	return s.repo.GetPendingRequestsForUser(ctx, userID)
}

func (s *Service) ApproveRequest(ctx context.Context, requestID, userID uuid.UUID) (generated.Conversation, error) {
	req, err := s.repo.GetMessageRequestByID(ctx, requestID)
	if err != nil {
		return generated.Conversation{}, err
	}

	if req.ToUserID != userID {
		return generated.Conversation{}, errors.New("unauthorized to approve this request")
	}

	if req.Status != generated.RequestStatusPending {
		return generated.Conversation{}, errors.New("request already resolved")
	}

	err = s.repo.UpdateMessageRequestStatus(ctx, requestID, generated.RequestStatusApproved)
	if err != nil {
		return generated.Conversation{}, err
	}

	// Create the conversation now that it is approved.
	// Sort IDs so user_a_id is always the smaller UUID to prevent duplicates.
	// For simplicity, we just use from/to. In production, sorting prevents (A,B) and (B,A).
	userA := req.FromUserID
	userB := req.ToUserID
	if userA.String() > userB.String() {
		userA, userB = userB, userA
	}

	conv, err := s.repo.CreateConversation(ctx, userA, userB)
	if err != nil {
		return generated.Conversation{}, err
	}

	// Create the first message that was in the request
	msg, err := s.repo.CreateMessage(ctx, generated.CreateMessageParams{
		ConversationID: conv.ID,
		SenderID:       req.FromUserID,
		Body:           req.FirstMessage,
	})
	if err == nil {
		s.broadcast(&msg)
	}

	return conv, nil
}

func (s *Service) RejectRequest(ctx context.Context, requestID, userID uuid.UUID) error {
	req, err := s.repo.GetMessageRequestByID(ctx, requestID)
	if err != nil {
		return err
	}

	if req.ToUserID != userID {
		return errors.New("unauthorized to reject this request")
	}

	return s.repo.UpdateMessageRequestStatus(ctx, requestID, generated.RequestStatusRejected)
}

// ── Conversations ──────────────────────────────

func (s *Service) GetConversations(ctx context.Context, userID uuid.UUID) ([]generated.Conversation, error) {
	return s.repo.GetConversationsForUser(ctx, userID)
}

func (s *Service) SearchContacts(ctx context.Context, userID uuid.UUID, query string) ([]generated.SearchContactsRow, error) {
	return s.repo.SearchContacts(ctx, generated.SearchContactsParams{
		UserAID: userID,
		Column2: sql.NullString{String: query, Valid: query != ""},
	})
}

func (s *Service) GetOrCreateDirectConversation(ctx context.Context, userA, userB uuid.UUID) (generated.Conversation, error) {
	// First check if a conversation already exists
	conv, err := s.repo.GetConversationByUsers(ctx, generated.GetConversationByUsersParams{
		UserAID: userA,
		UserBID: userB,
	})
	if err == nil {
		return conv, nil
	}

	// Check if they are mutual followers
	f1, err1 := s.repo.CheckIsFollowing(ctx, userA, userB)
	f2, err2 := s.repo.CheckIsFollowing(ctx, userB, userA)
	if err1 != nil || err2 != nil || !f1 || !f2 {
		return generated.Conversation{}, errors.New("cannot direct message non-mutual follower")
	}

	// Ensure A < B to prevent duplicates
	if userA.String() > userB.String() {
		userA, userB = userB, userA
	}

	return s.repo.CreateConversation(ctx, userA, userB)
}

func (s *Service) BlockConversation(ctx context.Context, conversationID, userID uuid.UUID) error {
	// Verify user is in conversation
	conv, err := s.repo.GetConversationByID(ctx, conversationID)
	if err != nil {
		return err
	}
	if conv.UserAID != userID && conv.UserBID != userID {
		return errors.New("unauthorized")
	}
	return s.repo.BlockConversation(ctx, conversationID)
}

// ── Messages ───────────────────────────────────

func (s *Service) SendMessage(ctx context.Context, conversationID, senderID uuid.UUID, body string, replyToID *uuid.UUID) (generated.Message, error) {
	conv, err := s.repo.GetConversationByID(ctx, conversationID)
	if err != nil {
		return generated.Message{}, err
	}

	if conv.Blocked {
		return generated.Message{}, errors.New("conversation is blocked")
	}

	if conv.UserAID != senderID && conv.UserBID != senderID {
		return generated.Message{}, errors.New("unauthorized to send in this conversation")
	}

	var replyTo uuid.NullUUID
	if replyToID != nil {
		replyTo = uuid.NullUUID{UUID: *replyToID, Valid: true}
	}

	msg, err := s.repo.CreateMessage(ctx, generated.CreateMessageParams{
		ConversationID: conversationID,
		SenderID:       senderID,
		Body:           body,
		ReplyToID:      replyTo,
	})
	if err != nil {
		return generated.Message{}, err
	}

	// Broadcast to active SSE streams
	s.broadcast(&msg)

	return msg, nil
}

func (s *Service) GetMessages(ctx context.Context, conversationID, userID uuid.UUID, cursorTs time.Time, limit int) ([]generated.Message, error) {
	conv, err := s.repo.GetConversationByID(ctx, conversationID)
	if err != nil {
		return nil, err
	}
	if conv.UserAID != userID && conv.UserBID != userID {
		return nil, errors.New("unauthorized")
	}

	if limit <= 0 || limit > 100 {
		limit = 50
	}

	return s.repo.GetMessagesForConversation(ctx, conversationID, cursorTs, limit)
}

func (s *Service) SoftDeleteMessage(ctx context.Context, messageID, senderID uuid.UUID) error {
	return s.repo.SoftDeleteMessage(ctx, messageID, senderID)
}

func (s *Service) UpdateMessage(ctx context.Context, messageID, senderID uuid.UUID, body string) (generated.Message, error) {
	msg, err := s.repo.UpdateMessage(ctx, generated.UpdateMessageParams{
		ID:       messageID,
		SenderID: senderID,
		Body:     body,
	})
	if err != nil {
		return generated.Message{}, err
	}
	
	s.broadcast(&msg)
	
	return msg, nil
}
