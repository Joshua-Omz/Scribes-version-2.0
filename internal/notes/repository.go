package notes

import (
	"context"
	"database/sql"
	"fmt"
)

// Repository defines note data access.
type Repository interface {
	Create(ctx context.Context, userID, title string, content []byte) (*Note, error)
	GetByID(ctx context.Context, id, userID string) (*Note, error)
	List(ctx context.Context, userID string) ([]*Note, error)
	Update(ctx context.Context, id, userID string, title *string, content []byte) (*Note, error)
	Delete(ctx context.Context, id, userID string) error
}

type postgresRepo struct {
	db *sql.DB
}

// NewRepository creates a PostgreSQL-backed note repository.
func NewRepository(db *sql.DB) Repository {
	return &postgresRepo{db: db}
}

func (r *postgresRepo) Create(ctx context.Context, userID, title string, content []byte) (*Note, error) {
	if content == nil {
		content = []byte("{}")
	}
	n := &Note{}
	err := r.db.QueryRowContext(ctx,
		`INSERT INTO notes (user_id, title, content)
		 VALUES ($1, $2, $3)
		 RETURNING id, user_id, title, content, is_published, is_imported, created_at, updated_at, deleted_at`,
		userID, title, content,
	).Scan(&n.ID, &n.UserID, &n.Title, &n.Content, &n.IsPublished, &n.IsImported, &n.CreatedAt, &n.UpdatedAt, &n.DeletedAt)
	if err != nil {
		return nil, fmt.Errorf("create note: %w", err)
	}
	return n, nil
}

func (r *postgresRepo) GetByID(ctx context.Context, id, userID string) (*Note, error) {
	n := &Note{}
	err := r.db.QueryRowContext(ctx,
		`SELECT id, user_id, title, content, is_published, is_imported, created_at, updated_at, deleted_at
		 FROM notes WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL`,
		id, userID,
	).Scan(&n.ID, &n.UserID, &n.Title, &n.Content, &n.IsPublished, &n.IsImported, &n.CreatedAt, &n.UpdatedAt, &n.DeletedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("get note: %w", err)
	}
	return n, nil
}

func (r *postgresRepo) List(ctx context.Context, userID string) ([]*Note, error) {
	rows, err := r.db.QueryContext(ctx,
		`SELECT id, user_id, title, content, is_published, is_imported, created_at, updated_at, deleted_at
		 FROM notes WHERE user_id = $1 AND deleted_at IS NULL ORDER BY created_at DESC`,
		userID,
	)
	if err != nil {
		return nil, fmt.Errorf("list notes: %w", err)
	}
	defer rows.Close()

	var notes []*Note
	for rows.Next() {
		n := &Note{}
		if err := rows.Scan(&n.ID, &n.UserID, &n.Title, &n.Content, &n.IsPublished, &n.IsImported, &n.CreatedAt, &n.UpdatedAt, &n.DeletedAt); err != nil {
			return nil, fmt.Errorf("scan note: %w", err)
		}
		notes = append(notes, n)
	}
	if notes == nil {
		notes = []*Note{}
	}
	return notes, rows.Err()
}

func (r *postgresRepo) Update(ctx context.Context, id, userID string, title *string, content []byte) (*Note, error) {
	n := &Note{}
	err := r.db.QueryRowContext(ctx,
		`UPDATE notes
		 SET title       = COALESCE($3, title),
		     content     = COALESCE($4, content),
		     updated_at  = NOW()
		 WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL
		   AND is_published = FALSE AND is_imported = FALSE
		 RETURNING id, user_id, title, content, is_published, is_imported, created_at, updated_at, deleted_at`,
		id, userID, title, content,
	).Scan(&n.ID, &n.UserID, &n.Title, &n.Content, &n.IsPublished, &n.IsImported, &n.CreatedAt, &n.UpdatedAt, &n.DeletedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("update note: %w", err)
	}
	return n, nil
}

func (r *postgresRepo) Delete(ctx context.Context, id, userID string) error {
	res, err := r.db.ExecContext(ctx,
		`UPDATE notes SET deleted_at = NOW() WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL`,
		id, userID,
	)
	if err != nil {
		return fmt.Errorf("delete note: %w", err)
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		return sql.ErrNoRows
	}
	return nil
}
