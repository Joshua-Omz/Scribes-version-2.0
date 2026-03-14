package interactions

import (
	"context"
	"database/sql"
	"fmt"
)

// Repository defines interaction data access.
type Repository interface {
	AddComment(ctx context.Context, postID, userID, content string) (*Comment, error)
	ListComments(ctx context.Context, postID string) ([]*Comment, error)
	ToggleReaction(ctx context.Context, postID, userID, reactionType string) (added bool, err error)
	ToggleBookmark(ctx context.Context, postID, userID string) (added bool, err error)
	ImportPost(ctx context.Context, postID, userID string) (*Import, error)
}

type postgresRepo struct {
	db *sql.DB
}

// NewRepository creates a PostgreSQL-backed interactions repository.
func NewRepository(db *sql.DB) Repository {
	return &postgresRepo{db: db}
}

func (r *postgresRepo) AddComment(ctx context.Context, postID, userID, content string) (*Comment, error) {
	// Verify the post exists.
	var exists bool
	if err := r.db.QueryRowContext(ctx,
		`SELECT EXISTS(SELECT 1 FROM posts WHERE id = $1 AND deleted_at IS NULL)`, postID,
	).Scan(&exists); err != nil {
		return nil, fmt.Errorf("check post exists: %w", err)
	}
	if !exists {
		return nil, ErrPostNotFound
	}

	c := &Comment{}
	err := r.db.QueryRowContext(ctx,
		`INSERT INTO comments (post_id, user_id, content)
		 VALUES ($1, $2, $3)
		 RETURNING id, post_id, user_id, content, created_at, updated_at, deleted_at`,
		postID, userID, content,
	).Scan(&c.ID, &c.PostID, &c.UserID, &c.Content, &c.CreatedAt, &c.UpdatedAt, &c.DeletedAt)
	if err != nil {
		return nil, fmt.Errorf("insert comment: %w", err)
	}
	return c, nil
}

func (r *postgresRepo) ListComments(ctx context.Context, postID string) ([]*Comment, error) {
	rows, err := r.db.QueryContext(ctx,
		`SELECT id, post_id, user_id, content, created_at, updated_at, deleted_at
		 FROM comments WHERE post_id = $1 AND deleted_at IS NULL ORDER BY created_at ASC`,
		postID,
	)
	if err != nil {
		return nil, fmt.Errorf("list comments: %w", err)
	}
	defer rows.Close()

	var comments []*Comment
	for rows.Next() {
		c := &Comment{}
		if err := rows.Scan(&c.ID, &c.PostID, &c.UserID, &c.Content, &c.CreatedAt, &c.UpdatedAt, &c.DeletedAt); err != nil {
			return nil, fmt.Errorf("scan comment: %w", err)
		}
		comments = append(comments, c)
	}
	if comments == nil {
		comments = []*Comment{}
	}
	return comments, rows.Err()
}

// ToggleReaction adds the reaction if it doesn't exist, removes it if it does.
func (r *postgresRepo) ToggleReaction(ctx context.Context, postID, userID, reactionType string) (bool, error) {
	// Try to delete first (toggle off).
	res, err := r.db.ExecContext(ctx,
		`DELETE FROM reactions WHERE post_id = $1 AND user_id = $2 AND reaction_type = $3`,
		postID, userID, reactionType,
	)
	if err != nil {
		return false, fmt.Errorf("delete reaction: %w", err)
	}
	if n, _ := res.RowsAffected(); n > 0 {
		return false, nil // removed
	}
	// Not found → insert.
	_, err = r.db.ExecContext(ctx,
		`INSERT INTO reactions (post_id, user_id, reaction_type) VALUES ($1, $2, $3)`,
		postID, userID, reactionType,
	)
	if err != nil {
		return false, fmt.Errorf("insert reaction: %w", err)
	}
	return true, nil // added
}

// ToggleBookmark adds or removes a bookmark.
func (r *postgresRepo) ToggleBookmark(ctx context.Context, postID, userID string) (bool, error) {
	res, err := r.db.ExecContext(ctx,
		`DELETE FROM bookmarks WHERE post_id = $1 AND user_id = $2`,
		postID, userID,
	)
	if err != nil {
		return false, fmt.Errorf("delete bookmark: %w", err)
	}
	if n, _ := res.RowsAffected(); n > 0 {
		return false, nil
	}
	_, err = r.db.ExecContext(ctx,
		`INSERT INTO bookmarks (post_id, user_id) VALUES ($1, $2)`,
		postID, userID,
	)
	if err != nil {
		return false, fmt.Errorf("insert bookmark: %w", err)
	}
	return true, nil
}

// ImportPost creates a read-only note copy of the post and records the import.
func (r *postgresRepo) ImportPost(ctx context.Context, postID, userID string) (*Import, error) {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return nil, fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback() //nolint:errcheck

	// Check for existing import.
	var exists bool
	if err := tx.QueryRowContext(ctx,
		`SELECT EXISTS(SELECT 1 FROM imports WHERE post_id = $1 AND user_id = $2)`, postID, userID,
	).Scan(&exists); err != nil {
		return nil, fmt.Errorf("check import exists: %w", err)
	}
	if exists {
		return nil, ErrAlreadyImported
	}

	// Fetch post content.
	var title string
	var content []byte
	err = tx.QueryRowContext(ctx,
		`SELECT title, content FROM posts WHERE id = $1 AND deleted_at IS NULL`, postID,
	).Scan(&title, &content)
	if err == sql.ErrNoRows {
		return nil, ErrPostNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("fetch post: %w", err)
	}

	// Create a read-only imported note.
	var noteID string
	if err := tx.QueryRowContext(ctx,
		`INSERT INTO notes (user_id, title, content, is_imported)
		 VALUES ($1, $2, $3, TRUE)
		 RETURNING id`,
		userID, title, content,
	).Scan(&noteID); err != nil {
		return nil, fmt.Errorf("create imported note: %w", err)
	}

	// Record the import.
	imp := &Import{}
	err = tx.QueryRowContext(ctx,
		`INSERT INTO imports (post_id, user_id, note_id) VALUES ($1, $2, $3)
		 RETURNING id, post_id, user_id, note_id, created_at, updated_at`,
		postID, userID, noteID,
	).Scan(&imp.ID, &imp.PostID, &imp.UserID, &imp.NoteID, &imp.CreatedAt, &imp.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("insert import: %w", err)
	}

	if err := tx.Commit(); err != nil {
		return nil, fmt.Errorf("commit tx: %w", err)
	}
	return imp, nil
}

var (
	ErrPostNotFound    = fmt.Errorf("post not found")
	ErrAlreadyImported = fmt.Errorf("post already imported")
)
