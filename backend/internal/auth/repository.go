package auth

import (
	"context"
	"database/sql"
	"time"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

type User struct {
	ID          uuid.UUID `json:"id"`
	Handle      string    `json:"handle"`
	DisplayName string    `json:"display_name"`
	Email       string    `json:"email"`
	Bio         *string   `json:"bio,omitempty"`
	Role        string    `json:"role"`
	CreatedAt   time.Time `json:"created_at"`
}

func mapUser(dbUser generated.User) User {
	var bio *string
	if dbUser.Bio.Valid {
		b := dbUser.Bio.String
		bio = &b
	}
	return User{
		ID:          dbUser.ID,
		Handle:      dbUser.Handle,
		DisplayName: dbUser.DisplayName,
		Email:       dbUser.Email,
		Bio:         bio,
		Role:        string(dbUser.Role),
		CreatedAt:   dbUser.CreatedAt,
	}
}

type Repository struct {
	q *generated.Queries
}

func NewRepository(q *generated.Queries) *Repository {
	return &Repository{q: q}
}

func (r *Repository) CreateUser(ctx context.Context, handle, displayName, email, passwordHash string) (User, error) {
	dbUser, err := r.q.CreateUser(ctx, generated.CreateUserParams{
		Handle:       handle,
		DisplayName:  displayName,
		Email:        email,
		PasswordHash: passwordHash,
		Role:         generated.UserRoleStandard,
		Bio:          sql.NullString{},
	})
	if err != nil {
		return User{}, err
	}
	return mapUser(dbUser), nil
}

func (r *Repository) GetUserByEmail(ctx context.Context, email string) (User, string, error) {
	dbUser, err := r.q.GetUserByEmail(ctx, email)
	if err != nil {
		return User{}, "", err
	}
	return mapUser(dbUser), dbUser.PasswordHash, nil
}

func (r *Repository) GetUserByID(ctx context.Context, id uuid.UUID) (User, error) {
	dbUser, err := r.q.GetUserByID(ctx, id)
	if err != nil {
		return User{}, err
	}
	return mapUser(dbUser), nil
}

func (r *Repository) GetUserByHandle(ctx context.Context, handle string) (User, error) {
	dbUser, err := r.q.GetUserByHandle(ctx, handle)
	if err != nil {
		return User{}, err
	}
	return mapUser(dbUser), nil
}
