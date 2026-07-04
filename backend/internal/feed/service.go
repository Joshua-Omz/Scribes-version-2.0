package feed

import (
	"context"
	"time"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{
		repo: repo,
	}
}

func (s *Service) GetFollowingFeed(ctx context.Context, userID uuid.UUID, cursorTs time.Time, cursorID uuid.UUID, limit int) ([]generated.Post, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	return s.repo.GetFollowingFeed(ctx, userID, cursorTs, cursorID, int32(limit))
}

func (s *Service) GetExploreFeed(ctx context.Context, userID uuid.UUID, requestedCategories []uuid.UUID, limit int) ([]generated.GetExploreFeedRow, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}

	categoriesToQuery := requestedCategories

	// Cold-boot logic: if no categories were provided by the client,
	// fetch the user's onboarding categories to power the feed.
	if len(categoriesToQuery) == 0 {
		onboardingCategories, err := s.repo.GetUserOnboardingCategories(ctx, userID)
		if err == nil && len(onboardingCategories) > 0 {
			categoriesToQuery = onboardingCategories
		}
	}

	return s.repo.GetExploreFeed(ctx, categoriesToQuery, int32(limit))
}
