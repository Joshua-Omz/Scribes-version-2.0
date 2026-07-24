package auth

import (
	"context"
	"errors"
	"regexp"
	"strings"
	"time"

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

	user, err := s.repo.CreateUser(ctx, input.Handle, input.DisplayName, input.Email, hash)
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
	// We pass an empty string for the ClientID to accept any audience for now,
	// since we don't have the ClientID yet. We can strict check it later.
	payload, err := idtoken.Validate(ctx, idTokenStr, "")
	if err != nil {
		return User{}, "", errors.New("invalid google token")
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

		user, err = s.repo.CreateUser(ctx, handle, name, email, dummyHash)
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

func (s *Service) SearchUsersByHandle(ctx context.Context, query string) ([]UserSearchResult, error) {
	return s.repo.SearchUsersByHandle(ctx, query)
}
