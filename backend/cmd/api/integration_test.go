//go:build integration

// Package main_test contains integration tests that exercise the full Scribes
// HTTP stack against a real PostgreSQL database.
//
// Run with:
//
//	TEST_DATABASE_URL="postgres://..." go test -v -race -tags integration ./cmd/api/...
//
// The tests are automatically skipped when TEST_DATABASE_URL is not set, so a
// plain `go test ./...` (without the build tag) will never require a database.
package main_test

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	"github.com/go-chi/chi/v5"
	chiMiddleware "github.com/go-chi/chi/v5/middleware"

	"github.com/Joshua-Omz/scribes/internal/auth"
	"github.com/Joshua-Omz/scribes/internal/drafts"
	"github.com/Joshua-Omz/scribes/internal/notes"
	"github.com/Joshua-Omz/scribes/internal/posts"
	syncPkg "github.com/Joshua-Omz/scribes/internal/sync"
	"github.com/Joshua-Omz/scribes/internal/users"
	"github.com/Joshua-Omz/scribes/pkg/database"
	mw "github.com/Joshua-Omz/scribes/pkg/middleware"
)

const testJWTSecret = "integration-test-secret"

// testDBURL returns the database URL for integration tests or skips the test.
func testDBURL(t *testing.T) string {
	t.Helper()
	url := os.Getenv("TEST_DATABASE_URL")
	if url == "" {
		t.Skip("TEST_DATABASE_URL not set – skipping integration test")
	}
	return url
}

// newTestServer spins up a full Scribes HTTP server backed by a real database
// and returns both the httptest.Server and a cleanup function.
func newTestServer(t *testing.T) *httptest.Server {
	t.Helper()
	dbURL := testDBURL(t)

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	pool, err := database.Connect(ctx, dbURL)
	if err != nil {
		t.Fatalf("connect to test database: %v", err)
	}

	if err = database.Migrate(dbURL, "file://../../migrations"); err != nil {
		pool.Close()
		t.Fatalf("run migrations: %v", err)
	}

	userRepo := users.NewRepository(pool)
	noteRepo := notes.NewRepository(pool)
	draftRepo := drafts.NewRepository(pool)
	postRepo := posts.NewRepository(pool)

	authHandler := auth.NewHandler(userRepo, testJWTSecret)
	noteHandler := notes.NewHandler(noteRepo)
	draftHandler := drafts.NewHandler(draftRepo)
	postHandler := posts.NewHandler(postRepo)
	syncHandler := syncPkg.NewHandler(noteRepo, draftRepo, postRepo)

	r := chi.NewRouter()
	r.Use(chiMiddleware.Recoverer)

	r.Post("/api/auth/register", authHandler.Register)
	r.Post("/api/auth/login", authHandler.Login)

	r.Get("/api/posts", postHandler.Feed)
	r.Get("/api/posts/{id}", postHandler.Get)

	r.Group(func(r chi.Router) {
		r.Use(mw.Authenticate(testJWTSecret))

		r.Get("/api/auth/me", authHandler.Me)

		r.Get("/api/notes", noteHandler.List)
		r.Post("/api/notes", noteHandler.Create)
		r.Get("/api/notes/{id}", noteHandler.Get)
		r.Put("/api/notes/{id}", noteHandler.Update)
		r.Delete("/api/notes/{id}", noteHandler.Delete)

		r.Get("/api/drafts", draftHandler.List)
		r.Post("/api/drafts", draftHandler.Create)
		r.Get("/api/drafts/{id}", draftHandler.Get)
		r.Put("/api/drafts/{id}", draftHandler.Update)
		r.Delete("/api/drafts/{id}", draftHandler.Delete)

		r.Post("/api/posts", postHandler.Create)
		r.Put("/api/posts/{id}", postHandler.Update)
		r.Delete("/api/posts/{id}", postHandler.Delete)

		r.Get("/api/sync/pull", syncHandler.Pull)
		r.Post("/api/sync/push", syncHandler.Push)
	})

	r.Get("/health", func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"status":"ok"}`))
	})

	srv := httptest.NewServer(r)
	t.Cleanup(func() {
		srv.Close()
		pool.Close()
	})
	return srv
}

// ── helpers ───────────────────────────────────────────────────────────────────

func doJSON(t *testing.T, client *http.Client, method, url string, body any, token string) *http.Response {
	t.Helper()
	var reqBody io.Reader
	if body != nil {
		b, err := json.Marshal(body)
		if err != nil {
			t.Fatalf("marshal request body: %v", err)
		}
		reqBody = bytes.NewReader(b)
	}
	req, err := http.NewRequest(method, url, reqBody)
	if err != nil {
		t.Fatalf("create request: %v", err)
	}
	req.Header.Set("Content-Type", "application/json")
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	resp, err := client.Do(req)
	if err != nil {
		t.Fatalf("execute request %s %s: %v", method, url, err)
	}
	return resp
}

func decodeJSON(t *testing.T, resp *http.Response, dst any) {
	t.Helper()
	defer resp.Body.Close()
	if err := json.NewDecoder(resp.Body).Decode(dst); err != nil {
		t.Fatalf("decode response body: %v", err)
	}
}

// uniqueEmail returns an email address that is unique per test run.
func uniqueEmail(prefix string) string {
	return fmt.Sprintf("%s+%d@test.example.com", prefix, time.Now().UnixNano())
}

// ── tests ─────────────────────────────────────────────────────────────────────

func TestHealth(t *testing.T) {
	srv := newTestServer(t)
	resp, err := http.Get(srv.URL + "/health")
	if err != nil {
		t.Fatalf("GET /health: %v", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		t.Errorf("GET /health: want 200, got %d", resp.StatusCode)
	}
}

func TestAuth_Register(t *testing.T) {
	srv := newTestServer(t)
	client := srv.Client()

	payload := map[string]string{
		"username": "testuser",
		"email":    uniqueEmail("register"),
		"password": "s3cr3t-password",
	}
	resp := doJSON(t, client, http.MethodPost, srv.URL+"/api/auth/register", payload, "")
	if resp.StatusCode != http.StatusCreated {
		t.Errorf("POST /api/auth/register: want 201, got %d", resp.StatusCode)
	}

	var body map[string]any
	decodeJSON(t, resp, &body)
	if body["token"] == nil {
		t.Error("register response missing 'token' field")
	}
}

func TestAuth_Register_DuplicateEmail(t *testing.T) {
	srv := newTestServer(t)
	client := srv.Client()
	email := uniqueEmail("dup")

	for i := 0; i < 2; i++ {
		payload := map[string]string{
			"username": fmt.Sprintf("dupuser%d", i),
			"email":    email,
			"password": "password",
		}
		resp := doJSON(t, client, http.MethodPost, srv.URL+"/api/auth/register", payload, "")
		resp.Body.Close()
		if i == 0 && resp.StatusCode != http.StatusCreated {
			t.Fatalf("first register: want 201, got %d", resp.StatusCode)
		}
		if i == 1 && resp.StatusCode != http.StatusConflict {
			t.Errorf("duplicate register: want 409, got %d", resp.StatusCode)
		}
	}
}

func TestAuth_LoginAndMe(t *testing.T) {
	srv := newTestServer(t)
	client := srv.Client()
	email := uniqueEmail("loginme")
	const password = "loginpassword"

	// Register
	regResp := doJSON(t, client, http.MethodPost, srv.URL+"/api/auth/register", map[string]string{
		"username": "loginuser",
		"email":    email,
		"password": password,
	}, "")
	if regResp.StatusCode != http.StatusCreated {
		t.Fatalf("register: want 201, got %d", regResp.StatusCode)
	}
	regResp.Body.Close()

	// Login
	loginResp := doJSON(t, client, http.MethodPost, srv.URL+"/api/auth/login", map[string]string{
		"email":    email,
		"password": password,
	}, "")
	if loginResp.StatusCode != http.StatusOK {
		t.Fatalf("login: want 200, got %d", loginResp.StatusCode)
	}
	var loginBody map[string]any
	decodeJSON(t, loginResp, &loginBody)
	token, ok := loginBody["token"].(string)
	if !ok || token == "" {
		t.Fatal("login response missing 'token'")
	}

	// GET /api/auth/me
	meResp := doJSON(t, client, http.MethodGet, srv.URL+"/api/auth/me", nil, token)
	if meResp.StatusCode != http.StatusOK {
		t.Errorf("GET /api/auth/me: want 200, got %d", meResp.StatusCode)
	}
	var meBody map[string]any
	decodeJSON(t, meResp, &meBody)
	if meBody["email"] != email {
		t.Errorf("me.email: want %q, got %q", email, meBody["email"])
	}
}

func TestAuth_Me_Unauthenticated(t *testing.T) {
	srv := newTestServer(t)
	resp := doJSON(t, srv.Client(), http.MethodGet, srv.URL+"/api/auth/me", nil, "")
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusUnauthorized {
		t.Errorf("GET /api/auth/me (no token): want 401, got %d", resp.StatusCode)
	}
}

func TestNotes_CRUD(t *testing.T) {
	srv := newTestServer(t)
	client := srv.Client()
	token := registerAndLogin(t, client, srv.URL)

	// Create note
	createResp := doJSON(t, client, http.MethodPost, srv.URL+"/api/notes", map[string]string{
		"title": "Integration test note",
		"body":  "Written by TestNotes_CRUD",
	}, token)
	if createResp.StatusCode != http.StatusCreated {
		t.Fatalf("POST /api/notes: want 201, got %d", createResp.StatusCode)
	}
	var created map[string]any
	decodeJSON(t, createResp, &created)
	noteID, _ := created["id"].(string)
	if noteID == "" {
		t.Fatal("created note missing 'id'")
	}

	// List notes
	listResp := doJSON(t, client, http.MethodGet, srv.URL+"/api/notes", nil, token)
	if listResp.StatusCode != http.StatusOK {
		t.Errorf("GET /api/notes: want 200, got %d", listResp.StatusCode)
	}
	listResp.Body.Close()

	// Get by ID
	getResp := doJSON(t, client, http.MethodGet, fmt.Sprintf("%s/api/notes/%s", srv.URL, noteID), nil, token)
	if getResp.StatusCode != http.StatusOK {
		t.Errorf("GET /api/notes/%s: want 200, got %d", noteID, getResp.StatusCode)
	}
	getResp.Body.Close()

	// Update note
	updateResp := doJSON(t, client, http.MethodPut, fmt.Sprintf("%s/api/notes/%s", srv.URL, noteID), map[string]string{
		"title": "Updated title",
		"body":  "Updated body",
	}, token)
	if updateResp.StatusCode != http.StatusOK {
		t.Errorf("PUT /api/notes/%s: want 200, got %d", noteID, updateResp.StatusCode)
	}
	var updated map[string]any
	decodeJSON(t, updateResp, &updated)
	if updated["title"] != "Updated title" {
		t.Errorf("updated note title: want %q, got %q", "Updated title", updated["title"])
	}

	// Delete note
	delResp := doJSON(t, client, http.MethodDelete, fmt.Sprintf("%s/api/notes/%s", srv.URL, noteID), nil, token)
	if delResp.StatusCode != http.StatusNoContent {
		t.Errorf("DELETE /api/notes/%s: want 204, got %d", noteID, delResp.StatusCode)
	}
	delResp.Body.Close()

	// Confirm deletion (note should no longer be accessible)
	afterDel := doJSON(t, client, http.MethodGet, fmt.Sprintf("%s/api/notes/%s", srv.URL, noteID), nil, token)
	if afterDel.StatusCode != http.StatusNotFound {
		t.Errorf("GET deleted note: want 404, got %d", afterDel.StatusCode)
	}
	afterDel.Body.Close()
}

func TestPublicFeed(t *testing.T) {
	srv := newTestServer(t)
	resp, err := http.Get(srv.URL + "/api/posts")
	if err != nil {
		t.Fatalf("GET /api/posts: %v", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		t.Errorf("GET /api/posts: want 200, got %d", resp.StatusCode)
	}
}

// registerAndLogin is a convenience helper that registers a unique user,
// logs them in, and returns the bearer token.
func registerAndLogin(t *testing.T, client *http.Client, baseURL string) string {
	t.Helper()
	email := uniqueEmail("crud")
	const password = "crudpassword"

	regResp := doJSON(t, client, http.MethodPost, baseURL+"/api/auth/register", map[string]string{
		"username": fmt.Sprintf("cruduser%d", time.Now().UnixNano()),
		"email":    email,
		"password": password,
	}, "")
	if regResp.StatusCode != http.StatusCreated {
		t.Fatalf("registerAndLogin: register want 201, got %d", regResp.StatusCode)
	}
	var regBody map[string]any
	decodeJSON(t, regResp, &regBody)
	token, _ := regBody["token"].(string)
	if token == "" {
		t.Fatal("registerAndLogin: no token in register response")
	}
	return token
}
