// Package notes HTTP handlers for the notes resource.
package notes

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"

	mw "github.com/Joshua-Omz/scribes/pkg/middleware"
)

// Handler handles HTTP requests for notes.
type Handler struct {
	repo *Repository
}

// NewHandler creates a notes Handler.
func NewHandler(repo *Repository) *Handler { return &Handler{repo: repo} }

type noteRequest struct {
	Title string `json:"title"`
	Body  string `json:"body"`
}

// List returns all non-deleted notes for the authenticated user.
func (h *Handler) List(w http.ResponseWriter, r *http.Request) {
	claims, _ := mw.ClaimsFromContext(r.Context())
	notes, err := h.repo.List(r.Context(), claims.UserID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "could not list notes")
		return
	}
	writeJSON(w, http.StatusOK, notes)
}

// Create creates a new note.
func (h *Handler) Create(w http.ResponseWriter, r *http.Request) {
	claims, _ := mw.ClaimsFromContext(r.Context())
	var req noteRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	note, err := h.repo.Create(r.Context(), claims.UserID, req.Title, req.Body)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "could not create note")
		return
	}
	writeJSON(w, http.StatusCreated, note)
}

// Get returns a single note by ID.
func (h *Handler) Get(w http.ResponseWriter, r *http.Request) {
	claims, _ := mw.ClaimsFromContext(r.Context())
	id := chi.URLParam(r, "id")
	note, err := h.repo.GetByID(r.Context(), id, claims.UserID)
	if err != nil {
		writeError(w, http.StatusNotFound, "note not found")
		return
	}
	writeJSON(w, http.StatusOK, note)
}

// Update replaces title/body of an existing note.
func (h *Handler) Update(w http.ResponseWriter, r *http.Request) {
	claims, _ := mw.ClaimsFromContext(r.Context())
	id := chi.URLParam(r, "id")
	var req noteRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	note, err := h.repo.Update(r.Context(), id, claims.UserID, req.Title, req.Body)
	if err != nil {
		writeError(w, http.StatusNotFound, "note not found")
		return
	}
	writeJSON(w, http.StatusOK, note)
}

// Delete soft-deletes a note.
func (h *Handler) Delete(w http.ResponseWriter, r *http.Request) {
	claims, _ := mw.ClaimsFromContext(r.Context())
	id := chi.URLParam(r, "id")
	if err := h.repo.SoftDelete(r.Context(), id, claims.UserID); err != nil {
		writeError(w, http.StatusNotFound, "note not found")
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
