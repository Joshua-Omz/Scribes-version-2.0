package recommendation

import (
	"context"

	"github.com/google/uuid"
	"scribes-api/internal/db/generated"
)

type Service interface {
	GetRecommendationsByType(ctx context.Context, sortType string, limit, offset int32) ([]generated.GetRecommendationsByTypeRow, error)
	GetSemanticallySimilarPosts(ctx context.Context, postID uuid.UUID, limit int32) ([]generated.GetSemanticallySimilarPostsRow, error)
}

type service struct {
	repo Repository
}

func NewService(repo Repository) Service {
	return &service{repo: repo}
}

func (s *service) GetRecommendationsByType(ctx context.Context, sortType string, limit, offset int32) ([]generated.GetRecommendationsByTypeRow, error) {
	// Validate sortType
	validTypes := map[string]bool{
		"overall":           true,
		"amen":              true,
		"insightful":        true,
		"thought_provoking": true,
	}
	if !validTypes[sortType] {
		sortType = "overall" // default
	}

	return s.repo.GetRecommendationsByType(ctx, sortType, limit, offset)
}

func (s *service) GetSemanticallySimilarPosts(ctx context.Context, postID uuid.UUID, limit int32) ([]generated.GetSemanticallySimilarPostsRow, error) {
	return s.repo.GetSemanticallySimilarPosts(ctx, postID, limit)
}
