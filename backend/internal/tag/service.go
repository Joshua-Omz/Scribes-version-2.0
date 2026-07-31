package tag

import (
	"context"

	"scribes-api/internal/db/generated"
)

type Service interface {
	SuggestTags(ctx context.Context, query string, limit int32) ([]generated.Tag, error)
	GetTrendingTags(ctx context.Context, limit int32) ([]generated.Tag, error)
}

type service struct {
	repo Repository
}

func NewService(repo Repository) Service {
	return &service{repo: repo}
}

func (s *service) SuggestTags(ctx context.Context, query string, limit int32) ([]generated.Tag, error) {
	if limit <= 0 || limit > 50 {
		limit = 10
	}
	return s.repo.SuggestTags(ctx, query, limit)
}

func (s *service) GetTrendingTags(ctx context.Context, limit int32) ([]generated.Tag, error) {
	if limit <= 0 || limit > 50 {
		limit = 20
	}
	return s.repo.GetTrendingTags(ctx, limit)
}
