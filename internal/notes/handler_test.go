package notes_test

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/Joshua-Omz/scribes/internal/notes"
	"github.com/Joshua-Omz/scribes/pkg/middleware"
)

// mockRepo is an in-memory notes repository.
type mockRepo struct {
	notes  map[string]*notes.Note
	nextID int
}

func newMockRepo() *mockRepo {
	return &mockRepo{notes: make(map[string]*notes.Note)}
}

func (m *mockRepo) Create(_ context.Context, userID, title string, content []byte) (*notes.Note, error) {
	m.nextID++
	id := fmt.Sprintf("note-%d", m.nextID)
	if content == nil {
		content = []byte("{}")
	}
	n := &notes.Note{
		ID:        id,
		UserID:    userID,
		Title:     title,
		Content:   json.RawMessage(content),
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
	m.notes[id] = n
	return n, nil
}

func (m *mockRepo) GetByID(_ context.Context, id, userID string) (*notes.Note, error) {
	n, ok := m.notes[id]
	if !ok || n.UserID != userID || n.DeletedAt != nil {
		return nil, nil
	}
	return n, nil
}

func (m *mockRepo) List(_ context.Context, userID string) ([]*notes.Note, error) {
	var result []*notes.Note
	for _, n := range m.notes {
		if n.UserID == userID && n.DeletedAt == nil {
			result = append(result, n)
		}
	}
	if result == nil {
		result = []*notes.Note{}
	}
	return result, nil
}

func (m *mockRepo) Update(_ context.Context, id, userID string, title *string, content []byte) (*notes.Note, error) {
	n, ok := m.notes[id]
	if !ok || n.UserID != userID || n.DeletedAt != nil || n.IsPublished || n.IsImported {
		return nil, nil
	}
	if title != nil {
		n.Title = *title
	}
	if content != nil {
		n.Content = json.RawMessage(content)
	}
	n.UpdatedAt = time.Now()
	return n, nil
}

func (m *mockRepo) Delete(_ context.Context, id, userID string) error {
	n, ok := m.notes[id]
	if !ok || n.UserID != userID || n.DeletedAt != nil {
		return nil
	}
	now := time.Now()
	n.DeletedAt = &now
	return nil
}

// withUserID injects a fake user ID into the request context.
func withUserID(r *http.Request, userID string) *http.Request {
	ctx := context.WithValue(r.Context(), middleware.UserIDKey, userID)
	return r.WithContext(ctx)
}

func TestCreateNote(t *testing.T) {
	h := notes.NewHandler(newMockRepo())

	body := `{"title":"My Note","content":{"blocks":[]}}`
	req := httptest.NewRequest(http.MethodPost, "/notes", bytes.NewBufferString(body))
	req = withUserID(req, "user-1")
	rec := httptest.NewRecorder()

	h.Create(rec, req)

	if rec.Code != http.StatusCreated {
		t.Fatalf("status = %d, want 201; body: %s", rec.Code, rec.Body.String())
	}
	var resp map[string]interface{}
	json.NewDecoder(rec.Body).Decode(&resp) //nolint:errcheck
	data := resp["data"].(map[string]interface{})
	if data["title"] != "My Note" {
		t.Errorf("title = %v, want 'My Note'", data["title"])
	}
}

func TestCreateNote_MissingTitle(t *testing.T) {
	h := notes.NewHandler(newMockRepo())
	req := httptest.NewRequest(http.MethodPost, "/notes", bytes.NewBufferString(`{"content":{}}`))
	req = withUserID(req, "user-1")
	rec := httptest.NewRecorder()
	h.Create(rec, req)
	if rec.Code != http.StatusBadRequest {
		t.Errorf("status = %d, want 400", rec.Code)
	}
}

func TestCreateNote_Unauthorized(t *testing.T) {
	h := notes.NewHandler(newMockRepo())
	req := httptest.NewRequest(http.MethodPost, "/notes", bytes.NewBufferString(`{"title":"t"}`))
	// No user ID in context.
	rec := httptest.NewRecorder()
	h.Create(rec, req)
	if rec.Code != http.StatusUnauthorized {
		t.Errorf("status = %d, want 401", rec.Code)
	}
}

func TestListNotes(t *testing.T) {
	repo := newMockRepo()
	repo.Create(context.Background(), "user-1", "Note A", nil) //nolint:errcheck
	repo.Create(context.Background(), "user-1", "Note B", nil) //nolint:errcheck
	repo.Create(context.Background(), "user-2", "Other", nil)  //nolint:errcheck

	h := notes.NewHandler(repo)
	req := httptest.NewRequest(http.MethodGet, "/notes", nil)
	req = withUserID(req, "user-1")
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

func TestGetNote_NotFound(t *testing.T) {
	h := notes.NewHandler(newMockRepo())
	req := httptest.NewRequest(http.MethodGet, "/notes/nonexistent", nil)
	req = withUserID(req, "user-1")
	req.SetPathValue("id", "nonexistent")
	rec := httptest.NewRecorder()
	h.Get(rec, req)
	if rec.Code != http.StatusNotFound {
		t.Errorf("status = %d, want 404", rec.Code)
	}
}

func TestUpdateNote(t *testing.T) {
	repo := newMockRepo()
	n, _ := repo.Create(context.Background(), "user-1", "Original", nil)

	h := notes.NewHandler(repo)
	newTitle := "Updated"
	body, _ := json.Marshal(map[string]string{"title": newTitle})
	req := httptest.NewRequest(http.MethodPatch, "/notes/"+n.ID, bytes.NewReader(body))
	req = withUserID(req, "user-1")
	req.SetPathValue("id", n.ID)
	rec := httptest.NewRecorder()
	h.Update(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want 200; body: %s", rec.Code, rec.Body.String())
	}
}

func TestDeleteNote(t *testing.T) {
	repo := newMockRepo()
	n, _ := repo.Create(context.Background(), "user-1", "To Delete", nil)

	h := notes.NewHandler(repo)
	req := httptest.NewRequest(http.MethodDelete, "/notes/"+n.ID, nil)
	req = withUserID(req, "user-1")
	req.SetPathValue("id", n.ID)
	rec := httptest.NewRecorder()
	h.Delete(rec, req)

	if rec.Code != http.StatusNoContent {
		t.Errorf("status = %d, want 204", rec.Code)
	}
}
