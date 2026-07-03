package note

import (
	"context"
	"database/sql"
	"encoding/json"
	"log"
	"time"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

// Note represents the domain model for a note.
// Notice again how we trade sqlc's generated Null types (like NullNoteSourceType and NullUUID)
// for clean pointers, making this struct ready for elegant JSON serialization.
type Note struct {
	ID          uuid.UUID       `json:"id"`
	AuthorID    uuid.UUID       `json:"author_id"`
	Content     json.RawMessage `json:"content"`
	Title       *string         `json:"title,omitempty"`
	NotebookID  *uuid.UUID      `json:"notebook_id,omitempty"`
	SourceType  *string         `json:"source_type,omitempty"`
	SourceLabel *string         `json:"source_label,omitempty"`
	UpdatedAt   time.Time       `json:"updated_at"`
	CreatedAt   time.Time       `json:"created_at"`
}

// mapNote translates the raw database type into our clean domain type.
func mapNote(dbNote generated.Note) Note {
	var title *string
	if dbNote.Title.Valid {
		t := dbNote.Title.String
		title = &t
	}

	var notebookID *uuid.UUID
	if dbNote.NotebookID.Valid {
		n := dbNote.NotebookID.UUID
		notebookID = &n
	}

	var sourceType *string
	if dbNote.SourceType.Valid {
		s := string(dbNote.SourceType.NoteSourceType)
		sourceType = &s
	}

	var sourceLabel *string
	if dbNote.SourceLabel.Valid {
		sl := dbNote.SourceLabel.String
		sourceLabel = &sl
	}

	return Note{
		ID:          dbNote.ID,
		AuthorID:    dbNote.AuthorID,
		Content:     dbNote.Content,
		Title:       title,
		NotebookID:  notebookID,
		SourceType:  sourceType,
		SourceLabel: sourceLabel,
		UpdatedAt:   dbNote.UpdatedAt,
		CreatedAt:   dbNote.CreatedAt,
	}
}

// Repository handles all database interactions for Notes.
type Repository struct {
	q *generated.Queries
}

func NewRepository(q *generated.Queries) *Repository {
	return &Repository{q: q}
}

func (r *Repository) CreateNote(ctx context.Context, authorID uuid.UUID, content json.RawMessage, title *string, notebookID *uuid.UUID, sourceType *string, sourceLabel *string) (Note, error) {
	var dbTitle sql.NullString
	if title != nil {
		dbTitle = sql.NullString{String: *title, Valid: true}
	}

	var dbNotebookID uuid.NullUUID
	if notebookID != nil {
		dbNotebookID = uuid.NullUUID{UUID: *notebookID, Valid: true}
	}

	var dbSourceType generated.NullNoteSourceType
	if sourceType != nil {
		dbSourceType = generated.NullNoteSourceType{
			NoteSourceType: generated.NoteSourceType(*sourceType),
			Valid:          true,
		}
	}

	var dbSourceLabel sql.NullString
	if sourceLabel != nil {
		dbSourceLabel = sql.NullString{String: *sourceLabel, Valid: true}
	}

	dbNote, err := r.q.CreateNote(ctx, generated.CreateNoteParams{
		AuthorID:    authorID,
		Content:     content,
		Title:       dbTitle,
		NotebookID:  dbNotebookID,
		SourceType:  dbSourceType,
		SourceLabel: dbSourceLabel,
	})
	if err != nil {
		return Note{}, err
	}
	return mapNote(dbNote), nil
}

func (r *Repository) GetNoteByID(ctx context.Context, id uuid.UUID) (Note, error) {
	dbNote, err := r.q.GetNoteByID(ctx, id)
	if err != nil {
		return Note{}, err
	}
	return mapNote(dbNote), nil
}

func (r *Repository) ListNotesByAuthor(ctx context.Context, authorID uuid.UUID) ([]Note, error) {
	dbNotes, err := r.q.ListNotesByAuthor(ctx, authorID)
	if err != nil {
		return nil, err
	}

	notes := make([]Note, len(dbNotes))
	for i, dbNote := range dbNotes {
		notes[i] = mapNote(dbNote)
	}
	return notes, nil
}

func (r *Repository) UpdateNote(ctx context.Context, id, authorID uuid.UUID, content json.RawMessage, title *string, notebookID *uuid.UUID, sourceType *string, sourceLabel *string) (Note, error) {
	var dbTitle sql.NullString
	if title != nil {
		dbTitle = sql.NullString{String: *title, Valid: true}
	}

	var dbNotebookID uuid.NullUUID
	if notebookID != nil {
		dbNotebookID = uuid.NullUUID{UUID: *notebookID, Valid: true}
	}

	var dbSourceType generated.NullNoteSourceType
	if sourceType != nil {
		dbSourceType = generated.NullNoteSourceType{
			NoteSourceType: generated.NoteSourceType(*sourceType),
			Valid:          true,
		}
	}

	var dbSourceLabel sql.NullString
	if sourceLabel != nil {
		dbSourceLabel = sql.NullString{String: *sourceLabel, Valid: true}
	}

	dbNote, err := r.q.UpdateNote(ctx, generated.UpdateNoteParams{
		ID:          id,
		AuthorID:    authorID,
		Content:     content,
		Title:       dbTitle,
		NotebookID:  dbNotebookID,
		SourceType:  dbSourceType,
		SourceLabel: dbSourceLabel,
	})
	if err != nil {
		return Note{}, err
	}
	return mapNote(dbNote), nil
}

func (r *Repository) DeleteNote(ctx context.Context, id, authorID uuid.UUID) error {
	_,err := r.q.GetNoteByID(ctx,id)
	if err != nil {
		 log.Println("note does not exists to begin with")
	}
	return r.q.DeleteNote(ctx, generated.DeleteNoteParams{
		ID:       id,
		AuthorID: authorID,
	})
}
