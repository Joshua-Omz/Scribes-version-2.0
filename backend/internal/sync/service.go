package sync

import (
	"context"

	"github.com/google/uuid"
)

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) Pull(ctx context.Context, authorID uuid.UUID, lastSeq int64) ([]SyncEvent, error) {
	return s.repo.PullSyncEvents(ctx, authorID, lastSeq)
}
