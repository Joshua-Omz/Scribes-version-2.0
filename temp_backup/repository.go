package feed

import (
	"context"
	"time"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

type Repository struct {
	q *generated.Queries
}

func NewRepository(q *generated.Queries) *Repository {
	return &Repository{
		q: q,
	}
}

func (r *Repository) GetFeedPosts(ctx context.Context, cursorTime time.Time, cursorID uuid.UUID, limit int32) ([]generated.GetFeedPostsRow, error) {
	return r.q.GetFeedPosts(ctx, generated.GetFeedPostsParams{
		PublishedAt: cursorTime,
		ID:          cursorID,
		Limit:       limit,
	})
}

func (r *Repository) GetExplorePosts(ctx context.Context, cursorTime time.Time, cursorID uuid.UUID, limit int32) ([]generated.GetExplorePostsRow, error) {
	return r.q.GetExplorePosts(ctx, generated.GetExplorePostsParams{
		PublishedAt: cursorTime,
		ID:          cursorID,
		Limit:       limit,
	})
}

func (r *Repository) GetExplorePostsByCategory(ctx context.Context, categoryID uuid.UUID, cursorTime time.Time, cursorID uuid.UUID, limit int32) ([]generated.GetExplorePostsByCategoryRow, error) {
	return r.q.GetExplorePostsByCategory(ctx, generated.GetExplorePostsByCategoryParams{
		CategoryID:  categoryID,
		PublishedAt: cursorTime,
		ID:          cursorID,
		Limit:       limit,
	})
}

func (r *Repository) ListCategories(ctx context.Context) ([]generated.Category, error) {
	return r.q.ListCategories(ctx)
}
