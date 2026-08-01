package recommendation

import (
	"context"
	"database/sql"

	"github.com/google/uuid"
	"scribes-api/internal/db/generated"
)

type Repository interface {
	GetRecommendationsByType(ctx context.Context, sortType string, limit, offset int32) ([]generated.GetRecommendationsByTypeRow, error)
	GetSemanticallySimilarPosts(ctx context.Context, postID uuid.UUID, limit int32) ([]generated.GetSemanticallySimilarPostsRow, error)
	RefreshEngagementScores(ctx context.Context) error
	TryAdvisoryLock(ctx context.Context, lockID int64) (bool, error)
	AdvisoryUnlock(ctx context.Context, lockID int64) error
}

type repository struct {
	db  *generated.Queries
	raw *sql.DB
}

func NewRepository(db *generated.Queries, raw *sql.DB) Repository {
	return &repository{db: db, raw: raw}
}

func (r *repository) GetRecommendationsByType(ctx context.Context, sortType string, limit, offset int32) ([]generated.GetRecommendationsByTypeRow, error) {
	return r.db.GetRecommendationsByType(ctx, generated.GetRecommendationsByTypeParams{
		SortType:    sortType,
		LimitCount:  limit,
		OffsetCount: offset,
	})
}

func (r *repository) GetSemanticallySimilarPosts(ctx context.Context, postID uuid.UUID, limit int32) ([]generated.GetSemanticallySimilarPostsRow, error) {
	return r.db.GetSemanticallySimilarPosts(ctx, generated.GetSemanticallySimilarPostsParams{
		PostID:     postID,
		LimitCount: limit,
	})
}

func (r *repository) RefreshEngagementScores(ctx context.Context) error {
	return r.db.RefreshEngagementScores(ctx)
}

func (r *repository) TryAdvisoryLock(ctx context.Context, lockID int64) (bool, error) {
	var acquired bool
	err := r.raw.QueryRowContext(ctx, "SELECT pg_try_advisory_lock($1)", lockID).Scan(&acquired)
	return acquired, err
}

func (r *repository) AdvisoryUnlock(ctx context.Context, lockID int64) error {
	var released bool
	err := r.raw.QueryRowContext(ctx, "SELECT pg_advisory_unlock($1)", lockID).Scan(&released)
	return err
}
