package posts

import (
	"encoding/json"
	"errors"
	"log"
	"net/http"

	"github.com/Joshua-Omz/scribes/pkg/middleware"
)

// Handler handles post endpoints.
type Handler struct {
	repo Repository
}

// NewHandler creates a posts handler.
func NewHandler(repo Repository) *Handler {
	return &Handler{repo: repo}
}

// Publish handles POST /posts/publish.
func (h *Handler) Publish(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	var req PublishRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if req.NoteID == "" {
		writeError(w, http.StatusBadRequest, "note_id is required")
		return
	}

	post, err := h.repo.Publish(r.Context(), userID, req.NoteID)
	if err != nil {
		switch {
		case errors.Is(err, ErrNoteNotFound):
			writeError(w, http.StatusNotFound, "note not found")
		case errors.Is(err, ErrAlreadyPublished):
			writeError(w, http.StatusConflict, "note has already been published")
		case errors.Is(err, ErrImportedNote):
			writeError(w, http.StatusForbidden, "imported notes cannot be published")
		default:
			writeError(w, http.StatusInternalServerError, "failed to publish post")
		}
		return
	}
	writeJSON(w, http.StatusCreated, map[string]interface{}{"data": post})
}

// Get handles GET /posts/{id}.
func (h *Handler) Get(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	post, err := h.repo.GetByID(r.Context(), id)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to fetch post")
		return
	}
	if post == nil {
		writeError(w, http.StatusNotFound, "post not found")
		return
	}
	writeJSON(w, http.StatusOK, map[string]interface{}{"data": post})
}

// List handles GET /posts.
func (h *Handler) List(w http.ResponseWriter, r *http.Request) {
	posts, err := h.repo.List(r.Context())
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to list posts")
		return
	}
	writeJSON(w, http.StatusOK, map[string]interface{}{"data": posts})
}

// Archive handles PATCH /posts/{id}/archive.
func (h *Handler) Archive(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}
	id := r.PathValue("id")

	post, err := h.repo.Archive(r.Context(), id, userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to archive post")
		return
	}
	if post == nil {
		writeError(w, http.StatusNotFound, "post not found or already archived")
		return
	}

	if err := h.repo.LogEvent(r.Context(), post.ID, userID, "archived", nil); err != nil {
		log.Printf("WARN: failed to log archive event for post %s: %v", post.ID, err)
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{"data": post})
}

func writeJSON(w http.ResponseWriter, status int, v interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v) //nolint:errcheck
}

func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]string{"error": msg})
}
