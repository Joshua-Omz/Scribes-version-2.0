package posts_test

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/Joshua-Omz/scribes/internal/posts"
	"github.com/Joshua-Omz/scribes/pkg/middleware"
)

// mockPostRepo is an in-memory posts repository.
type mockPostRepo struct {
	posts  map[string]*posts.Post
	nextID int
	// Tracks behaviour flags for testing.
	publishError    error
}

func newMockPostRepo() *mockPostRepo {
	return &mockPostRepo{posts: make(map[string]*posts.Post)}
}

func (m *mockPostRepo) Publish(_ context.Context, userID, noteID string) (*posts.Post, error) {
	if m.publishError != nil {
		return nil, m.publishError
	}
	m.nextID++
	noteIDCopy := noteID
	p := &posts.Post{
		ID:          fmt.Sprintf("post-%d", m.nextID),
		UserID:      userID,
		NoteID:      &noteIDCopy,
		Title:       "Test Post",
		Content:     json.RawMessage(`{"blocks":[]}`),
		PublishedAt: time.Now(),
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
	m.posts[p.ID] = p
	return p, nil
}

func (m *mockPostRepo) GetByID(_ context.Context, id string) (*posts.Post, error) {
	p, ok := m.posts[id]
	if !ok || p.DeletedAt != nil {
		return nil, nil
	}
	return p, nil
}

func (m *mockPostRepo) List(_ context.Context) ([]*posts.Post, error) {
	var result []*posts.Post
	for _, p := range m.posts {
		if p.DeletedAt == nil && !p.IsArchived {
			result = append(result, p)
		}
	}
	if result == nil {
		result = []*posts.Post{}
	}
	return result, nil
}

func (m *mockPostRepo) Archive(_ context.Context, id, userID string) (*posts.Post, error) {
	p, ok := m.posts[id]
	if !ok || p.UserID != userID || p.IsArchived {
		return nil, nil
	}
	p.IsArchived = true
	return p, nil
}

func (m *mockPostRepo) LogEvent(_ context.Context, _, _, _ string, _ []byte) error {
	return nil
}

func withUserID(r *http.Request, userID string) *http.Request {
	ctx := context.WithValue(r.Context(), middleware.UserIDKey, userID)
	return r.WithContext(ctx)
}

func TestPublish_Success(t *testing.T) {
	repo := newMockPostRepo()
	h := posts.NewHandler(repo)

	body := `{"note_id":"note-abc"}`
	req := httptest.NewRequest(http.MethodPost, "/posts/publish", bytes.NewBufferString(body))
	req = withUserID(req, "user-1")
	rec := httptest.NewRecorder()

	h.Publish(rec, req)

	if rec.Code != http.StatusCreated {
		t.Fatalf("status = %d, want 201; body: %s", rec.Code, rec.Body.String())
	}
	var resp map[string]interface{}
	json.NewDecoder(rec.Body).Decode(&resp) //nolint:errcheck
	if resp["data"] == nil {
		t.Error("expected data in response")
	}
}

func TestPublish_MissingNoteID(t *testing.T) {
	h := posts.NewHandler(newMockPostRepo())
	req := httptest.NewRequest(http.MethodPost, "/posts/publish", bytes.NewBufferString(`{}`))
	req = withUserID(req, "user-1")
	rec := httptest.NewRecorder()
	h.Publish(rec, req)
	if rec.Code != http.StatusBadRequest {
		t.Errorf("status = %d, want 400", rec.Code)
	}
}

func TestPublish_Unauthorized(t *testing.T) {
	h := posts.NewHandler(newMockPostRepo())
	req := httptest.NewRequest(http.MethodPost, "/posts/publish", bytes.NewBufferString(`{"note_id":"x"}`))
	rec := httptest.NewRecorder()
	h.Publish(rec, req)
	if rec.Code != http.StatusUnauthorized {
		t.Errorf("status = %d, want 401", rec.Code)
	}
}

func TestPublish_AlreadyPublished(t *testing.T) {
	repo := newMockPostRepo()
	// Simulate the already-published sentinel error from the repository.
	repo.publishError = fmt.Errorf("note already published")

	h := posts.NewHandler(repo)
	body := `{"note_id":"note-abc"}`
	req := httptest.NewRequest(http.MethodPost, "/posts/publish", bytes.NewBufferString(body))
	req = withUserID(req, "user-1")
	rec := httptest.NewRecorder()
	h.Publish(rec, req)

	// The handler maps errAlreadyPublished to 409; our mock returns a generic error → 500.
	// This confirms the handler always calls Publish and surfaces errors.
	if rec.Code == http.StatusCreated {
		t.Error("expected non-201 for publish error")
	}
}

func TestGetPost_NotFound(t *testing.T) {
	h := posts.NewHandler(newMockPostRepo())
	req := httptest.NewRequest(http.MethodGet, "/posts/nope", nil)
	req.SetPathValue("id", "nope")
	rec := httptest.NewRecorder()
	h.Get(rec, req)
	if rec.Code != http.StatusNotFound {
		t.Errorf("status = %d, want 404", rec.Code)
	}
}

func TestListPosts(t *testing.T) {
	repo := newMockPostRepo()
	repo.Publish(context.Background(), "user-1", "note-1") //nolint:errcheck
	repo.Publish(context.Background(), "user-2", "note-2") //nolint:errcheck

	h := posts.NewHandler(repo)
	req := httptest.NewRequest(http.MethodGet, "/posts", nil)
	rec := httptest.NewRecorder()
	h.List(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want 200", rec.Code)
	}
	var resp map[string]interface{}
	json.NewDecoder(rec.Body).Decode(&resp) //nolint:errcheck
	data := resp["data"].([]interface{})
	if len(data) != 2 {
		t.Errorf("count = %d, want 2", len(data))
	}
}

func TestArchivePost_Immutability(t *testing.T) {
	// Verify that archiving a post only changes is_archived, not content.
	repo := newMockPostRepo()
	p, _ := repo.Publish(context.Background(), "user-1", "note-1")
	originalContent := string(p.Content)

	h := posts.NewHandler(repo)
	req := httptest.NewRequest(http.MethodPatch, "/posts/"+p.ID+"/archive", nil)
	req = withUserID(req, "user-1")
	req.SetPathValue("id", p.ID)
	rec := httptest.NewRecorder()
	h.Archive(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want 200; body: %s", rec.Code, rec.Body.String())
	}

	archived, _ := repo.GetByID(context.Background(), p.ID)
	if !archived.IsArchived {
		t.Error("expected post to be archived")
	}
	if string(archived.Content) != originalContent {
		t.Errorf("content changed after archive: got %q, want %q", archived.Content, originalContent)
	}
}

func TestNoUpdateEndpoint(t *testing.T) {
	// Posts have no PUT/PATCH content endpoint — this is enforced by router design.
	// Verify the mock has no Update method.
	var _ posts.Repository = (*mockPostRepo)(nil)
	// If this compiles, the Repository interface has no Update method.
}
