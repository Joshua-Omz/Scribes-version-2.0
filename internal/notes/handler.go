package notes

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"strings"

	"github.com/Joshua-Omz/scribes/pkg/middleware"
)

// Handler handles note endpoints.
type Handler struct {
	repo Repository
}

// NewHandler creates a notes handler.
func NewHandler(repo Repository) *Handler {
	return &Handler{repo: repo}
}

// List handles GET /notes.
func (h *Handler) List(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}
	notes, err := h.repo.List(r.Context(), userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to list notes")
		return
	}
	writeJSON(w, http.StatusOK, map[string]interface{}{"data": notes})
}

// Create handles POST /notes.
func (h *Handler) Create(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	var req CreateNoteRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	req.Title = strings.TrimSpace(req.Title)
	if req.Title == "" {
		writeError(w, http.StatusBadRequest, "title is required")
		return
	}

	note, err := h.repo.Create(r.Context(), userID, req.Title, req.Content)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to create note")
		return
	}
	writeJSON(w, http.StatusCreated, map[string]interface{}{"data": note})
}

// Get handles GET /notes/{id}.
func (h *Handler) Get(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}
	id := r.PathValue("id")

	note, err := h.repo.GetByID(r.Context(), id, userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to fetch note")
		return
	}
	if note == nil {
		writeError(w, http.StatusNotFound, "note not found")
		return
	}
	writeJSON(w, http.StatusOK, map[string]interface{}{"data": note})
}

// Update handles PATCH /notes/{id}.
func (h *Handler) Update(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}
	id := r.PathValue("id")

	var req UpdateNoteRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	note, err := h.repo.Update(r.Context(), id, userID, req.Title, req.Content)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to update note")
		return
	}
	if note == nil {
		writeError(w, http.StatusNotFound, "note not found or cannot be edited")
		return
	}
	writeJSON(w, http.StatusOK, map[string]interface{}{"data": note})
}

// Delete handles DELETE /notes/{id}.
func (h *Handler) Delete(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}
	id := r.PathValue("id")

	if err := h.repo.Delete(r.Context(), id, userID); err != nil {
		if err == sql.ErrNoRows {
			writeError(w, http.StatusNotFound, "note not found")
			return
		}
		writeError(w, http.StatusInternalServerError, "failed to delete note")
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func writeJSON(w http.ResponseWriter, status int, v interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v) //nolint:errcheck
}

func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]string{"error": msg})
}
