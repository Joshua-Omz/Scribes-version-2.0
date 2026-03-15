package middleware_test

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"

	mw "github.com/Joshua-Omz/scribes/pkg/middleware"
)

const testSecret = "test-secret-key"

// makeToken creates a signed HS256 JWT for use in tests.
func makeToken(userID, username, secret string, expiry time.Time) string {
	claims := mw.Claims{
		UserID:   userID,
		Username: username,
		RegisteredClaims: jwt.RegisteredClaims{
			Subject:   userID,
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			ExpiresAt: jwt.NewNumericDate(expiry),
		},
	}
	tok := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, _ := tok.SignedString([]byte(secret))
	return signed
}

// ── Authenticate ──────────────────────────────────────────────────────────────

func TestAuthenticate_MissingHeader(t *testing.T) {
	handler := mw.Authenticate(testSecret)(okHandler())
	rec := doRequest(handler, "")
	expectStatus(t, rec, http.StatusUnauthorized)
}

func TestAuthenticate_NonBearerScheme(t *testing.T) {
	handler := mw.Authenticate(testSecret)(okHandler())
	rec := doRequest(handler, "Basic dXNlcjpwYXNz")
	expectStatus(t, rec, http.StatusUnauthorized)
}

func TestAuthenticate_InvalidToken(t *testing.T) {
	handler := mw.Authenticate(testSecret)(okHandler())
	rec := doRequest(handler, "Bearer not.a.valid.jwt")
	expectStatus(t, rec, http.StatusUnauthorized)
}

func TestAuthenticate_ExpiredToken(t *testing.T) {
	tok := makeToken("u1", "alice", testSecret, time.Now().Add(-time.Hour))
	handler := mw.Authenticate(testSecret)(okHandler())
	rec := doRequest(handler, fmt.Sprintf("Bearer %s", tok))
	expectStatus(t, rec, http.StatusUnauthorized)
}

func TestAuthenticate_WrongSecret(t *testing.T) {
	tok := makeToken("u1", "alice", "different-secret", time.Now().Add(time.Hour))
	handler := mw.Authenticate(testSecret)(okHandler())
	rec := doRequest(handler, fmt.Sprintf("Bearer %s", tok))
	expectStatus(t, rec, http.StatusUnauthorized)
}

func TestAuthenticate_Valid(t *testing.T) {
	tok := makeToken("user-42", "charlie", testSecret, time.Now().Add(time.Hour))

	var gotClaims *mw.Claims
	inner := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		c, ok := mw.ClaimsFromContext(r.Context())
		if !ok {
			t.Error("expected claims to be present in the request context")
		}
		gotClaims = c
		w.WriteHeader(http.StatusOK)
	})

	handler := mw.Authenticate(testSecret)(inner)
	rec := doRequest(handler, fmt.Sprintf("Bearer %s", tok))

	expectStatus(t, rec, http.StatusOK)
	if gotClaims == nil {
		t.Fatal("gotClaims is nil after successful authentication")
	}
	if gotClaims.UserID != "user-42" {
		t.Errorf("expected UserID %q, got %q", "user-42", gotClaims.UserID)
	}
	if gotClaims.Username != "charlie" {
		t.Errorf("expected Username %q, got %q", "charlie", gotClaims.Username)
	}
}

// ── ClaimsFromContext ─────────────────────────────────────────────────────────

func TestClaimsFromContext_Empty(t *testing.T) {
	_, ok := mw.ClaimsFromContext(context.Background())
	if ok {
		t.Error("expected ok=false for an empty context")
	}
}

func TestClaimsFromContext_WrongType(t *testing.T) {
	// Storing a value under a different key type must not satisfy ClaimsFromContext.
	type otherKey struct{}
	ctx := context.WithValue(context.Background(), otherKey{}, &mw.Claims{UserID: "x"})
	_, ok := mw.ClaimsFromContext(ctx)
	if ok {
		t.Error("expected ok=false when claims are stored under a foreign key")
	}
}

// ── Logger ────────────────────────────────────────────────────────────────────

func TestLogger_PassesThrough(t *testing.T) {
	called := false
	inner := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		called = true
		w.WriteHeader(http.StatusAccepted)
	})
	handler := mw.Logger(inner)

	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, req)

	if !called {
		t.Error("expected inner handler to be called by Logger")
	}
	if rec.Code != http.StatusAccepted {
		t.Errorf("expected status %d, got %d", http.StatusAccepted, rec.Code)
	}
}

// ── helpers ───────────────────────────────────────────────────────────────────

func okHandler() http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})
}

func doRequest(h http.Handler, authHeader string) *httptest.ResponseRecorder {
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	if authHeader != "" {
		req.Header.Set("Authorization", authHeader)
	}
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	return rec
}

func expectStatus(t *testing.T, rec *httptest.ResponseRecorder, want int) {
	t.Helper()
	if rec.Code != want {
		t.Errorf("expected HTTP status %d, got %d (body: %s)", want, rec.Code, rec.Body.String())
	}
}
