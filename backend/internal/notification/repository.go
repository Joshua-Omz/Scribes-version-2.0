package notification

import (
	"context"
	"database/sql"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

type Repository struct {
	q *generated.Queries
}

func NewRepository(q *generated.Queries, db *sql.DB) *Repository {
	return &Repository{q: q}
}

func (r *Repository) CreateNotification(ctx context.Context, recipientID uuid.UUID, ntype generated.NotifType, refID uuid.UUID, isRealtime bool) (generated.Notification, error) {
	return r.q.CreateNotification(ctx, generated.CreateNotificationParams{
		RecipientID: recipientID,
		Type:        ntype,
		RefID:       refID,
		IsRealtime:  isRealtime,
	})
}

func (r *Repository) GetUnreadNotificationsForUser(ctx context.Context, userID uuid.UUID) ([]generated.Notification, error) {
	return r.q.GetUnreadNotificationsForUser(ctx, userID)
}

func (r *Repository) MarkNotificationAsRead(ctx context.Context, id, userID uuid.UUID) error {
	return r.q.MarkNotificationAsRead(ctx, generated.MarkNotificationAsReadParams{
		ID:          id,
		RecipientID: userID,
	})
}

func (r *Repository) GetUnsentBatchedNotifications(ctx context.Context) ([]generated.Notification, error) {
	return r.q.GetUnsentBatchedNotifications(ctx)
}

func (r *Repository) MarkNotificationsAsSent(ctx context.Context, ids []uuid.UUID) error {
	return r.q.MarkNotificationsAsSent(ctx, ids)
}
