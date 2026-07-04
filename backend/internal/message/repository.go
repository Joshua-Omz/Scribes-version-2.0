package message

import (
	"context"
	"database/sql"
	"time"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

type Repository struct {
	q *generated.Queries
}

func NewRepository(q *generated.Queries, db *sql.DB) *Repository {
	return &Repository{q: q}
}

// ── Message Requests ───────────────────────────

func (r *Repository) CreateMessageRequest(ctx context.Context, fromUserID, toUserID uuid.UUID, firstMessage string) (generated.MessageRequest, error) {
	return r.q.CreateMessageRequest(ctx, generated.CreateMessageRequestParams{
		FromUserID:   fromUserID,
		ToUserID:     toUserID,
		FirstMessage: firstMessage,
	})
}

func (r *Repository) UpdateMessageRequestStatus(ctx context.Context, requestID uuid.UUID, status generated.RequestStatus) error {
	return r.q.UpdateMessageRequestStatus(ctx, generated.UpdateMessageRequestStatusParams{
		ID:     requestID,
		Status: status,
	})
}

func (r *Repository) GetPendingRequestsForUser(ctx context.Context, userID uuid.UUID) ([]generated.MessageRequest, error) {
	return r.q.GetPendingRequestsForUser(ctx, userID)
}

func (r *Repository) GetMessageRequestByID(ctx context.Context, requestID uuid.UUID) (generated.MessageRequest, error) {
	return r.q.GetMessageRequestByID(ctx, requestID)
}

// ── Conversations ──────────────────────────────

func (r *Repository) CreateConversation(ctx context.Context, userAID, userBID uuid.UUID) (generated.Conversation, error) {
	// userAID and userBID can be ordered to avoid unique constraint issues if we wanted,
	// but currently the db just has unique(user_a_id, user_b_id).
	return r.q.CreateConversation(ctx, generated.CreateConversationParams{
		UserAID: userAID,
		UserBID: userBID,
	})
}

func (r *Repository) GetConversationsForUser(ctx context.Context, userID uuid.UUID) ([]generated.Conversation, error) {
	return r.q.GetConversationsForUser(ctx, userID)
}

func (r *Repository) GetConversationByID(ctx context.Context, conversationID uuid.UUID) (generated.Conversation, error) {
	return r.q.GetConversationByID(ctx, conversationID)
}

func (r *Repository) BlockConversation(ctx context.Context, conversationID uuid.UUID) error {
	return r.q.BlockConversation(ctx, conversationID)
}

// ── Messages ───────────────────────────────────

func (r *Repository) CreateMessage(ctx context.Context, conversationID, senderID uuid.UUID, body string) (generated.Message, error) {
	return r.q.CreateMessage(ctx, generated.CreateMessageParams{
		ConversationID: conversationID,
		SenderID:       senderID,
		Body:           body,
	})
}

func (r *Repository) GetMessagesForConversation(ctx context.Context, conversationID uuid.UUID, cursorTs time.Time, limit int) ([]generated.Message, error) {
	msgs, err := r.q.GetMessagesForConversation(ctx, generated.GetMessagesForConversationParams{
		ConversationID: conversationID,
		CursorTs:       cursorTs,
		LimitCount:     int32(limit),
	})
	if err != nil {
		return nil, err
	}

	// Architectural requirement: Soft-delete mask
	for i := range msgs {
		if msgs[i].IsDeleted {
			msgs[i].Body = "[Message deleted]"
		}
	}
	return msgs, nil
}

func (r *Repository) SoftDeleteMessage(ctx context.Context, messageID, senderID uuid.UUID) error {
	return r.q.SoftDeleteMessage(ctx, generated.SoftDeleteMessageParams{
		ID:       messageID,
		SenderID: senderID,
	})
}
