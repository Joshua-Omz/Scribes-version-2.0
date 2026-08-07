package auth

import (
	"context"
	"errors"
	"fmt"
	"regexp"
	"strings"
	"time"

	"scribes-api/internal/db/generated"
	"scribes-api/pkg/password"
	"scribes-api/pkg/token"

	"github.com/google/uuid"
	"github.com/lib/pq"
	"google.golang.org/api/idtoken"
)

var (
	ErrEmailTaken         = errors.New("email already taken")
	ErrHandleTaken        = errors.New("handle already taken")
	ErrInvalidCredentials = errors.New("invalid email or password")
)

type Config struct {
	JWTSecret      string
	JWTExpiryHours int
	BcryptCost     int
	DummyHash      string
}

type Service struct {
	repo *Repository
	cfg  Config
}

func NewService(repo *Repository, cfg Config) *Service {
	return &Service{
		repo: repo,
		cfg:  cfg,
	}
}

func (s *Service) GetUserByID(ctx context.Context, id uuid.UUID) (User, error) {
	return s.repo.GetUserByID(ctx, id)
}

type RegisterInput struct {
	Email       string `json:"email"`
	Handle      string `json:"handle"`
	DisplayName string `json:"display_name"`
	Password    string `json:"password"`
	IsChurch    bool   `json:"is_church"`
}

func (s *Service) Register(ctx context.Context, input RegisterInput) (User, string, error) {
	input.Email = strings.TrimSpace(strings.ToLower(input.Email))
	input.Handle = strings.TrimSpace(strings.ToLower(input.Handle))

	if len(input.Password) < 8 {
		return User{}, "", errors.New("password must be at least 8 characters")
	}
	if !regexp.MustCompile(`^[a-z0-9_]+$`).MatchString(input.Handle) {
		return User{}, "", errors.New("handle must be alphanumeric and underscores only")
	}
	if !strings.Contains(input.Email, "@") {
		return User{}, "", errors.New("invalid email format")
	}

	hash, err := password.Hash(input.Password, s.cfg.BcryptCost)
	if err != nil {
		return User{}, "", err
	}

	user, err := s.repo.CreateUser(ctx, input.Handle, input.DisplayName, input.Email, hash, input.IsChurch)
	if err != nil {
		if pqErr, ok := err.(*pq.Error); ok && pqErr.Code == "23505" {
			if strings.Contains(pqErr.Message, "users_email_key") {
				return User{}, "", ErrEmailTaken
			}
			if strings.Contains(pqErr.Message, "users_handle_key") {
				return User{}, "", ErrHandleTaken
			}
		}
		return User{}, "", err
	}

	tok, err := token.Sign(user.ID.String(), user.Role, s.cfg.JWTSecret, time.Duration(s.cfg.JWTExpiryHours)*time.Hour)
	if err != nil {
		return User{}, "", err
	}

	return user, tok, nil
}

type LoginInput struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

func (s *Service) Login(ctx context.Context, input LoginInput) (User, string, error) {
	input.Email = strings.TrimSpace(strings.ToLower(input.Email))

	user, hash, err := s.repo.GetUserByEmail(ctx, input.Email)
	if err != nil {
		_ = password.Compare(s.cfg.DummyHash, input.Password)
		return User{}, "", ErrInvalidCredentials
	}

	err = password.Compare(hash, input.Password)
	if err != nil {
		return User{}, "", ErrInvalidCredentials
	}

	tok, err := token.Sign(user.ID.String(), user.Role, s.cfg.JWTSecret, time.Duration(s.cfg.JWTExpiryHours)*time.Hour)
	if err != nil {
		return User{}, "", err
	}

	return user, tok, nil
}

func (s *Service) LoginWithGoogle(ctx context.Context, idTokenStr string) (User, string, error) {
	// Validate the ID token using the google api library
	payload, err := idtoken.Validate(ctx, idTokenStr, "773705773175-i6dnlubf2aqcae5j4ltkmlkssf0nnkhq.apps.googleusercontent.com")
	if err != nil {
		return User{}, "", fmt.Errorf("google token validation failed: %v", err)
	}

	email, ok := payload.Claims["email"].(string)
	if !ok || email == "" {
		return User{}, "", errors.New("google token missing email")
	}

	email = strings.TrimSpace(strings.ToLower(email))

	// Check if user exists
	user, _, err := s.repo.GetUserByEmail(ctx, email)
	if err != nil {
		// User doesn't exist, register them
		name, _ := payload.Claims["name"].(string)
		if name == "" {
			name = "Scribe"
		}

		// Generate random handle since Google doesn't provide one
		handle := "user_" + uuid.New().String()[:8]

		// Generate a random dummy password hash for oauth users
		dummyHash, _ := password.Hash(uuid.NewString(), s.cfg.BcryptCost)

		user, err = s.repo.CreateUser(ctx, handle, name, email, dummyHash, false)
		if err != nil {
			return User{}, "", err
		}
	}

	tok, err := token.Sign(user.ID.String(), user.Role, s.cfg.JWTSecret, time.Duration(s.cfg.JWTExpiryHours)*time.Hour)
	if err != nil {
		return User{}, "", err
	}

	return user, tok, nil
}

func (s *Service) GetPublicProfile(ctx context.Context, id uuid.UUID) (PublicProfile, error) {
	return s.repo.GetPublicProfile(ctx, id)
}

func (s *Service) SearchUsers(ctx context.Context, query string) ([]UserSearchResult, error) {
	return s.repo.SearchUsers(ctx, query)
}

func (s *Service) GetSuggestedUsers(ctx context.Context, userID uuid.UUID, limit int32) ([]UserSearchResult, error) {
	if limit <= 0 || limit > 50 {
		limit = 10
	}
	return s.repo.GetSuggestedUsers(ctx, userID, limit)
}

type UpdateProfileInput struct {
	Handle      string  `json:"handle"`
	DisplayName string  `json:"display_name"`
	Bio         *string `json:"bio"`
	IsChurch    bool    `json:"is_church"`
	AvatarUrl   *string `json:"avatar_url"`
}

func (s *Service) UpdateProfile(ctx context.Context, id uuid.UUID, input UpdateProfileInput) (User, error) {
	input.Handle = strings.TrimSpace(strings.ToLower(input.Handle))
	if !regexp.MustCompile(`^[a-z0-9_]+$`).MatchString(input.Handle) {
		return User{}, errors.New("handle must be alphanumeric and underscores only")
	}

	user, err := s.repo.UpdateUserProfile(ctx, id, input.Handle, input.DisplayName, input.Bio, input.IsChurch, input.AvatarUrl)
	if err != nil {
		if pqErr, ok := err.(*pq.Error); ok && pqErr.Code == "23505" {
			if strings.Contains(pqErr.Message, "users_handle_key") {
				return User{}, ErrHandleTaken
			}
		}
		return User{}, err
	}
	return user, nil
}

type UpdateEmailInput struct {
	NewEmail        string `json:"new_email"`
	CurrentPassword string `json:"current_password"`
}

func (s *Service) UpdateEmail(ctx context.Context, id uuid.UUID, input UpdateEmailInput) error {
	input.NewEmail = strings.TrimSpace(strings.ToLower(input.NewEmail))
	if !strings.Contains(input.NewEmail, "@") {
		return errors.New("invalid email format")
	}

	currentHash, err := s.repo.q.GetUserPasswordHash(ctx, id)
	if err != nil {
		return err
	}

	if err := password.Compare(currentHash, input.CurrentPassword); err != nil {
		return ErrInvalidCredentials
	}

	return s.repo.UpdateUserEmail(ctx, id, input.NewEmail)
}

type UpdatePasswordInput struct {
	CurrentPassword string `json:"current_password"`
	NewPassword     string `json:"new_password"`
}

func (s *Service) UpdatePassword(ctx context.Context, id uuid.UUID, input UpdatePasswordInput) error {
	if len(input.NewPassword) < 8 {
		return errors.New("password must be at least 8 characters")
	}

	currentHash, err := s.repo.q.GetUserPasswordHash(ctx, id)
	if err != nil {
		return err
	}

	if err := password.Compare(currentHash, input.CurrentPassword); err != nil {
		return ErrInvalidCredentials
	}

	hash, err := password.Hash(input.NewPassword, s.cfg.BcryptCost)
	if err != nil {
		return err
	}

	return s.repo.UpdateUserPassword(ctx, id, hash)
}

type UpdateTagsInput struct {
	Tags []string `json:"tags"`
}

func (s *Service) UpdateTags(ctx context.Context, id uuid.UUID, tags []string) (User, error) {
	if len(tags) > 7 {
		return User{}, errors.New("maximum 7 tags allowed")
	}

	// Create or get tags by name and get their UUIDs
	tagUUIDs, err := s.repo.CreateOrGetTagIDs(ctx, tags)
	if err != nil {
		return User{}, err
	}

	return s.repo.UpdateUserTags(ctx, id, tagUUIDs)
}

func (s *Service) GetNotificationPreferences(ctx context.Context, userID uuid.UUID) (generated.NotificationPreference, error) {
	prefs, err := s.repo.GetNotificationPreferences(ctx, userID)
	if err != nil {
		// If not found, return defaults (true for all)
		if err.Error() == "sql: no rows in result set" {
			return generated.NotificationPreference{
				UserID:            userID,
				PushEnabled:       true,
				EmailEnabled:      true,
				DmAlerts:          true,
				NewFollowerAlerts: true,
			}, nil
		}
		return generated.NotificationPreference{}, err
	}
	return prefs, nil
}

type UpdateNotificationPreferencesInput struct {
	PushEnabled       bool `json:"push_enabled"`
	EmailEnabled      bool `json:"email_enabled"`
	DmAlerts          bool `json:"dm_alerts"`
	NewFollowerAlerts bool `json:"new_follower_alerts"`
}

func (s *Service) UpdateNotificationPreferences(ctx context.Context, userID uuid.UUID, input UpdateNotificationPreferencesInput) (generated.NotificationPreference, error) {
	return s.repo.UpsertNotificationPreferences(ctx, generated.UpsertNotificationPreferencesParams{
		UserID:            userID,
		PushEnabled:       input.PushEnabled,
		EmailEnabled:      input.EmailEnabled,
		DmAlerts:          input.DmAlerts,
		NewFollowerAlerts: input.NewFollowerAlerts,
	})
}
