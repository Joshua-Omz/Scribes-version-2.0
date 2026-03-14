package posts

import (
	"context"
	"database/sql"
	"fmt"
)

// Repository defines post data access.
type Repository interface {
	Publish(ctx context.Context, userID, noteID string) (*Post, error)
	GetByID(ctx context.Context, id string) (*Post, error)
	List(ctx context.Context) ([]*Post, error)
	Archive(ctx context.Context, id, userID string) (*Post, error)
	LogEvent(ctx context.Context, postID, userID, eventType string, metadata []byte) error
}

type postgresRepo struct {
	db *sql.DB
}

// NewRepository creates a PostgreSQL-backed post repository.
func NewRepository(db *sql.DB) Repository {
	return &postgresRepo{db: db}
}

// Publish creates a post from a note in a single transaction. The note must belong to userID,
// must not already be published, and must not be an import.
func (r *postgresRepo) Publish(ctx context.Context, userID, noteID string) (*Post, error) {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return nil, fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback() //nolint:errcheck

	// Lock and read the note.
	var title string
	var content []byte
	var isPublished, isImported bool
	err = tx.QueryRowContext(ctx,
		`SELECT title, content, is_published, is_imported
		 FROM notes WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL
		 FOR UPDATE`,
		noteID, userID,
	).Scan(&title, &content, &isPublished, &isImported)
	if err == sql.ErrNoRows {
		return nil, ErrNoteNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("fetch note: %w", err)
	}
	if isPublished {
		return nil, ErrAlreadyPublished
	}
	if isImported {
		return nil, ErrImportedNote
	}

	// Create the immutable post.
	p := &Post{}
	err = tx.QueryRowContext(ctx,
		`INSERT INTO posts (user_id, note_id, title, content)
		 VALUES ($1, $2, $3, $4)
		 RETURNING id, user_id, note_id, title, content, is_archived, published_at, created_at, updated_at, deleted_at`,
		userID, noteID, title, content,
	).Scan(&p.ID, &p.UserID, &p.NoteID, &p.Title, &p.Content, &p.IsArchived, &p.PublishedAt, &p.CreatedAt, &p.UpdatedAt, &p.DeletedAt)
	if err != nil {
		return nil, fmt.Errorf("insert post: %w", err)
	}

	// Mark note as published.
	if _, err := tx.ExecContext(ctx,
		`UPDATE notes SET is_published = TRUE, updated_at = NOW() WHERE id = $1`,
		noteID,
	); err != nil {
		return nil, fmt.Errorf("mark note published: %w", err)
	}

	// Log publish event.
	if _, err := tx.ExecContext(ctx,
		`INSERT INTO post_events (post_id, user_id, event_type, metadata) VALUES ($1, $2, 'published', '{}')`,
		p.ID, userID,
	); err != nil {
		return nil, fmt.Errorf("log publish event: %w", err)
	}

	if err := tx.Commit(); err != nil {
		return nil, fmt.Errorf("commit tx: %w", err)
	}
	return p, nil
}

func (r *postgresRepo) GetByID(ctx context.Context, id string) (*Post, error) {
	p := &Post{}
	err := r.db.QueryRowContext(ctx,
		`SELECT id, user_id, note_id, title, content, is_archived, published_at, created_at, updated_at, deleted_at
		 FROM posts WHERE id = $1 AND deleted_at IS NULL`,
		id,
	).Scan(&p.ID, &p.UserID, &p.NoteID, &p.Title, &p.Content, &p.IsArchived, &p.PublishedAt, &p.CreatedAt, &p.UpdatedAt, &p.DeletedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("get post: %w", err)
	}
	return p, nil
}

func (r *postgresRepo) List(ctx context.Context) ([]*Post, error) {
	rows, err := r.db.QueryContext(ctx,
		`SELECT id, user_id, note_id, title, content, is_archived, published_at, created_at, updated_at, deleted_at
		 FROM posts WHERE deleted_at IS NULL AND is_archived = FALSE ORDER BY published_at DESC`,
	)
	if err != nil {
		return nil, fmt.Errorf("list posts: %w", err)
	}
	defer rows.Close()

	var posts []*Post
	for rows.Next() {
		p := &Post{}
		if err := rows.Scan(&p.ID, &p.UserID, &p.NoteID, &p.Title, &p.Content, &p.IsArchived, &p.PublishedAt, &p.CreatedAt, &p.UpdatedAt, &p.DeletedAt); err != nil {
			return nil, fmt.Errorf("scan post: %w", err)
		}
		posts = append(posts, p)
	}
	if posts == nil {
		posts = []*Post{}
	}
	return posts, rows.Err()
}

// Archive sets is_archived = true; it does NOT modify post content (immutability preserved).
func (r *postgresRepo) Archive(ctx context.Context, id, userID string) (*Post, error) {
	p := &Post{}
	err := r.db.QueryRowContext(ctx,
		`UPDATE posts SET is_archived = TRUE, updated_at = NOW()
		 WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL AND is_archived = FALSE
		 RETURNING id, user_id, note_id, title, content, is_archived, published_at, created_at, updated_at, deleted_at`,
		id, userID,
	).Scan(&p.ID, &p.UserID, &p.NoteID, &p.Title, &p.Content, &p.IsArchived, &p.PublishedAt, &p.CreatedAt, &p.UpdatedAt, &p.DeletedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("archive post: %w", err)
	}
	return p, nil
}

func (r *postgresRepo) LogEvent(ctx context.Context, postID, userID, eventType string, metadata []byte) error {
	if metadata == nil {
		metadata = []byte("{}")
	}
	_, err := r.db.ExecContext(ctx,
		`INSERT INTO post_events (post_id, user_id, event_type, metadata) VALUES ($1, $2, $3, $4)`,
		postID, userID, eventType, metadata,
	)
	return err
}

// Sentinel errors for publish-path business logic.
var (
	ErrNoteNotFound    = fmt.Errorf("note not found")
	ErrAlreadyPublished = fmt.Errorf("note already published")
	ErrImportedNote    = fmt.Errorf("imported notes cannot be published")
)
