package post

import (
	"context"
	"database/sql"
	"encoding/json"
	"time"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

// Post represents the domain model for a published post.
// Notice: no UpdatedAt field exists on posts — unlike notes and drafts,
// a post's content is versioned (Sprint 3), not mutated in place.
// The PublishedAt timestamp is set once by the database DEFAULT and never changes.
type Post struct {
	ID             uuid.UUID       `json:"id"`
	AuthorID       uuid.UUID       `json:"author_id"`
	AuthorHandle   string          `json:"author_handle"`
	AuthorName     string          `json:"author_name"`
	Content        json.RawMessage `json:"content"`
	Caption        *string         `json:"caption,omitempty"`
	Visibility     string          `json:"visibility"`
	CurrentVersion int32           `json:"current_version"`
	IsCorrection   bool            `json:"is_correction"`
	CorrectsPostID *uuid.UUID      `json:"corrects_post_id,omitempty"`
	SermonSource   *string               `json:"sermon_source,omitempty"`
	IsDeleted      bool                  `json:"is_deleted"`
	PublishedAt    time.Time             `json:"published_at"`
	ScriptureRefs  []generated.GetScriptureRefsRow `json:"scripture_refs,omitempty"`
}

func mapGetPostByIDRow(dbPost generated.GetPostByIDRow) Post {
	var caption *string
	if dbPost.Caption.Valid {
		c := dbPost.Caption.String
		caption = &c
	}

	var sermonSource *string
	if dbPost.SermonSource.Valid {
		s := dbPost.SermonSource.String
		sermonSource = &s
	}

	var correctsPostID *uuid.UUID
	if dbPost.CorrectsPostID.Valid {
		id := dbPost.CorrectsPostID.UUID
		correctsPostID = &id
	}

	return Post{
		ID:             dbPost.ID,
		AuthorID:       dbPost.AuthorID,
		AuthorHandle:   dbPost.AuthorHandle,
		AuthorName:     dbPost.AuthorName,
		Content:        dbPost.Content,
		Caption:        caption,
		Visibility:     string(dbPost.Visibility),
		CurrentVersion: dbPost.CurrentVersion,
		IsCorrection:   dbPost.IsCorrection,
		CorrectsPostID: correctsPostID,
		SermonSource:   sermonSource,
		IsDeleted:      dbPost.IsDeleted,
		PublishedAt:    dbPost.PublishedAt,
		// ScriptureRefs are populated separately
	}
}

func mapListPostsByAuthorRow(dbPost generated.ListPostsByAuthorRow) Post {
	var caption *string
	if dbPost.Caption.Valid {
		c := dbPost.Caption.String
		caption = &c
	}

	var sermonSource *string
	if dbPost.SermonSource.Valid {
		s := dbPost.SermonSource.String
		sermonSource = &s
	}

	var correctsPostID *uuid.UUID
	if dbPost.CorrectsPostID.Valid {
		id := dbPost.CorrectsPostID.UUID
		correctsPostID = &id
	}

	return Post{
		ID:             dbPost.ID,
		AuthorID:       dbPost.AuthorID,
		AuthorHandle:   dbPost.AuthorHandle,
		AuthorName:     dbPost.AuthorName,
		Content:        dbPost.Content,
		Caption:        caption,
		Visibility:     string(dbPost.Visibility),
		CurrentVersion: dbPost.CurrentVersion,
		IsCorrection:   dbPost.IsCorrection,
		CorrectsPostID: correctsPostID,
		SermonSource:   sermonSource,
		IsDeleted:      dbPost.IsDeleted,
		PublishedAt:    dbPost.PublishedAt,
		// ScriptureRefs are populated separately
	}
}

// PostVersion represents the domain model for an immutable post snapshot.
type PostVersion struct {
	ID              uuid.UUID       `json:"id"`
	PostID          uuid.UUID       `json:"post_id"`
	VersionNumber   int32           `json:"version_number"`
	ContentSnapshot json.RawMessage `json:"content_snapshot"`
	SnapshottedAt   time.Time       `json:"snapshotted_at"`
	SnapshottedBy   uuid.UUID       `json:"snapshotted_by"`
}

func mapPostVersion(dbVersion generated.PostVersion) PostVersion {
	return PostVersion{
		ID:              dbVersion.ID,
		PostID:          dbVersion.PostID,
		VersionNumber:   dbVersion.VersionNumber,
		ContentSnapshot: dbVersion.ContentSnapshot,
		SnapshottedAt:   dbVersion.SnapshottedAt,
		SnapshottedBy:   dbVersion.SnapshottedBy,
	}
}

// Repository handles all database interactions for Posts.
type Repository struct {
	q  *generated.Queries
	db *sql.DB
}

func NewRepository(q *generated.Queries, db *sql.DB) *Repository {
	return &Repository{q: q, db: db}
}

func (r *Repository) CreatePost(ctx context.Context, authorID uuid.UUID, content json.RawMessage, caption *string, visibility string, sermonSource *string) (Post, error) {
	var dbCaption sql.NullString
	if caption != nil {
		dbCaption = sql.NullString{String: *caption, Valid: true}
	}

	var dbSermonSource sql.NullString
	if sermonSource != nil {
		dbSermonSource = sql.NullString{String: *sermonSource, Valid: true}
	}

	dbPost, err := r.q.CreatePost(ctx, generated.CreatePostParams{
		AuthorID:     authorID,
		Content:      content,
		Caption:      dbCaption,
		Visibility:   generated.PostVisibility(visibility),
		SermonSource: dbSermonSource,
	})
	if err != nil {
		return Post{}, err
	}
	
	// Fetch the hydrated post containing author details
	return r.GetPostByID(ctx, dbPost.ID)
}

func (r *Repository) GetPostByID(ctx context.Context, id uuid.UUID) (Post, error) {
	dbPost, err := r.q.GetPostByID(ctx, id)
	if err != nil {
		return Post{}, err
	}
	post := mapGetPostByIDRow(dbPost)
	refs, err := r.GetScriptureRefs(ctx, id)
	if err == nil {
		post.ScriptureRefs = refs
	}
	return post, nil
}

func (r *Repository) ListPostsByAuthor(ctx context.Context, authorID uuid.UUID) ([]Post, error) {
	dbPosts, err := r.q.ListPostsByAuthor(ctx, authorID)
	if err != nil {
		return nil, err
	}

	posts := make([]Post, len(dbPosts))
	for i, dbPost := range dbPosts {
		post := mapListPostsByAuthorRow(dbPost)
		refs, err := r.GetScriptureRefs(ctx, post.ID)
		if err == nil {
			post.ScriptureRefs = refs
		}
		posts[i] = post
	}
	return posts, nil
}

func (r *Repository) UpdatePost(ctx context.Context, id, authorID uuid.UUID, content json.RawMessage, caption *string, visibility string, sermonSource *string, currentVersion int32) (Post, error) {
	var dbCaption sql.NullString
	if caption != nil {
		dbCaption = sql.NullString{String: *caption, Valid: true}
	}

	var dbSermonSource sql.NullString
	if sermonSource != nil {
		dbSermonSource = sql.NullString{String: *sermonSource, Valid: true}
	}

	dbPost, err := r.q.UpdatePost(ctx, generated.UpdatePostParams{
		ID:             id,
		Content:        content,
		Caption:        dbCaption,
		Visibility:     generated.PostVisibility(visibility),
		SermonSource:   dbSermonSource,
		CurrentVersion: currentVersion,
		AuthorID:       authorID,
	})
	if err != nil {
		return Post{}, err
	}
	return r.GetPostByID(ctx, dbPost.ID)
}

func (r *Repository) DeletePost(ctx context.Context, id, authorID uuid.UUID) error {
	return r.q.DeletePost(ctx, generated.DeletePostParams{
		ID:       id,
		AuthorID: authorID,
	})
}

// CreateCorrectionPost creates a new post that declares it corrects a previous post.
func (r *Repository) CreateCorrectionPost(ctx context.Context, authorID uuid.UUID, content json.RawMessage, caption *string, visibility string, sermonSource *string, correctsPostID uuid.UUID) (Post, error) {
	var dbCaption sql.NullString
	if caption != nil {
		dbCaption = sql.NullString{String: *caption, Valid: true}
	}

	var dbSermonSource sql.NullString
	if sermonSource != nil {
		dbSermonSource = sql.NullString{String: *sermonSource, Valid: true}
	}

	dbPost, err := r.q.CreateCorrectionPost(ctx, generated.CreateCorrectionPostParams{
		AuthorID:       authorID,
		Content:        content,
		Caption:        dbCaption,
		Visibility:     generated.PostVisibility(visibility),
		SermonSource:   dbSermonSource,
		CorrectsPostID: uuid.NullUUID{UUID: correctsPostID, Valid: true},
	})
	if err != nil {
		return Post{}, err
	}
	return r.GetPostByID(ctx, dbPost.ID)
}

// RevisePost performs the atomic revision flow:
// 1. Snapshot the current version into post_versions
// 2. Update the post with new content and bump current_version
func (r *Repository) RevisePost(ctx context.Context, id, authorID uuid.UUID, currentContent json.RawMessage, currentVersion int32, newContent json.RawMessage, newCaption *string) (Post, error) {
	// We need a transaction to guarantee the snapshot and update succeed together.
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return Post{}, err
	}
	defer tx.Rollback()

	qTx := r.q.WithTx(tx)

	// 1. Snapshot the current content
	_, err = qTx.CreatePostVersion(ctx, generated.CreatePostVersionParams{
		PostID:          id,
		VersionNumber:   currentVersion,
		ContentSnapshot: currentContent,
		SnapshottedBy:   authorID,
	})
	if err != nil {
		return Post{}, err
	}

	// 2. Update the post (which bumps current_version via the SQL query)
	var dbCaption sql.NullString
	if newCaption != nil {
		dbCaption = sql.NullString{String: *newCaption, Valid: true}
	}

	updatedPost, err := qTx.RevisePost(ctx, generated.RevisePostParams{
		ID:       id,
		Content:  newContent,
		Caption:  dbCaption,
		AuthorID: authorID,
	})
	if err != nil {
		return Post{}, err
	}

	// Commit transaction
	if err := tx.Commit(); err != nil {
		return Post{}, err
	}

	// Fetch hydrated post outside the transaction
	return r.GetPostByID(ctx, updatedPost.ID)
}

func (r *Repository) ListVersionsByPost(ctx context.Context, postID uuid.UUID) ([]PostVersion, error) {
	dbVersions, err := r.q.ListVersionsByPost(ctx, postID)
	if err != nil {
		return nil, err
	}

	versions := make([]PostVersion, len(dbVersions))
	for i, dbVersion := range dbVersions {
		versions[i] = mapPostVersion(dbVersion)
	}
	return versions, nil
}

func (r *Repository) GetVersionByPostAndNumber(ctx context.Context, postID uuid.UUID, versionNumber int32) (PostVersion, error) {
	dbVersion, err := r.q.GetVersionByPostAndNumber(ctx, generated.GetVersionByPostAndNumberParams{
		PostID:        postID,
		VersionNumber: versionNumber,
	})
	if err != nil {
		return PostVersion{}, err
	}
	return mapPostVersion(dbVersion), nil
}

func (r *Repository) SetPostCategories(ctx context.Context, postID uuid.UUID, categoryIDs []uuid.UUID) error {
	err := r.q.ClearPostCategories(ctx, postID)
	if err != nil {
		return err
	}
	for _, catID := range categoryIDs {
		err = r.q.AddPostCategory(ctx, generated.AddPostCategoryParams{
			PostID:     postID,
			CategoryID: catID,
		})
		if err != nil {
			return err
		}
	}
	return nil
}

func (r *Repository) GetPostCategories(ctx context.Context, postID uuid.UUID) ([]uuid.UUID, error) {
	return r.q.GetPostCategories(ctx, postID)
}

func (r *Repository) SetScriptureRefs(ctx context.Context, postID uuid.UUID, refs []generated.AddScriptureRefParams) error {
	err := r.q.ClearScriptureRefs(ctx, postID)
	if err != nil {
		return err
	}
	for _, ref := range refs {
		ref.PostID = postID
		err = r.q.AddScriptureRef(ctx, ref)
		if err != nil {
			return err
		}
	}
	return nil
}

func (r *Repository) GetScriptureRefs(ctx context.Context, postID uuid.UUID) ([]generated.GetScriptureRefsRow, error) {
	return r.q.GetScriptureRefs(ctx, postID)
}