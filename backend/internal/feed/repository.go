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
	ScriptureRefs  []generated.GetScriptureRefsRow `json:"scripture_refs,omitempty"`
}

func mapFollowingFeedPost(row generated.GetFollowingFeedPostsRow) FeedPost {
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

func mapExploreScripturePost(row generated.GetExplorePostsByScriptureRow) FeedPost {
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

func mapSearchExplorePost(row generated.SearchExplorePostsRow) FeedPost {
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
		post := mapFeedPost(row)
		refs, err := r.q.GetScriptureRefs(ctx, post.ID)
		if err == nil {
			post.ScriptureRefs = refs
		}
		posts[i] = post
	}
	return posts, nil
}

func (r *Repository) GetFollowingFeedPosts(ctx context.Context, userID uuid.UUID, cursorTime time.Time, cursorID uuid.UUID, limit int32) ([]FeedPost, error) {
	rows, err := r.q.GetFollowingFeedPosts(ctx, generated.GetFollowingFeedPostsParams{
		FollowerID:  userID,
		PublishedAt: cursorTime,
		ID:          cursorID,
		Limit:       limit,
	})
	if err != nil {
		return nil, err
	}
	posts := make([]FeedPost, len(rows))
	for i, row := range rows {
		post := mapFollowingFeedPost(row)
		refs, err := r.q.GetScriptureRefs(ctx, post.ID)
		if err == nil {
			post.ScriptureRefs = refs
		}
		posts[i] = post
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
		post := mapExplorePost(row)
		refs, err := r.q.GetScriptureRefs(ctx, post.ID)
		if err == nil {
			post.ScriptureRefs = refs
		}
		posts[i] = post
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
		post := mapExploreCategoryPost(row)
		refs, err := r.q.GetScriptureRefs(ctx, post.ID)
		if err == nil {
			post.ScriptureRefs = refs
		}
		posts[i] = post
	}
	return posts, nil
}

func (r *Repository) GetExplorePostsByScripture(ctx context.Context, book string, chapter int32, cursorTime time.Time, cursorID uuid.UUID, limit int32) ([]FeedPost, error) {
	rows, err := r.q.GetExplorePostsByScripture(ctx, generated.GetExplorePostsByScriptureParams{
		Book:        book,
		Chapter:     chapter,
		PublishedAt: cursorTime,
		ID:          cursorID,
		Limit:       limit,
	})
	if err != nil {
		return nil, err
	}
	posts := make([]FeedPost, len(rows))
	for i, row := range rows {
		post := mapExploreScripturePost(row)
		refs, err := r.q.GetScriptureRefs(ctx, post.ID)
		if err == nil {
			post.ScriptureRefs = refs
		}
		posts[i] = post
	}
	return posts, nil
}

func (r *Repository) SearchExplorePosts(ctx context.Context, query string, cursorTime time.Time, cursorID uuid.UUID, limit int32) ([]FeedPost, error) {
	rows, err := r.q.SearchExplorePosts(ctx, generated.SearchExplorePostsParams{
		SearchQuery: query,
		PublishedAt: cursorTime,
		ID:          cursorID,
		Limit:       limit,
	})
	if err != nil {
		return nil, err
	}
	posts := make([]FeedPost, len(rows))
	for i, row := range rows {
		post := mapSearchExplorePost(row)
		refs, err := r.q.GetScriptureRefs(ctx, post.ID)
		if err == nil {
			post.ScriptureRefs = refs
		}
		posts[i] = post
	}
	return posts, nil
}

func (r *Repository) ListCategories(ctx context.Context) ([]generated.Category, error) {
	return r.q.ListCategories(ctx)
}
