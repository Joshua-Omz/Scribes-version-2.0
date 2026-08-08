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
	AvatarUrl      *string   `json:"avatar_url,omitempty"`
	Role           string    `json:"role"`
	IsChurch       bool      `json:"is_church"`
	SelectedTags   []string  `json:"selected_tags"`
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
	var avatar *string
	if dbUser.AvatarUrl.Valid {
		a := dbUser.AvatarUrl.String
		avatar = &a
	}
	return User{
		ID:           dbUser.ID,
		Handle:       dbUser.Handle,
		DisplayName:  dbUser.DisplayName,
		Email:        dbUser.Email,
		Bio:          bio,
		AvatarUrl:    avatar,
		Role:         string(dbUser.Role),
		IsChurch:     dbUser.IsChurch,
		SelectedTags: []string{}, // Fresh user has no tags
		CreatedAt:    dbUser.CreatedAt,
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

func (r *Repository) CreateUser(ctx context.Context, handle, displayName, email, passwordHash string, isChurch bool) (User, error) {
	dbUser, err := r.q.CreateUser(ctx, generated.CreateUserParams{
		Handle:       handle,
		DisplayName:  displayName,
		Email:        email,
		PasswordHash: passwordHash,
		Role:         generated.UserRoleStandard,
		Bio:          sql.NullString{},
		IsChurch:     isChurch,
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
	var avatar *string
	if dbUser.AvatarUrl.Valid {
		a := dbUser.AvatarUrl.String
		avatar = &a
	}
	return User{
		ID:             dbUser.ID,
		Handle:         dbUser.Handle,
		DisplayName:    dbUser.DisplayName,
		Email:          dbUser.Email,
		Bio:            bio,
		AvatarUrl:      avatar,
		Role:           string(dbUser.Role),
		IsChurch:       dbUser.IsChurch,
		SelectedTags:   dbUser.SelectedTags,
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
	var avatar *string
	if dbUser.AvatarUrl.Valid {
		a := dbUser.AvatarUrl.String
		avatar = &a
	}
	return User{
		ID:             dbUser.ID,
		Handle:         dbUser.Handle,
		DisplayName:    dbUser.DisplayName,
		Email:          dbUser.Email,
		Bio:            bio,
		AvatarUrl:      avatar,
		Role:           string(dbUser.Role),
		IsChurch:       dbUser.IsChurch,
		SelectedTags:   dbUser.SelectedTags,
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
	var avatar *string
	if dbUser.AvatarUrl.Valid {
		a := dbUser.AvatarUrl.String
		avatar = &a
	}
	return User{
		ID:             dbUser.ID,
		Handle:         dbUser.Handle,
		DisplayName:    dbUser.DisplayName,
		Email:          dbUser.Email,
		Bio:            bio,
		AvatarUrl:      avatar,
		Role:           string(dbUser.Role),
		IsChurch:       dbUser.IsChurch,
		SelectedTags:   dbUser.SelectedTags,
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
	AvatarUrl      *string   `json:"avatar_url,omitempty"`
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
	var avatar *string
	if row.AvatarUrl.Valid {
		a := row.AvatarUrl.String
		avatar = &a
	}
	return PublicProfile{
		ID:             row.ID,
		Handle:         row.Handle,
		DisplayName:    row.DisplayName,
		Bio:            bio,
		AvatarUrl:      avatar,
		FollowersCount: int(row.FollowersCount),
		FollowingCount: int(row.FollowingCount),
	}, nil
}

type UserSearchResult struct {
	ID             uuid.UUID `json:"id"`
	Handle         string    `json:"handle"`
	DisplayName    string    `json:"display_name"`
	Bio            *string   `json:"bio,omitempty"`
	AvatarUrl      *string   `json:"avatar_url,omitempty"`
	FollowersCount int       `json:"followers_count"`
	FollowingCount int       `json:"following_count"`
}

func (r *Repository) SearchUsers(ctx context.Context, query string) ([]UserSearchResult, error) {
	rows, err := r.q.SearchUsers(ctx, sql.NullString{String: query, Valid: query != ""})
	if err != nil {
		return nil, err
	}
	results := make([]UserSearchResult, len(rows))
	for i, row := range rows {
		var bio *string
		if row.Bio.Valid {
			b := row.Bio.String
			bio = &b
		}
		var avatar *string
		if row.AvatarUrl.Valid {
			a := row.AvatarUrl.String
			avatar = &a
		}
		results[i] = UserSearchResult{
			ID:             row.ID,
			Handle:         row.Handle,
			DisplayName:    row.DisplayName,
			Bio:            bio,
			AvatarUrl:      avatar,
			FollowersCount: int(row.FollowersCount),
			FollowingCount: int(row.FollowingCount),
		}
	}
	return results, nil
}

func (r *Repository) GetSuggestedUsers(ctx context.Context, userID uuid.UUID, limit int32) ([]UserSearchResult, error) {
	rows, err := r.q.GetSuggestedUsers(ctx, generated.GetSuggestedUsersParams{
		ID:    userID,
		Limit: limit,
	})
	if err != nil {
		return nil, err
	}
	results := make([]UserSearchResult, len(rows))
	for i, row := range rows {
		var bio *string
		if row.Bio.Valid {
			b := row.Bio.String
			bio = &b
		}
		var avatar *string
		if row.AvatarUrl.Valid {
			a := row.AvatarUrl.String
			avatar = &a
		}
		results[i] = UserSearchResult{
			ID:             row.ID,
			Handle:         row.Handle,
			DisplayName:    row.DisplayName,
			Bio:            bio,
			AvatarUrl:      avatar,
			FollowersCount: int(row.FollowersCount),
			FollowingCount: int(row.FollowingCount),
		}
	}
	return results, nil
}

func (r *Repository) UpdateUserProfile(ctx context.Context, id uuid.UUID, handle, displayName string, bio *string, isChurch bool, avatarUrl *string) (User, error) {
	b := sql.NullString{}
	if bio != nil {
		b.String = *bio
		b.Valid = true
	}
	a := sql.NullString{}
	if avatarUrl != nil {
		a.String = *avatarUrl
		a.Valid = true
	}
	_, err := r.q.UpdateUserProfile(ctx, generated.UpdateUserProfileParams{
		ID:          id,
		Handle:      handle,
		DisplayName: displayName,
		Bio:         b,
		IsChurch:    isChurch,
		AvatarUrl:   a,
	})
	if err != nil {
		return User{}, err
	}
	return r.GetUserByID(ctx, id)
}

func (r *Repository) UpdateUserEmail(ctx context.Context, id uuid.UUID, email string) error {
	return r.q.UpdateUserEmail(ctx, generated.UpdateUserEmailParams{
		ID:    id,
		Email: email,
	})
}

func (r *Repository) UpdateUserPassword(ctx context.Context, id uuid.UUID, passwordHash string) error {
	return r.q.UpdateUserPassword(ctx, generated.UpdateUserPasswordParams{
		ID:           id,
		PasswordHash: passwordHash,
	})
}

func (r *Repository) UpdateUserTags(ctx context.Context, id uuid.UUID, tags []uuid.UUID) (User, error) {
	err := r.q.ClearUserTags(ctx, id)
	if err != nil {
		return User{}, err
	}

	for _, tagID := range tags {
		err = r.q.AddUserTag(ctx, generated.AddUserTagParams{
			UserID: id,
			TagID:  tagID,
		})
		if err != nil {
			return User{}, err
		}
	}
	return r.GetUserByID(ctx, id)
}

func (r *Repository) CreateOrGetTagIDs(ctx context.Context, tags []string) ([]uuid.UUID, error) {
	var tagUUIDs []uuid.UUID
	for _, t := range tags {
		tagID, err := r.q.UpsertTag(ctx, generated.UpsertTagParams{
			PName:        t, // simplistic for now, should normalize
			PDisplayName: t,
		})
		if err != nil {
			return nil, err
		}
		tagUUIDs = append(tagUUIDs, tagID)
	}
	return tagUUIDs, nil
}

func (r *Repository) GetNotificationPreferences(ctx context.Context, userID uuid.UUID) (generated.NotificationPreference, error) {
	return r.q.GetNotificationPreferences(ctx, userID)
}

func (r *Repository) UpsertNotificationPreferences(ctx context.Context, arg generated.UpsertNotificationPreferencesParams) (generated.NotificationPreference, error) {
	return r.q.UpsertNotificationPreferences(ctx, arg)
}
