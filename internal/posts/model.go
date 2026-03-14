package posts

import (
	"encoding/json"
	"time"
)

// Post is an immutable published document.
type Post struct {
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

// PostEvent records an audit event for a post.
type PostEvent struct {
	ID        string          `json:"id"`
	PostID    string          `json:"post_id"`
	UserID    string          `json:"user_id"`
	EventType string          `json:"event_type"`
	Metadata  json.RawMessage `json:"metadata"`
	CreatedAt time.Time       `json:"created_at"`
}

// PublishRequest is the payload for POST /posts/publish.
type PublishRequest struct {
	NoteID string `json:"note_id"`
}
