package users

import (
	"context"
	"database/sql"
	"fmt"
)

// Repository defines user data access.
type Repository interface {
	GetByID(ctx context.Context, id string) (*User, error)
}

type postgresRepo struct {
	db *sql.DB
}

// NewRepository creates a PostgreSQL-backed user repository.
func NewRepository(db *sql.DB) Repository {
	return &postgresRepo{db: db}
}

func (r *postgresRepo) GetByID(ctx context.Context, id string) (*User, error) {
	u := &User{}
	err := r.db.QueryRowContext(ctx,
		`SELECT id, email, username, display_name, bio, created_at, updated_at, deleted_at
		 FROM users WHERE id = $1 AND deleted_at IS NULL`,
		id,
	).Scan(&u.ID, &u.Email, &u.Username, &u.DisplayName, &u.Bio, &u.CreatedAt, &u.UpdatedAt, &u.DeletedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("get user by id: %w", err)
	}
	return u, nil
}
