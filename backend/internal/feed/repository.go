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

// enrichPosts performs a bulk fetch of scripture refs and tags for a slice of
// posts, then attaches them in-memory. This replaces per-post N+1 queries with
// exactly 2 bulk queries regardless of page size.
func (r *Repository) enrichPosts(ctx context.Context, posts []FeedPost) error {
	if len(posts) == 0 {
		return nil
	}

	// 1. Collect all post IDs
	ids := make([]uuid.UUID, len(posts))
	for i, p := range posts {
		ids[i] = p.ID
	}

	// 2. Bulk fetch scripture refs
	allRefs, err := r.q.GetScriptureRefsForPosts(ctx, ids)
	if err != nil {
		return err
	}
	refsMap := make(map[uuid.UUID][]generated.GetScriptureRefsRow)
	for _, ref := range allRefs {
		refsMap[ref.PostID] = append(refsMap[ref.PostID], generated.GetScriptureRefsRow{
			Book:       ref.Book,
			Chapter:    ref.Chapter,
			VerseStart: ref.VerseStart,
			VerseEnd:   ref.VerseEnd,
		})
	}

	// 3. Bulk fetch tags
	allTags, err := r.q.GetPostTagsForPosts(ctx, ids)
	if err != nil {
		return err
	}
	tagsMap := make(map[uuid.UUID][]string)
	for _, tag := range allTags {
		tagsMap[tag.PostID] = append(tagsMap[tag.PostID], tag.DisplayName)
	}

	// 4. Attach in-memory
	for i := range posts {
		posts[i].ScriptureRefs = refsMap[posts[i].ID]
		if tags, ok := tagsMap[posts[i].ID]; ok {
			posts[i].Tags = tags
		} else {
			posts[i].Tags = []string{}
		}
	}

	return nil
}

type FeedPost struct {
	ID              uuid.UUID                       `json:"id"`
	AuthorID        uuid.UUID                       `json:"author_id"`
	Content         json.RawMessage                 `json:"content"`
	Caption         *string                         `json:"caption"`
	Visibility      generated.PostVisibility        `json:"visibility"`
	CurrentVersion  int32                           `json:"current_version"`
	IsCorrection    bool                            `json:"is_correction"`
	CorrectsPostID  *uuid.UUID                      `json:"corrects_post_id"`
	SermonSource    *string                         `json:"sermon_source"`
	IsDeleted       bool                            `json:"is_deleted"`
	PublishedAt     time.Time                       `json:"published_at"`
	AuthorHandle    string                          `json:"author_handle"`
	AuthorName      string                          `json:"author_name"`
	CoverImageUrl   *string                         `json:"cover_image_url,omitempty"`
	PostType        generated.PostType              `json:"post_type"`
	AuthorAvatarUrl *string                         `json:"author_avatar_url,omitempty"`
	ScriptureRefs   []generated.GetScriptureRefsRow `json:"scripture_refs,omitempty"`
	Tags            []string                        `json:"tags,omitempty"`
	AmenCount       int32                           `json:"amen_count"`
	CommentCount    int32                           `json:"comment_count"`
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
		CoverImageUrl: func() *string {
			if row.CoverImageUrl.Valid {
				return &row.CoverImageUrl.String
			}
			return nil
		}(),
		PostType: row.PostType,
		AuthorAvatarUrl: func() *string {
			if row.AuthorAvatarUrl.Valid {
				return &row.AuthorAvatarUrl.String
			}
			return nil
		}(),
		AmenCount:      row.AmenCount,
		CommentCount:   row.CommentCount,
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
		CoverImageUrl: func() *string {
			if row.CoverImageUrl.Valid {
				return &row.CoverImageUrl.String
			}
			return nil
		}(),
		PostType: row.PostType,
		AuthorAvatarUrl: func() *string {
			if row.AuthorAvatarUrl.Valid {
				return &row.AuthorAvatarUrl.String
			}
			return nil
		}(),
		AmenCount:      row.AmenCount,
		CommentCount:   row.CommentCount,
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
		CoverImageUrl: func() *string {
			if row.CoverImageUrl.Valid {
				return &row.CoverImageUrl.String
			}
			return nil
		}(),
		PostType: row.PostType,
		AuthorAvatarUrl: func() *string {
			if row.AuthorAvatarUrl.Valid {
				return &row.AuthorAvatarUrl.String
			}
			return nil
		}(),
		AmenCount:      row.AmenCount,
		CommentCount:   row.CommentCount,
	}
}

func mapExploreTagPost(row generated.GetExplorePostsByTagRow) FeedPost {
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
		CoverImageUrl: func() *string {
			if row.CoverImageUrl.Valid {
				return &row.CoverImageUrl.String
			}
			return nil
		}(),
		PostType: row.PostType,
		AuthorAvatarUrl: func() *string {
			if row.AuthorAvatarUrl.Valid {
				return &row.AuthorAvatarUrl.String
			}
			return nil
		}(),
		AmenCount:      row.AmenCount,
		CommentCount:   row.CommentCount,
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
		CoverImageUrl: func() *string {
			if row.CoverImageUrl.Valid {
				return &row.CoverImageUrl.String
			}
			return nil
		}(),
		PostType: row.PostType,
		AuthorAvatarUrl: func() *string {
			if row.AuthorAvatarUrl.Valid {
				return &row.AuthorAvatarUrl.String
			}
			return nil
		}(),
		AmenCount:      row.AmenCount,
		CommentCount:   row.CommentCount,
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
		CoverImageUrl: func() *string {
			if row.CoverImageUrl.Valid {
				return &row.CoverImageUrl.String
			}
			return nil
		}(),
		PostType: row.PostType,
		AuthorAvatarUrl: func() *string {
			if row.AuthorAvatarUrl.Valid {
				return &row.AuthorAvatarUrl.String
			}
			return nil
		}(),
		AmenCount:      row.AmenCount,
		CommentCount:   row.CommentCount,
	}
}

func mapChurchPost(row generated.GetChurchPostsRow) FeedPost {
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
		CoverImageUrl: func() *string {
			if row.CoverImageUrl.Valid {
				return &row.CoverImageUrl.String
			}
			return nil
		}(),
		PostType: row.PostType,
		AuthorAvatarUrl: func() *string {
			if row.AuthorAvatarUrl.Valid {
				return &row.AuthorAvatarUrl.String
			}
			return nil
		}(),
		AmenCount:      row.AmenCount,
		CommentCount:   row.CommentCount,
	}
}

func mapForYouPost(row generated.GetForYouPostsRow) FeedPost {
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
		CoverImageUrl: func() *string {
			if row.CoverImageUrl.Valid {
				return &row.CoverImageUrl.String
			}
			return nil
		}(),
		PostType: row.PostType,
		AuthorAvatarUrl: func() *string {
			if row.AuthorAvatarUrl.Valid {
				return &row.AuthorAvatarUrl.String
			}
			return nil
		}(),
		AmenCount:      row.AmenCount,
		CommentCount:   row.CommentCount,
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
	if err := r.enrichPosts(ctx, posts); err != nil {
		return nil, err
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
		posts[i] = mapFollowingFeedPost(row)
	}
	if err := r.enrichPosts(ctx, posts); err != nil {
		return nil, err
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
	if err := r.enrichPosts(ctx, posts); err != nil {
		return nil, err
	}
	return posts, nil
}

func (r *Repository) GetExplorePostsByTag(ctx context.Context, tag string, cursorTime time.Time, cursorID uuid.UUID, limit int32) ([]FeedPost, error) {
	rows, err := r.q.GetExplorePostsByTag(ctx, generated.GetExplorePostsByTagParams{
		Name:        tag,
		PublishedAt: cursorTime,
		ID:          cursorID,
		Limit:       limit,
	})
	if err != nil {
		return nil, err
	}
	posts := make([]FeedPost, len(rows))
	for i, row := range rows {
		posts[i] = mapExploreTagPost(row)
	}
	if err := r.enrichPosts(ctx, posts); err != nil {
		return nil, err
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
		posts[i] = mapExploreScripturePost(row)
	}
	if err := r.enrichPosts(ctx, posts); err != nil {
		return nil, err
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
		posts[i] = mapSearchExplorePost(row)
	}
	if err := r.enrichPosts(ctx, posts); err != nil {
		return nil, err
	}
	return posts, nil
}

func (r *Repository) GetChurchPosts(ctx context.Context, cursorTime time.Time, cursorID uuid.UUID, limit int32) ([]FeedPost, error) {
	rows, err := r.q.GetChurchPosts(ctx, generated.GetChurchPostsParams{
		PublishedAt: cursorTime,
		ID:          cursorID,
		Limit:       limit,
	})
	if err != nil {
		return nil, err
	}
	posts := make([]FeedPost, len(rows))
	for i, row := range rows {
		posts[i] = mapChurchPost(row)
	}
	if err := r.enrichPosts(ctx, posts); err != nil {
		return nil, err
	}
	return posts, nil
}

func (r *Repository) GetForYouPosts(ctx context.Context, userID uuid.UUID, cursorTime time.Time, cursorID uuid.UUID, limit int32) ([]FeedPost, error) {
	rows, err := r.q.GetForYouPosts(ctx, generated.GetForYouPostsParams{
		UserID:      userID,
		PublishedAt: cursorTime,
		ID:          cursorID,
		Limit:       limit,
	})
	if err != nil {
		return nil, err
	}
	posts := make([]FeedPost, len(rows))
	for i, row := range rows {
		posts[i] = mapForYouPost(row)
	}
	if err := r.enrichPosts(ctx, posts); err != nil {
		return nil, err
	}
	return posts, nil
}
