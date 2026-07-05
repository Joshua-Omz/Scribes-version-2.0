package auth

import (
	"context"
	"os"
	"testing"

	"scribes-api/test/testutil"
)

func TestAuthService(t *testing.T) {
	os.Setenv("DATABASE_URL", "postgres://scribes:password@localhost:5433/scribes_db?sslmode=disable")
	os.Setenv("JWT_SECRET", "test_secret")

	tdb := testutil.SetupDB(t)
	defer tdb.Teardown()

	repo := NewRepository(tdb.Queries)
	svc := NewService(repo, Config{
		JWTSecret:      "test_secret",
		JWTExpiryHours: 24,
		BcryptCost:     10,
		DummyHash:      "$2a$10$C8.XGzT3Q2yD7u/9X1Fq9.F/V2lX3e1Z1C/M1G1O1Y2K3J4E5R6t7", // just a valid bcrypt shape
	})

	ctx := context.Background()

	// 1. Register with valid input succeeds
	t.Run("Register Valid", func(t *testing.T) {
		_, _, err := svc.Register(ctx, RegisterInput{
			Email:       "test1@example.com",
			Handle:      "user1",
			DisplayName: "User One",
			Password:    "password123",
		})
		if err != nil {
			t.Fatalf("expected nil, got %v", err)
		}
	})

	// 2. Register with duplicate email returns ErrEmailTaken
	t.Run("Register Duplicate Email", func(t *testing.T) {
		_, _, err := svc.Register(ctx, RegisterInput{
			Email:       "test1@example.com",
			Handle:      "user1_other",
			DisplayName: "User One",
			Password:    "password123",
		})
		if err != ErrEmailTaken {
			t.Fatalf("expected ErrEmailTaken, got %v", err)
		}
	})

	// 3. Register with duplicate handle returns ErrHandleTaken
	t.Run("Register Duplicate Handle", func(t *testing.T) {
		_, _, err := svc.Register(ctx, RegisterInput{
			Email:       "test1_other@example.com",
			Handle:      "user1",
			DisplayName: "User One",
			Password:    "password123",
		})
		if err != ErrHandleTaken {
			t.Fatalf("expected ErrHandleTaken, got %v", err)
		}
	})

	// 4. Login with correct credentials succeeds
	t.Run("Login Success", func(t *testing.T) {
		_, token, err := svc.Login(ctx, LoginInput{
			Email:    "test1@example.com",
			Password: "password123",
		})
		if err != nil {
			t.Fatalf("expected nil, got %v", err)
		}
		if token == "" {
			t.Fatal("expected a token, got empty string")
		}
	})

	// 5. Login with wrong password returns ErrInvalidCredentials
	t.Run("Login Wrong Password", func(t *testing.T) {
		_, _, err := svc.Login(ctx, LoginInput{
			Email:    "test1@example.com",
			Password: "wrongpassword",
		})
		if err != ErrInvalidCredentials {
			t.Fatalf("expected ErrInvalidCredentials, got %v", err)
		}
	})

	// 6. Login with non-existent email returns ErrInvalidCredentials
	t.Run("Login Non-existent Email", func(t *testing.T) {
		_, _, err := svc.Login(ctx, LoginInput{
			Email:    "nonexistent@example.com",
			Password: "password123",
		})
		if err != ErrInvalidCredentials {
			t.Fatalf("expected ErrInvalidCredentials, got %v", err)
		}
	})
}
