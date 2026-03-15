// Package posts implements the public post model, repository and HTTP handlers.
package posts

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

// Post is a publicly visible piece of writing.
type Post struct {
	ID        string     `json:"id"`
	UserID    string     `json:"user_id"`
	DraftID   *string    `json:"draft_id,omitempty"`
	Title     string     `json:"title"`
	Body      string     `json:"body"`
	Category  string     `json:"category"`
	Scripture *string    `json:"scripture,omitempty"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `json:"deleted_at,omitempty"`
}

// Repository is the data-access layer for posts.
type Repository struct {
	db *pgxpool.Pool
}

// NewRepository creates a Repository.
func NewRepository(db *pgxpool.Pool) *Repository { return &Repository{db: db} }

func (r *Repository) Create(ctx context.Context, userID string, draftID *string, title, body, category string, scripture *string) (*Post, error) {
	const q = `
		INSERT INTO posts (user_id, draft_id, title, body, category, scripture)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, user_id, draft_id, title, body, category, scripture, created_at, updated_at, deleted_at`

	p := &Post{}
	err := r.db.QueryRow(ctx, q, userID, draftID, title, body, category, scripture).
		Scan(&p.ID, &p.UserID, &p.DraftID, &p.Title, &p.Body, &p.Category, &p.Scripture,
			&p.CreatedAt, &p.UpdatedAt, &p.DeletedAt)
	if err != nil {
		return nil, fmt.Errorf("posts.Create: %w", err)
	}
	return p, nil
}

// Feed returns all non-deleted posts ordered chronologically (newest first).
func (r *Repository) Feed(ctx context.Context, category string) ([]*Post, error) {
	q := `
		SELECT id, user_id, draft_id, title, body, category, scripture, created_at, updated_at, deleted_at
		FROM posts
		WHERE deleted_at IS NULL`
	args := []any{}
	if category != "" {
		q += ` AND category = $1`
		args = append(args, category)
	}
	q += ` ORDER BY created_at DESC`

	rows, err := r.db.Query(ctx, q, args...)
	if err != nil {
		return nil, fmt.Errorf("posts.Feed: %w", err)
	}
	defer rows.Close()

	var result []*Post
	for rows.Next() {
		p := &Post{}
		if err = rows.Scan(&p.ID, &p.UserID, &p.DraftID, &p.Title, &p.Body, &p.Category, &p.Scripture,
			&p.CreatedAt, &p.UpdatedAt, &p.DeletedAt); err != nil {
			return nil, fmt.Errorf("posts.Feed scan: %w", err)
		}
		result = append(result, p)
	}
	return result, rows.Err()
}

func (r *Repository) GetByID(ctx context.Context, id string) (*Post, error) {
	const q = `
		SELECT id, user_id, draft_id, title, body, category, scripture, created_at, updated_at, deleted_at
		FROM posts
		WHERE id = $1 AND deleted_at IS NULL`

	p := &Post{}
	err := r.db.QueryRow(ctx, q, id).
		Scan(&p.ID, &p.UserID, &p.DraftID, &p.Title, &p.Body, &p.Category, &p.Scripture,
			&p.CreatedAt, &p.UpdatedAt, &p.DeletedAt)
	if err != nil {
		return nil, fmt.Errorf("posts.GetByID: %w", err)
	}
	return p, nil
}

func (r *Repository) Update(ctx context.Context, id, userID, title, body, category string, scripture *string) (*Post, error) {
	const q = `
		UPDATE posts SET title = $3, body = $4, category = $5, scripture = $6, updated_at = NOW()
		WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL
		RETURNING id, user_id, draft_id, title, body, category, scripture, created_at, updated_at, deleted_at`

	p := &Post{}
	err := r.db.QueryRow(ctx, q, id, userID, title, body, category, scripture).
		Scan(&p.ID, &p.UserID, &p.DraftID, &p.Title, &p.Body, &p.Category, &p.Scripture,
			&p.CreatedAt, &p.UpdatedAt, &p.DeletedAt)
	if err != nil {
		return nil, fmt.Errorf("posts.Update: %w", err)
	}
	return p, nil
}

func (r *Repository) SoftDelete(ctx context.Context, id, userID string) error {
	const q = `
		UPDATE posts SET deleted_at = NOW(), updated_at = NOW()
		WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL`

	tag, err := r.db.Exec(ctx, q, id, userID)
	if err != nil {
		return fmt.Errorf("posts.SoftDelete: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("posts.SoftDelete: post not found")
	}
	return nil
}

// ── HTTP Handler ──────────────────────────────────────────────────────────────

// Handler handles HTTP requests for posts.
type Handler struct{ repo *Repository }

// NewHandler creates a posts Handler.
func NewHandler(repo *Repository) *Handler { return &Handler{repo: repo} }

type postRequest struct {
	DraftID   *string `json:"draft_id,omitempty"`
	Title     string  `json:"title"`
	Body      string  `json:"body"`
	Category  string  `json:"category"`
	Scripture *string `json:"scripture,omitempty"`
}

// Feed returns the public chronological post feed, optionally filtered by category.
func (h *Handler) Feed(w http.ResponseWriter, r *http.Request) {
	category := r.URL.Query().Get("category")
	posts, err := h.repo.Feed(r.Context(), category)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "could not fetch feed")
		return
	}
	writeJSON(w, http.StatusOK, posts)
}

func (h *Handler) Get(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	post, err := h.repo.GetByID(r.Context(), id)
	if err != nil {
		writeError(w, http.StatusNotFound, "post not found")
		return
	}
	writeJSON(w, http.StatusOK, post)
}

func (h *Handler) Create(w http.ResponseWriter, r *http.Request) {
	claims, _ := mw.ClaimsFromContext(r.Context())
	var req postRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if req.Body == "" {
		writeError(w, http.StatusBadRequest, "body is required")
		return
	}
	if req.Category == "" {
		req.Category = "general"
	}
	post, err := h.repo.Create(r.Context(), claims.UserID, req.DraftID, req.Title, req.Body, req.Category, req.Scripture)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "could not create post")
		return
	}
	writeJSON(w, http.StatusCreated, post)
}

func (h *Handler) Update(w http.ResponseWriter, r *http.Request) {
	claims, _ := mw.ClaimsFromContext(r.Context())
	id := chi.URLParam(r, "id")
	var req postRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	post, err := h.repo.Update(r.Context(), id, claims.UserID, req.Title, req.Body, req.Category, req.Scripture)
	if err != nil {
		writeError(w, http.StatusNotFound, "post not found")
		return
	}
	writeJSON(w, http.StatusOK, post)
}

func (h *Handler) Delete(w http.ResponseWriter, r *http.Request) {
	claims, _ := mw.ClaimsFromContext(r.Context())
	id := chi.URLParam(r, "id")
	if err := h.repo.SoftDelete(r.Context(), id, claims.UserID); err != nil {
		writeError(w, http.StatusNotFound, "post not found")
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

// ListUpdatedAfter returns posts updated after since (public, no user filter).
func (r *Repository) ListUpdatedAfter(ctx context.Context, since time.Time) ([]*Post, error) {
	const q = `
		SELECT id, user_id, draft_id, title, body, category, scripture, created_at, updated_at, deleted_at
		FROM posts
		WHERE updated_at > $1
		ORDER BY updated_at ASC`

	rows, err := r.db.Query(ctx, q, since)
	if err != nil {
		return nil, fmt.Errorf("posts.ListUpdatedAfter: %w", err)
	}
	defer rows.Close()

	var result []*Post
	for rows.Next() {
		p := &Post{}
		if err = rows.Scan(&p.ID, &p.UserID, &p.DraftID, &p.Title, &p.Body, &p.Category, &p.Scripture,
			&p.CreatedAt, &p.UpdatedAt, &p.DeletedAt); err != nil {
			return nil, fmt.Errorf("posts.ListUpdatedAfter scan: %w", err)
		}
		result = append(result, p)
	}
	return result, rows.Err()
}
