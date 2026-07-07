package feed

import (
	"context"
	"encoding/json"
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

type FeedPost struct {
	ID             uuid.UUID                `json:"id"`
	AuthorID       uuid.UUID                `json:"author_id"`
	Content        json.RawMessage          `json:"content"`
	Caption        *string                  `json:"caption"`
	Visibility     generated.PostVisibility `json:"visibility"`
	CurrentVersion int32                    `json:"current_version"`
	IsCorrection   bool                     `json:"is_correction"`
	CorrectsPostID *uuid.UUID               `json:"corrects_post_id"`
	SermonSource   *string                  `json:"sermon_source"`
	IsDeleted      bool                     `json:"is_deleted"`
	PublishedAt    time.Time                `json:"published_at"`
	AuthorHandle   string                   `json:"author_handle"`
	AuthorName     string                   `json:"author_name"`
}

func mapFeedPost(row generated.GetFeedPostsRow) FeedPost {
	var caption *string
	if row.Caption.Valid {
		caption = &row.Caption.String
	}
	var correctsPostID *uuid.UUID
	if row.CorrectsPostID.Valid {
		correctsPostID = &row.CorrectsPostID.UUID
	}
	var sermonSource *string
	if row.SermonSource.Valid {
		sermonSource = &row.SermonSource.String
	}

	return FeedPost{
		ID:             row.ID,
		AuthorID:       row.AuthorID,
		Content:        row.Content,
		Caption:        caption,
		Visibility:     row.Visibility,
		CurrentVersion: row.CurrentVersion,
		IsCorrection:   row.IsCorrection,
		CorrectsPostID: correctsPostID,
		SermonSource:   sermonSource,
		IsDeleted:      row.IsDeleted,
		PublishedAt:    row.PublishedAt,
		AuthorHandle:   row.AuthorHandle,
		AuthorName:     row.AuthorName,
	}
}

func mapExplorePost(row generated.GetExplorePostsRow) FeedPost {
	var caption *string
	if row.Caption.Valid {
		caption = &row.Caption.String
	}
	var correctsPostID *uuid.UUID
	if row.CorrectsPostID.Valid {
		correctsPostID = &row.CorrectsPostID.UUID
	}
	var sermonSource *string
	if row.SermonSource.Valid {
		sermonSource = &row.SermonSource.String
	}

	return FeedPost{
		ID:             row.ID,
		AuthorID:       row.AuthorID,
		Content:        row.Content,
		Caption:        caption,
		Visibility:     row.Visibility,
		CurrentVersion: row.CurrentVersion,
		IsCorrection:   row.IsCorrection,
		CorrectsPostID: correctsPostID,
		SermonSource:   sermonSource,
		IsDeleted:      row.IsDeleted,
		PublishedAt:    row.PublishedAt,
		AuthorHandle:   row.AuthorHandle,
		AuthorName:     row.AuthorName,
	}
}

func mapExploreCategoryPost(row generated.GetExplorePostsByCategoryRow) FeedPost {
	var caption *string
	if row.Caption.Valid {
		caption = &row.Caption.String
	}
	var correctsPostID *uuid.UUID
	if row.CorrectsPostID.Valid {
		correctsPostID = &row.CorrectsPostID.UUID
	}
	var sermonSource *string
	if row.SermonSource.Valid {
		sermonSource = &row.SermonSource.String
	}

	return FeedPost{
		ID:             row.ID,
		AuthorID:       row.AuthorID,
		Content:        row.Content,
		Caption:        caption,
		Visibility:     row.Visibility,
		CurrentVersion: row.CurrentVersion,
		IsCorrection:   row.IsCorrection,
		CorrectsPostID: correctsPostID,
		SermonSource:   sermonSource,
		IsDeleted:      row.IsDeleted,
		PublishedAt:    row.PublishedAt,
		AuthorHandle:   row.AuthorHandle,
		AuthorName:     row.AuthorName,
	}
}

func (r *Repository) GetFeedPosts(ctx context.Context, cursorTime time.Time, cursorID uuid.UUID, limit int32) ([]FeedPost, error) {
	rows, err := r.q.GetFeedPosts(ctx, generated.GetFeedPostsParams{
		PublishedAt: cursorTime,
		ID:          cursorID,
		Limit:       limit,
	})
	if err != nil {
		return nil, err
	}
	posts := make([]FeedPost, len(rows))
	for i, row := range rows {
		posts[i] = mapFeedPost(row)
	}
	return posts, nil
}

func (r *Repository) GetExplorePosts(ctx context.Context, cursorTime time.Time, cursorID uuid.UUID, limit int32) ([]FeedPost, error) {
	rows, err := r.q.GetExplorePosts(ctx, generated.GetExplorePostsParams{
		PublishedAt: cursorTime,
		ID:          cursorID,
		Limit:       limit,
	})
	if err != nil {
		return nil, err
	}
	posts := make([]FeedPost, len(rows))
	for i, row := range rows {
		posts[i] = mapExplorePost(row)
	}
	return posts, nil
}

func (r *Repository) GetExplorePostsByCategory(ctx context.Context, categoryID uuid.UUID, cursorTime time.Time, cursorID uuid.UUID, limit int32) ([]FeedPost, error) {
	rows, err := r.q.GetExplorePostsByCategory(ctx, generated.GetExplorePostsByCategoryParams{
		CategoryID:  categoryID,
		PublishedAt: cursorTime,
		ID:          cursorID,
		Limit:       limit,
	})
	if err != nil {
		return nil, err
	}
	posts := make([]FeedPost, len(rows))
	for i, row := range rows {
		posts[i] = mapExploreCategoryPost(row)
	}
	return posts, nil
}

func (r *Repository) ListCategories(ctx context.Context) ([]generated.Category, error) {
	return r.q.ListCategories(ctx)
}
