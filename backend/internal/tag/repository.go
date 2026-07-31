package tag

import (
	"context"

	"scribes-api/internal/db/generated"
)

type Repository interface {
	SuggestTags(ctx context.Context, query string, limit int32) ([]generated.Tag, error)
	GetTrendingTags(ctx context.Context, limit int32) ([]generated.Tag, error)
}

type repository struct {
	db *generated.Queries
}

func NewRepository(db *generated.Queries) Repository {
	return &repository{db: db}
}

func (r *repository) SuggestTags(ctx context.Context, query string, limit int32) ([]generated.Tag, error) {
	return r.db.SuggestTags(ctx, generated.SuggestTagsParams{
		Name:  query,
		Limit: limit,
	})
}

func (r *repository) GetTrendingTags(ctx context.Context, limit int32) ([]generated.Tag, error) {
	return r.db.GetTrendingTags(ctx, limit)
}
