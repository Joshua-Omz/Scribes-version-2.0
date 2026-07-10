package draft

import (
	"context"
	"database/sql"
	"encoding/json"
	"time"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

// Draft represents the domain model for a draft.
// Notice how we use *string for optional fields instead of sql.NullString.
type Draft struct {
	ID           uuid.UUID       `json:"id"`
	AuthorID     uuid.UUID       `json:"author_id"`
	Content      json.RawMessage `json:"content"`
	Caption      *string         `json:"caption,omitempty"`
	SermonSource *string         `json:"sermon_source,omitempty"`
	CreatedAt    time.Time       `json:"created_at"`
	UpdatedAt    time.Time       `json:"updated_at"`
}

// mapDraft is our "translator" function. It converts the raw database type
// into our clean domain type.
func mapDraft(dbDraft generated.Draft) Draft {
	var caption *string
	if dbDraft.Caption.Valid {
		c := dbDraft.Caption.String
		caption = &c
	}

	var sermonSource *string
	if dbDraft.SermonSource.Valid {
		s := dbDraft.SermonSource.String
		sermonSource = &s
	}

	return Draft{
		ID:           dbDraft.ID,
		AuthorID:     dbDraft.AuthorID,
		Content:      dbDraft.Content,
		Caption:      caption,
		SermonSource: sermonSource,
		CreatedAt:    dbDraft.CreatedAt,
		UpdatedAt:    dbDraft.UpdatedAt,
	}
}

// Repository handles all database interactions for Drafts.
type Repository struct {
	q *generated.Queries
}

func NewRepository(q *generated.Queries) *Repository {
	return &Repository{q: q}
}

func (r *Repository) CreateDraft(ctx context.Context, authorID uuid.UUID, content json.RawMessage, caption, sermonSource *string) (Draft, error) {
	var dbCaption sql.NullString
	if caption != nil {
		dbCaption = sql.NullString{String: *caption, Valid: true}
	}

	var dbSermonSource sql.NullString
	if sermonSource != nil {
		dbSermonSource = sql.NullString{String: *sermonSource, Valid: true}
	}

	dbDraft, err := r.q.CreateDraft(ctx, generated.CreateDraftParams{
		AuthorID:     authorID,
		Content:      content,
		Caption:      dbCaption,
		SermonSource: dbSermonSource,
	})
	if err != nil {
		return Draft{}, err
	}
	return mapDraft(dbDraft), nil
}

func (r *Repository) GetDraftByID(ctx context.Context, id uuid.UUID) (Draft, error) {
	dbDraft, err := r.q.GetDraftByID(ctx, id)
	if err != nil {
		return Draft{}, err
	}
	return mapDraft(dbDraft), nil
}

func (r *Repository) ListDraftsByAuthor(ctx context.Context, authorID uuid.UUID) ([]Draft, error) {
	dbDrafts, err := r.q.ListDraftsByAuthor(ctx, authorID)
	if err != nil {
		return nil, err
	}

	drafts := make([]Draft, len(dbDrafts))
	for i, dbDraft := range dbDrafts {
		drafts[i] = mapDraft(dbDraft)
	}
	return drafts, nil
}

func (r *Repository) UpdateDraft(ctx context.Context, id, authorID uuid.UUID, content json.RawMessage, caption, sermonSource *string) (Draft, error) {
	var dbCaption sql.NullString
	if caption != nil {
		dbCaption = sql.NullString{String: *caption, Valid: true}
	}

	var dbSermonSource sql.NullString
	if sermonSource != nil {
		dbSermonSource = sql.NullString{String: *sermonSource, Valid: true}
	}

	dbDraft, err := r.q.UpdateDraft(ctx, generated.UpdateDraftParams{
		ID:           id,
		AuthorID:     authorID,
		Content:      content,
		Caption:      dbCaption,
		SermonSource: dbSermonSource,
	})
	if err != nil {
		return Draft{}, err
	}
	return mapDraft(dbDraft), nil
}

func (r *Repository) DeleteDraft(ctx context.Context, id, authorID uuid.UUID) error {
	return r.q.DeleteDraft(ctx, generated.DeleteDraftParams{
		ID:       id,
		AuthorID: authorID,
	})
}

func (r *Repository) SetDraftCategories(ctx context.Context, draftID uuid.UUID, categoryIDs []uuid.UUID) error {
	err := r.q.ClearDraftCategories(ctx, draftID)
	if err != nil {
		return err
	}
	for _, catID := range categoryIDs {
		err = r.q.AddDraftCategory(ctx, generated.AddDraftCategoryParams{
			DraftID:    draftID,
			CategoryID: catID,
		})
		if err != nil {
			return err
		}
	}
	return nil
}

func (r *Repository) GetDraftCategories(ctx context.Context, draftID uuid.UUID) ([]uuid.UUID, error) {
	return r.q.GetDraftCategories(ctx, draftID)
}
