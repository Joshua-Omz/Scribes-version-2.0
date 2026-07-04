package message

import (
	"context"
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
	msg, err := s.repo.CreateMessage(ctx, conv.ID, req.FromUserID, req.FirstMessage)
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

func (s *Service) SendMessage(ctx context.Context, conversationID, senderID uuid.UUID, body string) (generated.Message, error) {
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

	msg, err := s.repo.CreateMessage(ctx, conversationID, senderID, body)
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
