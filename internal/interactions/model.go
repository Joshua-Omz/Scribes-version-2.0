package interactions

import (
	"encoding/json"
	"time"
)

// Comment is a user comment on a post.
type Comment struct {
	ID        string     `json:"id"`
	PostID    string     `json:"post_id"`
	UserID    string     `json:"user_id"`
	Content   string     `json:"content"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `json:"deleted_at,omitempty"`
}

// Reaction is a user reaction on a post.
type Reaction struct {
	ID           string    `json:"id"`
	PostID       string    `json:"post_id"`
	UserID       string    `json:"user_id"`
	ReactionType string    `json:"reaction_type"`
	CreatedAt    time.Time `json:"created_at"`
}

// Bookmark is a user bookmark of a post.
type Bookmark struct {
	ID        string    `json:"id"`
	PostID    string    `json:"post_id"`
	UserID    string    `json:"user_id"`
	CreatedAt time.Time `json:"created_at"`
}

// Import records that a user imported a post as a read-only note copy.
type Import struct {
	ID        string    `json:"id"`
	PostID    string    `json:"post_id"`
	UserID    string    `json:"user_id"`
	NoteID    *string   `json:"note_id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// CreateCommentRequest is the payload for POST /posts/{id}/comments.
type CreateCommentRequest struct {
	Content string `json:"content"`
}

// CreateReactionRequest is the payload for POST /posts/{id}/reactions.
type CreateReactionRequest struct {
	ReactionType string `json:"reaction_type"`
}

// ImportedNote is the note created when importing a post.
type ImportedNote struct {
	ID          string          `json:"id"`
	UserID      string          `json:"user_id"`
	Title       string          `json:"title"`
	Content     json.RawMessage `json:"content"`
	IsPublished bool            `json:"is_published"`
	IsImported  bool            `json:"is_imported"`
	CreatedAt   time.Time       `json:"created_at"`
	UpdatedAt   time.Time       `json:"updated_at"`
}
