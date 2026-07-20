
package auth

import (
	"context"
	"database/sql"
	"time"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

type User struct {
	ID             uuid.UUID `json:"id"`
	Handle         string    `json:"handle"`
	DisplayName    string    `json:"display_name"`
	Email          string    `json:"email"`
	Bio            *string   `json:"bio,omitempty"`
	Role           string    `json:"role"`
	CreatedAt      time.Time `json:"created_at"`
	FollowersCount int       `json:"followers_count"`
	FollowingCount int       `json:"following_count"`
}

// Since CreateUser still returns generated.User, we need a separate map function for it
func mapCreatedUser(dbUser generated.User) User {
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
		// newly created users have 0 followers/following
		FollowersCount: 0,
		FollowingCount: 0,
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
	return mapCreatedUser(dbUser), nil
}

func (r *Repository) GetUserByEmail(ctx context.Context, email string) (User, string, error) {
	dbUser, err := r.q.GetUserByEmail(ctx, email)
	if err != nil {
		return User{}, "", err
	}
	var bio *string
	if dbUser.Bio.Valid {
		b := dbUser.Bio.String
		bio = &b
	}
	return User{
		ID:             dbUser.ID,
		Handle:         dbUser.Handle,
		DisplayName:    dbUser.DisplayName,
		Email:          dbUser.Email,
		Bio:            bio,
		Role:           string(dbUser.Role),
		CreatedAt:      dbUser.CreatedAt,
		FollowersCount: int(dbUser.FollowersCount),
		FollowingCount: int(dbUser.FollowingCount),
	}, dbUser.PasswordHash, nil
}

func (r *Repository) GetUserByID(ctx context.Context, id uuid.UUID) (User, error) {
	dbUser, err := r.q.GetUserByID(ctx, id)
	if err != nil {
		return User{}, err
	}
	var bio *string
	if dbUser.Bio.Valid {
		b := dbUser.Bio.String
		bio = &b
	}
	return User{
		ID:             dbUser.ID,
		Handle:         dbUser.Handle,
		DisplayName:    dbUser.DisplayName,
		Email:          dbUser.Email,
		Bio:            bio,
		Role:           string(dbUser.Role),
		CreatedAt:      dbUser.CreatedAt,
		FollowersCount: int(dbUser.FollowersCount),
		FollowingCount: int(dbUser.FollowingCount),
	}, nil
}

func (r *Repository) GetUserByHandle(ctx context.Context, handle string) (User, error) {
	dbUser, err := r.q.GetUserByHandle(ctx, handle)
	if err != nil {
		return User{}, err
	}
	var bio *string
	if dbUser.Bio.Valid {
		b := dbUser.Bio.String
		bio = &b
	}
	return User{
		ID:             dbUser.ID,
		Handle:         dbUser.Handle,
		DisplayName:    dbUser.DisplayName,
		Email:          dbUser.Email,
		Bio:            bio,
		Role:           string(dbUser.Role),
		CreatedAt:      dbUser.CreatedAt,
		FollowersCount: int(dbUser.FollowersCount),
		FollowingCount: int(dbUser.FollowingCount),
	}, nil
}

type PublicProfile struct {
	ID             uuid.UUID `json:"id"`
	Handle         string    `json:"handle"`
	DisplayName    string    `json:"display_name"`
	Bio            *string   `json:"bio,omitempty"`
	FollowersCount int       `json:"followers_count"`
	FollowingCount int       `json:"following_count"`
}

func (r *Repository) GetPublicProfile(ctx context.Context, id uuid.UUID) (PublicProfile, error) {
	row, err := r.q.GetPublicProfile(ctx, id)
	if err != nil {
		return PublicProfile{}, err
	}
	var bio *string
	if row.Bio.Valid {
		b := row.Bio.String
		bio = &b
	}
	return PublicProfile{
		ID:             row.ID,
		Handle:         row.Handle,
		DisplayName:    row.DisplayName,
		Bio:            bio,
		FollowersCount: int(row.FollowersCount),
		FollowingCount: int(row.FollowingCount),
	}, nil
}

type UserSearchResult struct {
	ID          uuid.UUID `json:"id"`
	Handle      string    `json:"handle"`
	DisplayName string    `json:"display_name"`
}

func (r *Repository) SearchUsersByHandle(ctx context.Context, query string) ([]UserSearchResult, error) {
	rows, err := r.q.SearchUsersByHandle(ctx, sql.NullString{String: query, Valid: query != ""})
	if err != nil {
		return nil, err
	}
	results := make([]UserSearchResult, len(rows))
	for i, row := range rows {
		results[i] = UserSearchResult{
			ID:          row.ID,
			Handle:      row.Handle,
			DisplayName: row.DisplayName,
		}
	}
	return results, nil
}
