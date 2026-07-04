package notification

import (
	"context"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) GetUnreadNotifications(ctx context.Context, userID uuid.UUID) ([]generated.Notification, error) {
	return s.repo.GetUnreadNotificationsForUser(ctx, userID)
}

func (s *Service) MarkAsRead(ctx context.Context, id, userID uuid.UUID) error {
	return s.repo.MarkNotificationAsRead(ctx, id, userID)
}

// In a real system, other services (like comments, likes, mentions) would call this 
// internally to trigger a notification payload, rather than exposing an HTTP endpoint for it.
func (s *Service) CreateNotification(ctx context.Context, recipientID uuid.UUID, ntype generated.NotifType, refID uuid.UUID, isRealtime bool) (generated.Notification, error) {
	return s.repo.CreateNotification(ctx, recipientID, ntype, refID, isRealtime)
}
