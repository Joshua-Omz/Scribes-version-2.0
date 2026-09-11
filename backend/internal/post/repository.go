package post

import (
	"context"
	"database/sql"
	"encoding/json"
	"time"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
	"github.com/sqlc-dev/pqtype"
)

// SoundTrack represents a curated ambient audio loop.
type SoundTrack struct {
	ID              uuid.UUID `json:"id"`
	Title           string    `json:"title"`
	Category        string    `json:"category"`
	AudioURL        string    `json:"audio_url"`
	DurationSeconds int32     `json:"duration_seconds"`
}

// PassagePanel represents a single ordered devotional card in a passage.
type PassagePanel struct {
	ID                 uuid.UUID       `json:"id"`
	PostID             uuid.UUID       `json:"post_id"`
	PanelOrder         int32           `json:"panel_order"`
	PanelType          string          `json:"panel_type"`
	Content            json.RawMessage `json:"content"`
	BackgroundImageURL *string         `json:"background_image_url,omitempty"`
	ScriptureRef       json.RawMessage `json:"scripture_ref,omitempty"`
	CreatedAt          time.Time       `json:"created_at"`
}

// Post represents the domain model for a published post.
type Post struct {
	ID                 uuid.UUID                       `json:"id"`
	AuthorID           uuid.UUID                       `json:"author_id"`
	AuthorHandle       string                          `json:"author_handle"`
	AuthorName         string                          `json:"author_name"`
	Content            json.RawMessage                 `json:"content"`
	Caption            *string                         `json:"caption,omitempty"`
	Visibility         string                          `json:"visibility"`
	CurrentVersion     int32                           `json:"current_version"`
	IsCorrection       bool                            `json:"is_correction"`
	CorrectsPostID     *uuid.UUID                      `json:"corrects_post_id,omitempty"`
	SermonSource       *string                         `json:"sermon_source,omitempty"`
	IsDeleted          bool                            `json:"is_deleted"`
	PublishedAt        time.Time                       `json:"published_at"`
	ScriptureRefs      []generated.GetScriptureRefsRow `json:"scripture_refs,omitempty"`
	Tags               []string                        `json:"tags"`
	CoverImageUrl      *string                         `json:"cover_image_url,omitempty"`
	ReflectionImageUrl *string                         `json:"reflection_image_url,omitempty"`
	SoundID            *uuid.UUID                      `json:"sound_id,omitempty"`
	Sound              *SoundTrack                     `json:"sound,omitempty"`
	Panels             []PassagePanel                  `json:"panels,omitempty"`
	PostType           string                          `json:"post_type"`
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

	var coverImage *string
	if dbPost.CoverImageUrl.Valid {
		ci := dbPost.CoverImageUrl.String
		coverImage = &ci
	}

	var reflectionImage *string
	if dbPost.ReflectionImageUrl.Valid {
		ri := dbPost.ReflectionImageUrl.String
		reflectionImage = &ri
	}

	var soundID *uuid.UUID
	if dbPost.SoundID.Valid {
		sid := dbPost.SoundID.UUID
		soundID = &sid
	}

	var sound *SoundTrack
	if dbPost.SoundTitle.Valid {
		sound = &SoundTrack{
			ID:              dbPost.SoundID.UUID,
			Title:           dbPost.SoundTitle.String,
			Category:        dbPost.SoundCategory.String,
			AudioURL:        dbPost.SoundAudioUrl.String,
			DurationSeconds: dbPost.SoundDurationSeconds.Int32,
		}
	}

	return Post{
		ID:                 dbPost.ID,
		AuthorID:           dbPost.AuthorID,
		AuthorHandle:       dbPost.AuthorHandle,
		AuthorName:         dbPost.AuthorName,
		Content:            dbPost.Content,
		Caption:            caption,
		Visibility:         string(dbPost.Visibility),
		CurrentVersion:     dbPost.CurrentVersion,
		IsCorrection:       dbPost.IsCorrection,
		CorrectsPostID:     correctsPostID,
		SermonSource:       sermonSource,
		IsDeleted:          dbPost.IsDeleted,
		PublishedAt:        dbPost.PublishedAt,
		CoverImageUrl:      coverImage,
		ReflectionImageUrl: reflectionImage,
		SoundID:            soundID,
		Sound:              sound,
		Panels:             []PassagePanel{},
		PostType:           string(dbPost.PostType),
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

	var coverImage *string
	if dbPost.CoverImageUrl.Valid {
		ci := dbPost.CoverImageUrl.String
		coverImage = &ci
	}

	var reflectionImage *string
	if dbPost.ReflectionImageUrl.Valid {
		ri := dbPost.ReflectionImageUrl.String
		reflectionImage = &ri
	}

	var soundID *uuid.UUID
	if dbPost.SoundID.Valid {
		sid := dbPost.SoundID.UUID
		soundID = &sid
	}

	var sound *SoundTrack
	if dbPost.SoundTitle.Valid {
		sound = &SoundTrack{
			ID:              dbPost.SoundID.UUID,
			Title:           dbPost.SoundTitle.String,
			Category:        dbPost.SoundCategory.String,
			AudioURL:        dbPost.SoundAudioUrl.String,
			DurationSeconds: dbPost.SoundDurationSeconds.Int32,
		}
	}

	return Post{
		ID:                 dbPost.ID,
		AuthorID:           dbPost.AuthorID,
		AuthorHandle:       dbPost.AuthorHandle,
		AuthorName:         dbPost.AuthorName,
		Content:            dbPost.Content,
		Caption:            caption,
		Visibility:         string(dbPost.Visibility),
		CurrentVersion:     dbPost.CurrentVersion,
		IsCorrection:       dbPost.IsCorrection,
		CorrectsPostID:     correctsPostID,
		SermonSource:       sermonSource,
		IsDeleted:          dbPost.IsDeleted,
		PublishedAt:        dbPost.PublishedAt,
		CoverImageUrl:      coverImage,
		ReflectionImageUrl: reflectionImage,
		SoundID:            soundID,
		Sound:              sound,
		Panels:             []PassagePanel{},
		PostType:           string(dbPost.PostType),
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

func (r *Repository) CreatePost(ctx context.Context, authorID uuid.UUID, content json.RawMessage, caption *string, visibility string, sermonSource *string, coverImageUrl *string, reflectionImageUrl *string, soundID *uuid.UUID, postType string) (Post, error) {
	var dbCaption sql.NullString
	if caption != nil {
		dbCaption = sql.NullString{String: *caption, Valid: true}
	}

	var dbSermonSource sql.NullString
	if sermonSource != nil {
		dbSermonSource = sql.NullString{String: *sermonSource, Valid: true}
	}

	var dbCoverImageUrl sql.NullString
	if coverImageUrl != nil {
		dbCoverImageUrl = sql.NullString{String: *coverImageUrl, Valid: true}
	}

	var dbReflectionImageUrl sql.NullString
	if reflectionImageUrl != nil {
		dbReflectionImageUrl = sql.NullString{String: *reflectionImageUrl, Valid: true}
	}

	var dbSoundID uuid.NullUUID
	if soundID != nil {
		dbSoundID = uuid.NullUUID{UUID: *soundID, Valid: true}
	}

	if postType == "" {
		postType = "standard"
	}

	dbPost, err := r.q.CreatePost(ctx, generated.CreatePostParams{
		AuthorID:           authorID,
		Content:            content,
		Caption:            dbCaption,
		Visibility:         generated.PostVisibility(visibility),
		SermonSource:       dbSermonSource,
		CoverImageUrl:      dbCoverImageUrl,
		ReflectionImageUrl: dbReflectionImageUrl,
		SoundID:            dbSoundID,
		PostType:           generated.PostType(postType),
	})
	if err != nil {
		return Post{}, err
	}

	// Fetch the hydrated post containing author details
	return r.GetPostByID(ctx, dbPost.ID)
}

func (r *Repository) BulkInsertPassagePanels(ctx context.Context, postID uuid.UUID, panels []PassagePanel) error {
	for i, p := range panels {
		var dbBgImage sql.NullString
		if p.BackgroundImageURL != nil && *p.BackgroundImageURL != "" {
			dbBgImage = sql.NullString{String: *p.BackgroundImageURL, Valid: true}
		}

		var scriptureRef pqtype.NullRawMessage
		if len(p.ScriptureRef) > 0 && string(p.ScriptureRef) != "null" {
			scriptureRef = pqtype.NullRawMessage{RawMessage: p.ScriptureRef, Valid: true}
		}

		content := p.Content
		if len(content) == 0 {
			content = json.RawMessage("{}")
		}

		_, err := r.q.CreatePassagePanel(ctx, generated.CreatePassagePanelParams{
			PostID:             postID,
			PanelOrder:         int32(i),
			PanelType:          generated.PassagePanelType(p.PanelType),
			Content:            content,
			BackgroundImageUrl: dbBgImage,
			ScriptureRef:       scriptureRef,
		})
		if err != nil {
			return err
		}
	}
	return nil
}

func (r *Repository) ListActiveSounds(ctx context.Context) ([]SoundTrack, error) {
	rows, err := r.q.ListActiveSounds(ctx)
	if err != nil {
		return nil, err
	}
	sounds := make([]SoundTrack, 0, len(rows))
	for _, row := range rows {
		sounds = append(sounds, SoundTrack{
			ID:              row.ID,
			Title:           row.Title,
			Category:        row.Category,
			AudioURL:        row.AudioUrl,
			DurationSeconds: row.DurationSeconds,
		})
	}
	return sounds, nil
}

func (r *Repository) GetPostByID(ctx context.Context, id uuid.UUID) (Post, error) {
	dbPost, err := r.q.GetPostByID(ctx, id)
	if err != nil {
		return Post{}, err
	}
	post := mapGetPostByIDRow(dbPost)

	// Hydrate passage panels if this is a passage
	if post.PostType == "passage" {
		panels, err := r.q.ListPassagePanelsByPostID(ctx, id)
		if err == nil {
			post.Panels = make([]PassagePanel, 0, len(panels))
			for _, p := range panels {
				var bgImage *string
				if p.BackgroundImageUrl.Valid {
					bgi := p.BackgroundImageUrl.String
					bgImage = &bgi
				}
				post.Panels = append(post.Panels, PassagePanel{
					ID:                 p.ID,
					PostID:             p.PostID,
					PanelOrder:         p.PanelOrder,
					PanelType:          string(p.PanelType),
					Content:            p.Content,
					BackgroundImageURL: bgImage,
					ScriptureRef:       p.ScriptureRef.RawMessage,
					CreatedAt:          p.CreatedAt,
				})
			}
		}
	}

	refs, err := r.GetScriptureRefs(ctx, id)
	if err == nil {
		post.ScriptureRefs = refs
	}
	tags, err := r.GetPostTags(ctx, id)
	if err == nil {
		post.Tags = tags
	} else {
		post.Tags = []string{}
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
		tags, err := r.GetPostTags(ctx, post.ID)
		if err == nil {
			post.Tags = tags
		} else {
			post.Tags = []string{}
		}
		posts[i] = post
	}
	return posts, nil
}

func (r *Repository) UpdatePost(ctx context.Context, id, authorID uuid.UUID, content json.RawMessage, caption *string, visibility string, sermonSource *string, currentVersion int32, coverImageUrl *string) (Post, error) {
	var dbCaption sql.NullString
	if caption != nil {
		dbCaption = sql.NullString{String: *caption, Valid: true}
	}

	var dbSermonSource sql.NullString
	if sermonSource != nil {
		dbSermonSource = sql.NullString{String: *sermonSource, Valid: true}
	}

	var dbCoverImageUrl sql.NullString
	if coverImageUrl != nil {
		dbCoverImageUrl = sql.NullString{String: *coverImageUrl, Valid: true}
	}

	dbPost, err := r.q.UpdatePost(ctx, generated.UpdatePostParams{
		ID:             id,
		Content:        content,
		Caption:        dbCaption,
		Visibility:     generated.PostVisibility(visibility),
		SermonSource:   dbSermonSource,
		CurrentVersion: currentVersion,
		AuthorID:       authorID,
		CoverImageUrl:  dbCoverImageUrl,
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
func (r *Repository) CreateCorrectionPost(ctx context.Context, authorID uuid.UUID, content json.RawMessage, caption *string, visibility string, sermonSource *string, correctsPostID uuid.UUID, coverImageUrl *string, postType string) (Post, error) {
	var dbCaption sql.NullString
	if caption != nil {
		dbCaption = sql.NullString{String: *caption, Valid: true}
	}

	var dbSermonSource sql.NullString
	if sermonSource != nil {
		dbSermonSource = sql.NullString{String: *sermonSource, Valid: true}
	}

	var dbCoverImageUrl sql.NullString
	if coverImageUrl != nil {
		dbCoverImageUrl = sql.NullString{String: *coverImageUrl, Valid: true}
	}

	if postType == "" {
		postType = "standard"
	}

	dbPost, err := r.q.CreateCorrectionPost(ctx, generated.CreateCorrectionPostParams{
		AuthorID:       authorID,
		Content:        content,
		Caption:        dbCaption,
		Visibility:     generated.PostVisibility(visibility),
		SermonSource:   dbSermonSource,
		CorrectsPostID: uuid.NullUUID{UUID: correctsPostID, Valid: true},
		CoverImageUrl:  dbCoverImageUrl,
		PostType:       generated.PostType(postType),
	})
	if err != nil {
		return Post{}, err
	}
	return r.GetPostByID(ctx, dbPost.ID)
}

// RevisePost performs the atomic revision flow:
// 1. Snapshot the current version into post_versions
// 2. Update the post with new content and bump current_version
func (r *Repository) RevisePost(ctx context.Context, id, authorID uuid.UUID, currentContent json.RawMessage, currentVersion int32, newContent json.RawMessage, newCaption *string, coverImageUrl *string) (Post, error) {
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

	// 2. Update the post
	var dbCaption sql.NullString
	if newCaption != nil {
		dbCaption = sql.NullString{String: *newCaption, Valid: true}
	}

	var dbCoverImageUrl sql.NullString
	if coverImageUrl != nil {
		dbCoverImageUrl = sql.NullString{String: *coverImageUrl, Valid: true}
	}

	dbPost, err := qTx.RevisePost(ctx, generated.RevisePostParams{
		ID:            id,
		Content:       newContent,
		Caption:       dbCaption,
		AuthorID:      authorID,
		CoverImageUrl: dbCoverImageUrl,
	})
	if err != nil {
		return Post{}, err
	}

	err = tx.Commit()
	if err != nil {
		return Post{}, err
	}
	return r.GetPostByID(ctx, dbPost.ID)
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

// ── Internal helpers parameterized on *Queries ──────────────────────────
// These accept a *generated.Queries so they work with both r.q (non-tx)
// and qTx (inside a transaction).

func setPostTagsQ(ctx context.Context, q *generated.Queries, postID uuid.UUID, tags []string) error {
	err := q.ClearPostTags(ctx, postID)
	if err != nil {
		return err
	}
	for _, tagName := range tags {
		tagID, err := q.UpsertTag(ctx, generated.UpsertTagParams{
			PName:        tagName,
			PDisplayName: tagName,
		})
		if err != nil {
			return err
		}
		err = q.AddPostTag(ctx, generated.AddPostTagParams{
			PostID: postID,
			TagID:  tagID,
		})
		if err != nil {
			return err
		}
	}
	return nil
}

func setScriptureRefsQ(ctx context.Context, q *generated.Queries, postID uuid.UUID, refs []generated.AddScriptureRefParams) error {
	err := q.ClearScriptureRefs(ctx, postID)
	if err != nil {
		return err
	}
	for _, ref := range refs {
		ref.PostID = postID
		err = q.AddScriptureRef(ctx, ref)
		if err != nil {
			return err
		}
	}
	return nil
}

func bulkInsertPanelsQ(ctx context.Context, q *generated.Queries, postID uuid.UUID, panels []PassagePanel) error {
	for i, p := range panels {
		var dbBgImage sql.NullString
		if p.BackgroundImageURL != nil && *p.BackgroundImageURL != "" {
			dbBgImage = sql.NullString{String: *p.BackgroundImageURL, Valid: true}
		}

		var scriptureRef pqtype.NullRawMessage
		if len(p.ScriptureRef) > 0 && string(p.ScriptureRef) != "null" {
			scriptureRef = pqtype.NullRawMessage{RawMessage: p.ScriptureRef, Valid: true}
		}

		content := p.Content
		if len(content) == 0 {
			content = json.RawMessage("{}")
		}

		_, err := q.CreatePassagePanel(ctx, generated.CreatePassagePanelParams{
			PostID:             postID,
			PanelOrder:         int32(i),
			PanelType:          generated.PassagePanelType(p.PanelType),
			Content:            content,
			BackgroundImageUrl: dbBgImage,
			ScriptureRef:       scriptureRef,
		})
		if err != nil {
			return err
		}
	}
	return nil
}

// ── Public non-transactional helpers (delegate to Q-parameterized versions) ──

func (r *Repository) SetPostTags(ctx context.Context, postID uuid.UUID, tags []string) error {
	return setPostTagsQ(ctx, r.q, postID, tags)
}

func (r *Repository) GetPostTags(ctx context.Context, postID uuid.UUID) ([]string, error) {
	return r.q.GetPostTags(ctx, postID)
}

func (r *Repository) SetScriptureRefs(ctx context.Context, postID uuid.UUID, refs []generated.AddScriptureRefParams) error {
	return setScriptureRefsQ(ctx, r.q, postID, refs)
}

func (r *Repository) GetScriptureRefs(ctx context.Context, postID uuid.UUID) ([]generated.GetScriptureRefsRow, error) {
	return r.q.GetScriptureRefs(ctx, postID)
}

// ── Transactional mutation methods ──────────────────────────────────────
// Each wraps all writes in a single BeginTx/Commit boundary so that a
// failure at any step rolls back the entire mutation — no ghost posts.

// CreatePostTxParams bundles everything the transactional create needs.
type CreatePostTxParams struct {
	AuthorID           uuid.UUID
	Content            json.RawMessage
	Caption            *string
	Visibility         string
	SermonSource       *string
	CoverImageUrl      *string
	ReflectionImageUrl *string
	SoundID            *uuid.UUID
	PostType           string
	Tags               []string
	ScriptureRefs      []generated.AddScriptureRefParams
	Panels             []PassagePanel
}

func (r *Repository) CreatePostTx(ctx context.Context, params CreatePostTxParams) (Post, error) {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return Post{}, err
	}
	defer tx.Rollback()

	qTx := r.q.WithTx(tx)

	// 1. INSERT the post row
	var dbCaption sql.NullString
	if params.Caption != nil {
		dbCaption = sql.NullString{String: *params.Caption, Valid: true}
	}
	var dbSermonSource sql.NullString
	if params.SermonSource != nil {
		dbSermonSource = sql.NullString{String: *params.SermonSource, Valid: true}
	}
	var dbCoverImageUrl sql.NullString
	if params.CoverImageUrl != nil {
		dbCoverImageUrl = sql.NullString{String: *params.CoverImageUrl, Valid: true}
	}
	var dbReflectionImageUrl sql.NullString
	if params.ReflectionImageUrl != nil {
		dbReflectionImageUrl = sql.NullString{String: *params.ReflectionImageUrl, Valid: true}
	}
	var dbSoundID uuid.NullUUID
	if params.SoundID != nil {
		dbSoundID = uuid.NullUUID{UUID: *params.SoundID, Valid: true}
	}
	postType := params.PostType
	if postType == "" {
		postType = "standard"
	}

	dbPost, err := qTx.CreatePost(ctx, generated.CreatePostParams{
		AuthorID:           params.AuthorID,
		Content:            params.Content,
		Caption:            dbCaption,
		Visibility:         generated.PostVisibility(params.Visibility),
		SermonSource:       dbSermonSource,
		CoverImageUrl:      dbCoverImageUrl,
		ReflectionImageUrl: dbReflectionImageUrl,
		SoundID:            dbSoundID,
		PostType:           generated.PostType(postType),
	})
	if err != nil {
		return Post{}, err
	}

	// 2. INSERT passage panels (if passage type)
	if postType == "passage" && len(params.Panels) > 0 {
		if err := bulkInsertPanelsQ(ctx, qTx, dbPost.ID, params.Panels); err != nil {
			return Post{}, err
		}
	}

	// 3. SET tags
	if len(params.Tags) > 0 {
		if err := setPostTagsQ(ctx, qTx, dbPost.ID, params.Tags); err != nil {
			return Post{}, err
		}
	}

	// 4. SET scripture refs
	if len(params.ScriptureRefs) > 0 {
		if err := setScriptureRefsQ(ctx, qTx, dbPost.ID, params.ScriptureRefs); err != nil {
			return Post{}, err
		}
	}

	// All-or-nothing commit
	if err := tx.Commit(); err != nil {
		return Post{}, err
	}

	// Hydrate outside the transaction (read-only, data is committed)
	return r.GetPostByID(ctx, dbPost.ID)
}

// UpdatePostTxParams bundles everything the transactional update needs.
type UpdatePostTxParams struct {
	PostID         uuid.UUID
	AuthorID       uuid.UUID
	Content        json.RawMessage
	Caption        *string
	Visibility     string
	SermonSource   *string
	CurrentVersion int32
	CoverImageUrl  *string
	Tags           []string
	ScriptureRefs  []generated.AddScriptureRefParams
}

func (r *Repository) UpdatePostTx(ctx context.Context, params UpdatePostTxParams) (Post, error) {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return Post{}, err
	}
	defer tx.Rollback()

	qTx := r.q.WithTx(tx)

	// 1. UPDATE the post row
	var dbCaption sql.NullString
	if params.Caption != nil {
		dbCaption = sql.NullString{String: *params.Caption, Valid: true}
	}
	var dbSermonSource sql.NullString
	if params.SermonSource != nil {
		dbSermonSource = sql.NullString{String: *params.SermonSource, Valid: true}
	}
	var dbCoverImageUrl sql.NullString
	if params.CoverImageUrl != nil {
		dbCoverImageUrl = sql.NullString{String: *params.CoverImageUrl, Valid: true}
	}

	dbPost, err := qTx.UpdatePost(ctx, generated.UpdatePostParams{
		ID:             params.PostID,
		Content:        params.Content,
		Caption:        dbCaption,
		Visibility:     generated.PostVisibility(params.Visibility),
		SermonSource:   dbSermonSource,
		CurrentVersion: params.CurrentVersion,
		AuthorID:       params.AuthorID,
		CoverImageUrl:  dbCoverImageUrl,
	})
	if err != nil {
		return Post{}, err
	}

	// 2. SET scripture refs
	if err := setScriptureRefsQ(ctx, qTx, dbPost.ID, params.ScriptureRefs); err != nil {
		return Post{}, err
	}

	// 3. SET tags
	if err := setPostTagsQ(ctx, qTx, dbPost.ID, params.Tags); err != nil {
		return Post{}, err
	}

	if err := tx.Commit(); err != nil {
		return Post{}, err
	}

	return r.GetPostByID(ctx, dbPost.ID)
}

// CreateCorrectionPostTxParams bundles everything the transactional correction needs.
type CreateCorrectionPostTxParams struct {
	AuthorID       uuid.UUID
	Content        json.RawMessage
	Caption        *string
	Visibility     string
	SermonSource   *string
	CorrectsPostID uuid.UUID
	CoverImageUrl  *string
	PostType       string
	Tags           []string
	ScriptureRefs  []generated.AddScriptureRefParams
}

func (r *Repository) CreateCorrectionPostTx(ctx context.Context, params CreateCorrectionPostTxParams) (Post, error) {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return Post{}, err
	}
	defer tx.Rollback()

	qTx := r.q.WithTx(tx)

	// 1. INSERT correction post
	var dbCaption sql.NullString
	if params.Caption != nil {
		dbCaption = sql.NullString{String: *params.Caption, Valid: true}
	}
	var dbSermonSource sql.NullString
	if params.SermonSource != nil {
		dbSermonSource = sql.NullString{String: *params.SermonSource, Valid: true}
	}
	var dbCoverImageUrl sql.NullString
	if params.CoverImageUrl != nil {
		dbCoverImageUrl = sql.NullString{String: *params.CoverImageUrl, Valid: true}
	}
	postType := params.PostType
	if postType == "" {
		postType = "standard"
	}

	dbPost, err := qTx.CreateCorrectionPost(ctx, generated.CreateCorrectionPostParams{
		AuthorID:       params.AuthorID,
		Content:        params.Content,
		Caption:        dbCaption,
		Visibility:     generated.PostVisibility(params.Visibility),
		SermonSource:   dbSermonSource,
		CorrectsPostID: uuid.NullUUID{UUID: params.CorrectsPostID, Valid: true},
		CoverImageUrl:  dbCoverImageUrl,
		PostType:       generated.PostType(postType),
	})
	if err != nil {
		return Post{}, err
	}

	// 2. SET tags
	if len(params.Tags) > 0 {
		if err := setPostTagsQ(ctx, qTx, dbPost.ID, params.Tags); err != nil {
			return Post{}, err
		}
	}

	// 3. SET scripture refs
	if len(params.ScriptureRefs) > 0 {
		if err := setScriptureRefsQ(ctx, qTx, dbPost.ID, params.ScriptureRefs); err != nil {
			return Post{}, err
		}
	}

	if err := tx.Commit(); err != nil {
		return Post{}, err
	}

	return r.GetPostByID(ctx, dbPost.ID)
}

// RevisePostTxParams bundles everything the transactional revision needs.
type RevisePostTxParams struct {
	PostID         uuid.UUID
	AuthorID       uuid.UUID
	CurrentContent json.RawMessage
	CurrentVersion int32
	NewContent     json.RawMessage
	NewCaption     *string
	CoverImageUrl  *string
	Tags           []string
}

func (r *Repository) RevisePostTx(ctx context.Context, params RevisePostTxParams) (Post, error) {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return Post{}, err
	}
	defer tx.Rollback()

	qTx := r.q.WithTx(tx)

	// 1. Snapshot the current version
	_, err = qTx.CreatePostVersion(ctx, generated.CreatePostVersionParams{
		PostID:          params.PostID,
		VersionNumber:   params.CurrentVersion,
		ContentSnapshot: params.CurrentContent,
		SnapshottedBy:   params.AuthorID,
	})
	if err != nil {
		return Post{}, err
	}

	// 2. Update the post with new content
	var dbCaption sql.NullString
	if params.NewCaption != nil {
		dbCaption = sql.NullString{String: *params.NewCaption, Valid: true}
	}
	var dbCoverImageUrl sql.NullString
	if params.CoverImageUrl != nil {
		dbCoverImageUrl = sql.NullString{String: *params.CoverImageUrl, Valid: true}
	}

	dbPost, err := qTx.RevisePost(ctx, generated.RevisePostParams{
		ID:            params.PostID,
		Content:       params.NewContent,
		Caption:       dbCaption,
		AuthorID:      params.AuthorID,
		CoverImageUrl: dbCoverImageUrl,
	})
	if err != nil {
		return Post{}, err
	}

	// 3. SET tags (now inside the transaction)
	if err := setPostTagsQ(ctx, qTx, dbPost.ID, params.Tags); err != nil {
		return Post{}, err
	}

	if err := tx.Commit(); err != nil {
		return Post{}, err
	}

	return r.GetPostByID(ctx, dbPost.ID)
}
