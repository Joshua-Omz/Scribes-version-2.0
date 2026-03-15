// Package users defines the User model and its repository.
package users

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// User represents a registered account.
type User struct {
	ID        string    `json:"id"`
	Username  string    `json:"username"`
	Email     string    `json:"email"`
	Password  string    `json:"-"` // never serialised
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// Repository is the data-access layer for users.
type Repository struct {
	db *pgxpool.Pool
}

// NewRepository creates a Repository backed by db.
func NewRepository(db *pgxpool.Pool) *Repository {
	return &Repository{db: db}
}

// Create inserts a new user and returns the persisted record.
func (r *Repository) Create(ctx context.Context, username, email, hashedPassword string) (*User, error) {
	const q = `
		INSERT INTO users (username, email, password)
		VALUES ($1, $2, $3)
		RETURNING id, username, email, created_at, updated_at`

	u := &User{}
	err := r.db.QueryRow(ctx, q, username, email, hashedPassword).
		Scan(&u.ID, &u.Username, &u.Email, &u.CreatedAt, &u.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("users.Create: %w", err)
	}
	return u, nil
}

// GetByEmail fetches a user including its hashed password (for auth).
func (r *Repository) GetByEmail(ctx context.Context, email string) (*User, error) {
	const q = `
		SELECT id, username, email, password, created_at, updated_at
		FROM users WHERE email = $1`

	u := &User{}
	err := r.db.QueryRow(ctx, q, email).
		Scan(&u.ID, &u.Username, &u.Email, &u.Password, &u.CreatedAt, &u.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("users.GetByEmail: %w", err)
	}
	return u, nil
}

// GetByID fetches a user by its primary key.
func (r *Repository) GetByID(ctx context.Context, id string) (*User, error) {
	const q = `
		SELECT id, username, email, created_at, updated_at
		FROM users WHERE id = $1`

	u := &User{}
	err := r.db.QueryRow(ctx, q, id).
		Scan(&u.ID, &u.Username, &u.Email, &u.CreatedAt, &u.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("users.GetByID: %w", err)
	}
	return u, nil
}
