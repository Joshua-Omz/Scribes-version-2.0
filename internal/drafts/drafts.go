// Package drafts implements the draft model, repository and HTTP handlers.
package drafts

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	mw "github.com/Joshua-Omz/scribes/pkg/middleware"
)

// Draft is a staging area between a private Note and a published Post.
type Draft struct {
	ID        string     `json:"id"`
	UserID    string     `json:"user_id"`
	NoteID    *string    `json:"note_id,omitempty"`
	Title     string     `json:"title"`
	Body      string     `json:"body"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `json:"deleted_at,omitempty"`
}

// Repository is the data-access layer for drafts.
type Repository struct {
	db *pgxpool.Pool
}

// NewRepository creates a Repository.
func NewRepository(db *pgxpool.Pool) *Repository { return &Repository{db: db} }

func (r *Repository) Create(ctx context.Context, userID string, noteID *string, title, body string) (*Draft, error) {
	const q = `
		INSERT INTO drafts (user_id, note_id, title, body)
		VALUES ($1, $2, $3, $4)
		RETURNING id, user_id, note_id, title, body, created_at, updated_at, deleted_at`

	d := &Draft{}
	err := r.db.QueryRow(ctx, q, userID, noteID, title, body).
		Scan(&d.ID, &d.UserID, &d.NoteID, &d.Title, &d.Body, &d.CreatedAt, &d.UpdatedAt, &d.DeletedAt)
	if err != nil {
		return nil, fmt.Errorf("drafts.Create: %w", err)
	}
	return d, nil
}

func (r *Repository) List(ctx context.Context, userID string) ([]*Draft, error) {
	const q = `
		SELECT id, user_id, note_id, title, body, created_at, updated_at, deleted_at
		FROM drafts
		WHERE user_id = $1 AND deleted_at IS NULL
		ORDER BY created_at DESC`

	rows, err := r.db.Query(ctx, q, userID)
	if err != nil {
		return nil, fmt.Errorf("drafts.List: %w", err)
	}
	defer rows.Close()

	var result []*Draft
	for rows.Next() {
		d := &Draft{}
		if err = rows.Scan(&d.ID, &d.UserID, &d.NoteID, &d.Title, &d.Body, &d.CreatedAt, &d.UpdatedAt, &d.DeletedAt); err != nil {
			return nil, fmt.Errorf("drafts.List scan: %w", err)
		}
		result = append(result, d)
	}
	return result, rows.Err()
}

func (r *Repository) GetByID(ctx context.Context, id, userID string) (*Draft, error) {
	const q = `
		SELECT id, user_id, note_id, title, body, created_at, updated_at, deleted_at
		FROM drafts
		WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL`

	d := &Draft{}
	err := r.db.QueryRow(ctx, q, id, userID).
		Scan(&d.ID, &d.UserID, &d.NoteID, &d.Title, &d.Body, &d.CreatedAt, &d.UpdatedAt, &d.DeletedAt)
	if err != nil {
		return nil, fmt.Errorf("drafts.GetByID: %w", err)
	}
	return d, nil
}

func (r *Repository) Update(ctx context.Context, id, userID, title, body string) (*Draft, error) {
	const q = `
		UPDATE drafts SET title = $3, body = $4, updated_at = NOW()
		WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL
		RETURNING id, user_id, note_id, title, body, created_at, updated_at, deleted_at`

	d := &Draft{}
	err := r.db.QueryRow(ctx, q, id, userID, title, body).
		Scan(&d.ID, &d.UserID, &d.NoteID, &d.Title, &d.Body, &d.CreatedAt, &d.UpdatedAt, &d.DeletedAt)
	if err != nil {
		return nil, fmt.Errorf("drafts.Update: %w", err)
	}
	return d, nil
}

func (r *Repository) SoftDelete(ctx context.Context, id, userID string) error {
	const q = `
		UPDATE drafts SET deleted_at = NOW(), updated_at = NOW()
		WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL`

	tag, err := r.db.Exec(ctx, q, id, userID)
	if err != nil {
		return fmt.Errorf("drafts.SoftDelete: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("drafts.SoftDelete: draft not found")
	}
	return nil
}

// ListUpdatedAfter returns drafts changed after since (for delta sync).
func (r *Repository) ListUpdatedAfter(ctx context.Context, userID string, since time.Time) ([]*Draft, error) {
	const q = `
		SELECT id, user_id, note_id, title, body, created_at, updated_at, deleted_at
		FROM drafts
		WHERE user_id = $1 AND updated_at > $2
		ORDER BY updated_at ASC`

	rows, err := r.db.Query(ctx, q, userID, since)
	if err != nil {
		return nil, fmt.Errorf("drafts.ListUpdatedAfter: %w", err)
	}
	defer rows.Close()

	var result []*Draft
	for rows.Next() {
		d := &Draft{}
		if err = rows.Scan(&d.ID, &d.UserID, &d.NoteID, &d.Title, &d.Body, &d.CreatedAt, &d.UpdatedAt, &d.DeletedAt); err != nil {
			return nil, fmt.Errorf("drafts.ListUpdatedAfter scan: %w", err)
		}
		result = append(result, d)
	}
	return result, rows.Err()
}

// ── HTTP Handler ──────────────────────────────────────────────────────────────

// Handler handles HTTP requests for drafts.
type Handler struct{ repo *Repository }

// NewHandler creates a drafts Handler.
func NewHandler(repo *Repository) *Handler { return &Handler{repo: repo} }

type draftRequest struct {
	NoteID *string `json:"note_id,omitempty"`
	Title  string  `json:"title"`
	Body   string  `json:"body"`
}

func (h *Handler) List(w http.ResponseWriter, r *http.Request) {
	claims, _ := mw.ClaimsFromContext(r.Context())
	drafts, err := h.repo.List(r.Context(), claims.UserID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "could not list drafts")
		return
	}
	writeJSON(w, http.StatusOK, drafts)
}

func (h *Handler) Create(w http.ResponseWriter, r *http.Request) {
	claims, _ := mw.ClaimsFromContext(r.Context())
	var req draftRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	draft, err := h.repo.Create(r.Context(), claims.UserID, req.NoteID, req.Title, req.Body)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "could not create draft")
		return
	}
	writeJSON(w, http.StatusCreated, draft)
}

func (h *Handler) Get(w http.ResponseWriter, r *http.Request) {
	claims, _ := mw.ClaimsFromContext(r.Context())
	id := chi.URLParam(r, "id")
	draft, err := h.repo.GetByID(r.Context(), id, claims.UserID)
	if err != nil {
		writeError(w, http.StatusNotFound, "draft not found")
		return
	}
	writeJSON(w, http.StatusOK, draft)
}

func (h *Handler) Update(w http.ResponseWriter, r *http.Request) {
	claims, _ := mw.ClaimsFromContext(r.Context())
	id := chi.URLParam(r, "id")
	var req draftRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	draft, err := h.repo.Update(r.Context(), id, claims.UserID, req.Title, req.Body)
	if err != nil {
		writeError(w, http.StatusNotFound, "draft not found")
		return
	}
	writeJSON(w, http.StatusOK, draft)
}

func (h *Handler) Delete(w http.ResponseWriter, r *http.Request) {
	claims, _ := mw.ClaimsFromContext(r.Context())
	id := chi.URLParam(r, "id")
	if err := h.repo.SoftDelete(r.Context(), id, claims.UserID); err != nil {
		writeError(w, http.StatusNotFound, "draft not found")
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func writeJSON(w http.ResponseWriter, code int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	_ = json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, code int, msg string) {
	writeJSON(w, code, map[string]string{"error": msg})
}
