package sync

import (
	"encoding/json"
	"time"
)

// DeltaResponse contains items changed since last_synced_at.
type DeltaResponse struct {
	Notes     []NoteSync     `json:"notes"`
	Posts     []PostSync     `json:"posts"`
	Bookmarks []BookmarkSync `json:"bookmarks"`
	SyncedAt  time.Time      `json:"synced_at"`
}

// NoteSync is a note entry in the delta sync response.
type NoteSync struct {
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

// PostSync is a post entry in the delta sync response.
type PostSync struct {
	ID          string          `json:"id"`
	UserID      string          `json:"user_id"`
	NoteID      *string         `json:"note_id"`
	Title       string          `json:"title"`
	Content     json.RawMessage `json:"content"`
	IsArchived  bool            `json:"is_archived"`
	PublishedAt time.Time       `json:"published_at"`
	CreatedAt   time.Time       `json:"created_at"`
	UpdatedAt   time.Time       `json:"updated_at"`
	DeletedAt   *time.Time      `json:"deleted_at,omitempty"`
}

// BookmarkSync is a bookmark entry in the delta sync response.
type BookmarkSync struct {
	ID        string    `json:"id"`
	PostID    string    `json:"post_id"`
	UserID    string    `json:"user_id"`
	CreatedAt time.Time `json:"created_at"`
}
