// Package notes implements the private workspace note model and repository.
package notes

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// Note is a private, offline-first writing unit owned by a single user.
type Note struct {
	ID        string     `json:"id"`
	UserID    string     `json:"user_id"`
	Title     string     `json:"title"`
	Body      string     `json:"body"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `json:"deleted_at,omitempty"`
}

// Repository is the data-access layer for notes.
type Repository struct {
	db *pgxpool.Pool
}

// NewRepository creates a Repository.
func NewRepository(db *pgxpool.Pool) *Repository { return &Repository{db: db} }

// Create inserts a new note.
func (r *Repository) Create(ctx context.Context, userID, title, body string) (*Note, error) {
	const q = `
		INSERT INTO notes (user_id, title, body)
		VALUES ($1, $2, $3)
		RETURNING id, user_id, title, body, created_at, updated_at, deleted_at`

	n := &Note{}
	err := r.db.QueryRow(ctx, q, userID, title, body).
		Scan(&n.ID, &n.UserID, &n.Title, &n.Body, &n.CreatedAt, &n.UpdatedAt, &n.DeletedAt)
	if err != nil {
		return nil, fmt.Errorf("notes.Create: %w", err)
	}
	return n, nil
}

// List returns all non-deleted notes for a user, newest first.
func (r *Repository) List(ctx context.Context, userID string) ([]*Note, error) {
	const q = `
		SELECT id, user_id, title, body, created_at, updated_at, deleted_at
		FROM notes
		WHERE user_id = $1 AND deleted_at IS NULL
		ORDER BY created_at DESC`

	rows, err := r.db.Query(ctx, q, userID)
	if err != nil {
		return nil, fmt.Errorf("notes.List: %w", err)
	}
	defer rows.Close()

	var notes []*Note
	for rows.Next() {
		n := &Note{}
		if err = rows.Scan(&n.ID, &n.UserID, &n.Title, &n.Body, &n.CreatedAt, &n.UpdatedAt, &n.DeletedAt); err != nil {
			return nil, fmt.Errorf("notes.List scan: %w", err)
		}
		notes = append(notes, n)
	}
	return notes, rows.Err()
}

// GetByID retrieves a single note by id (must belong to userID).
func (r *Repository) GetByID(ctx context.Context, id, userID string) (*Note, error) {
	const q = `
		SELECT id, user_id, title, body, created_at, updated_at, deleted_at
		FROM notes
		WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL`

	n := &Note{}
	err := r.db.QueryRow(ctx, q, id, userID).
		Scan(&n.ID, &n.UserID, &n.Title, &n.Body, &n.CreatedAt, &n.UpdatedAt, &n.DeletedAt)
	if err != nil {
		return nil, fmt.Errorf("notes.GetByID: %w", err)
	}
	return n, nil
}

// Update modifies title and body of an existing note (LWW: latest caller wins).
func (r *Repository) Update(ctx context.Context, id, userID, title, body string) (*Note, error) {
	const q = `
		UPDATE notes SET title = $3, body = $4, updated_at = NOW()
		WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL
		RETURNING id, user_id, title, body, created_at, updated_at, deleted_at`

	n := &Note{}
	err := r.db.QueryRow(ctx, q, id, userID, title, body).
		Scan(&n.ID, &n.UserID, &n.Title, &n.Body, &n.CreatedAt, &n.UpdatedAt, &n.DeletedAt)
	if err != nil {
		return nil, fmt.Errorf("notes.Update: %w", err)
	}
	return n, nil
}

// SoftDelete marks a note as deleted (sets deleted_at = NOW()).
func (r *Repository) SoftDelete(ctx context.Context, id, userID string) error {
	const q = `
		UPDATE notes SET deleted_at = NOW(), updated_at = NOW()
		WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL`

	tag, err := r.db.Exec(ctx, q, id, userID)
	if err != nil {
		return fmt.Errorf("notes.SoftDelete: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("notes.SoftDelete: note not found")
	}
	return nil
}

// ListUpdatedAfter returns notes updated after a given timestamp (for delta sync).
func (r *Repository) ListUpdatedAfter(ctx context.Context, userID string, since time.Time) ([]*Note, error) {
	const q = `
		SELECT id, user_id, title, body, created_at, updated_at, deleted_at
		FROM notes
		WHERE user_id = $1 AND updated_at > $2
		ORDER BY updated_at ASC`

	rows, err := r.db.Query(ctx, q, userID, since)
	if err != nil {
		return nil, fmt.Errorf("notes.ListUpdatedAfter: %w", err)
	}
	defer rows.Close()

	var result []*Note
	for rows.Next() {
		n := &Note{}
		if err = rows.Scan(&n.ID, &n.UserID, &n.Title, &n.Body, &n.CreatedAt, &n.UpdatedAt, &n.DeletedAt); err != nil {
			return nil, fmt.Errorf("notes.ListUpdatedAfter scan: %w", err)
		}
		result = append(result, n)
	}
	return result, rows.Err()
}

// Upsert inserts or updates a note record coming from the sync push (LWW).
// If an existing row's updated_at is newer, the push is silently ignored.
func (r *Repository) Upsert(ctx context.Context, n *Note) error {
	const q = `
		INSERT INTO notes (id, user_id, title, body, created_at, updated_at, deleted_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		ON CONFLICT (id) DO UPDATE
		  SET title      = EXCLUDED.title,
		      body       = EXCLUDED.body,
		      updated_at = EXCLUDED.updated_at,
		      deleted_at = EXCLUDED.deleted_at
		WHERE notes.updated_at < EXCLUDED.updated_at`

	_, err := r.db.Exec(ctx, q,
		n.ID, n.UserID, n.Title, n.Body, n.CreatedAt, n.UpdatedAt, n.DeletedAt)
	if err != nil {
		return fmt.Errorf("notes.Upsert: %w", err)
	}
	return nil
}
