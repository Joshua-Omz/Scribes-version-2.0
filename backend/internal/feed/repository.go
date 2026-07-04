package feed

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

func (r *Repository) GetFollowingFeed(ctx context.Context, followerID uuid.UUID, cursorTs time.Time, cursorID uuid.UUID, limit int32) ([]generated.Post, error) {
	return r.q.GetFollowingFeed(ctx, generated.GetFollowingFeedParams{
		FollowerID: followerID,
		CursorTs:   cursorTs,
		CursorID:   cursorID,
		LimitCount: int32(limit),
	})
}

func (r *Repository) GetExploreFeed(ctx context.Context, categoryIDs []uuid.UUID, limit int32) ([]generated.GetExploreFeedRow, error) {
	return r.q.GetExploreFeed(ctx, generated.GetExploreFeedParams{
		CategoryIds: categoryIDs,
		LimitCount:  int32(limit),
	})
}

func (r *Repository) GetUserOnboardingCategories(ctx context.Context, userID uuid.UUID) ([]uuid.UUID, error) {
	return r.q.GetUserOnboardingCategories(ctx, userID)
}
