package notification

import (
	"context"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

type Repository struct {
	q *generated.Queries
}

func NewRepository(q *generated.Queries) *Repository {
	return &Repository{q: q}
}

func (r *Repository) Insert(ctx context.Context, event Event) (generated.Notification, error) {
	return r.q.InsertNotification(ctx, generated.InsertNotificationParams{
		RecipientID: event.RecipientID,
		Type:        event.Type.ToDB(),
		RefID:       event.RefID,
		ActorID:     uuid.NullUUID{UUID: event.ActorID, Valid: event.ActorID != uuid.Nil},
		IsRealtime:  event.IsRealtime,
	})
}

func (r *Repository) ListAllByUser(ctx context.Context, userID uuid.UUID) ([]generated.ListAllByUserRow, error) {
	return r.q.ListAllByUser(ctx, userID)
}

func (r *Repository) ListUnreadByUser(ctx context.Context, userID uuid.UUID) ([]generated.ListUnreadByUserRow, error) {
	return r.q.ListUnreadByUser(ctx, userID)
}

func (r *Repository) MarkAllRead(ctx context.Context, userID uuid.UUID) error {
	return r.q.MarkAllReadByUser(ctx, userID)
}

func (r *Repository) FlushBatch(ctx context.Context) error {
	return r.q.FlushPendingBatch(ctx)
}

func (r *Repository) HasUnread(ctx context.Context, userID uuid.UUID) (bool, error) {
	return r.q.HasUnread(ctx, userID)
}
