package notes

import (
	"encoding/json"
	"time"
)

// Note represents a user's draft document.
type Note struct {
	ID          string          `json:"id"`
	UserID      string          `json:"user_id"`
	Title       string          `json:"title"`
	Content     json.RawMessage `json:"content"`
	IsPublished bool            `json:"is_published"`
	IsImported  bool            `json:"is_imported"`
	CreatedAt   time.Time       `json:"created_at"`
	UpdatedAt   time.Time       `json:"updated_at"`
	DeletedAt   *time.Time      `json:"deleted_at,omitempty"`
}

// CreateNoteRequest is the payload for POST /notes.
type CreateNoteRequest struct {
	Title   string          `json:"title"`
	Content json.RawMessage `json:"content"`
}

// UpdateNoteRequest is the payload for PATCH /notes/{id}.
type UpdateNoteRequest struct {
	Title   *string         `json:"title"`
	Content json.RawMessage `json:"content"`
}
