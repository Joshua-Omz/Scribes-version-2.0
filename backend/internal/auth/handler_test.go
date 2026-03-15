package auth

import (
	"strings"
	"testing"

	"github.com/Joshua-Omz/scribes/internal/users"
)

// ── hashPassword ──────────────────────────────────────────────────────────────

func TestHashPassword_Format(t *testing.T) {
	hash, err := hashPassword("mysecret")
	if err != nil {
		t.Fatalf("hashPassword: %v", err)
	}
	parts := strings.SplitN(hash, ":", 2)
	if len(parts) != 2 {
		t.Fatalf("expected <salt>:<hash> format, got %q", hash)
	}
	if parts[0] == "" || parts[1] == "" {
		t.Errorf("salt or hash component is empty in %q", hash)
	}
}

func TestHashPassword_Unique(t *testing.T) {
	h1, err := hashPassword("password123")
	if err != nil {
		t.Fatalf("first hashPassword: %v", err)
	}
	h2, err := hashPassword("password123")
	if err != nil {
		t.Fatalf("second hashPassword: %v", err)
	}
	if h1 == h2 {
		t.Error("expected different hashes for the same password (random salts must differ)")
	}
}

func TestHashPassword_EmptyPassword(t *testing.T) {
	_, err := hashPassword("")
	if err == nil {
		t.Error("expected an error for an empty password, got nil")
	}
}

// ── verifyPassword ────────────────────────────────────────────────────────────

func TestVerifyPassword_Correct(t *testing.T) {
	pw := "correct-horse-battery-staple"
	stored, err := hashPassword(pw)
	if err != nil {
		t.Fatalf("hashPassword: %v", err)
	}
	if !verifyPassword(pw, stored) {
		t.Error("expected verifyPassword to return true for the correct password")
	}
}

func TestVerifyPassword_Wrong(t *testing.T) {
	stored, err := hashPassword("real-password")
	if err != nil {
		t.Fatalf("hashPassword: %v", err)
	}
	if verifyPassword("wrong-password", stored) {
		t.Error("expected verifyPassword to return false for a wrong password")
	}
}

func TestVerifyPassword_Malformed(t *testing.T) {
	cases := []string{
		"",
		"nocolon",
		"ZZ:ZZ",   // valid separator but invalid hex characters
		":ababab", // empty salt
		"ababab:", // empty hash
	}
	for _, c := range cases {
		if verifyPassword("any", c) {
			t.Errorf("expected false for malformed stored value %q", c)
		}
	}
}

// ── generateToken ─────────────────────────────────────────────────────────────

func TestGenerateToken_Valid(t *testing.T) {
	h := NewHandler(nil, "test-jwt-secret")
	u := &users.User{
		ID:       "user-abc",
		Username: "testuser",
	}
	token, err := h.generateToken(u)
	if err != nil {
		t.Fatalf("generateToken: %v", err)
	}
	if token == "" {
		t.Fatal("expected a non-empty token")
	}
	// A compact JWT always has exactly three dot-separated parts.
	parts := strings.Split(token, ".")
	if len(parts) != 3 {
		t.Errorf("expected JWT with 3 parts (header.payload.sig), got %d", len(parts))
	}
}

func TestGenerateToken_DifferentUsers(t *testing.T) {
	h := NewHandler(nil, "test-jwt-secret")
	u1 := &users.User{ID: "user-1", Username: "alice"}
	u2 := &users.User{ID: "user-2", Username: "bob"}

	t1, err := h.generateToken(u1)
	if err != nil {
		t.Fatalf("generateToken u1: %v", err)
	}
	t2, err := h.generateToken(u2)
	if err != nil {
		t.Fatalf("generateToken u2: %v", err)
	}
	if t1 == t2 {
		t.Error("expected different tokens for different users")
	}
}
