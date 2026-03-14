package interactions

import (
	"encoding/json"
	"errors"
	"net/http"
	"strings"

	"github.com/Joshua-Omz/scribes/pkg/middleware"
)

// Handler handles interaction endpoints.
type Handler struct {
	repo Repository
}

// NewHandler creates an interactions handler.
func NewHandler(repo Repository) *Handler {
	return &Handler{repo: repo}
}

// AddComment handles POST /posts/{id}/comments.
func (h *Handler) AddComment(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}
	postID := r.PathValue("id")

	var req CreateCommentRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	req.Content = strings.TrimSpace(req.Content)
	if req.Content == "" {
		writeError(w, http.StatusBadRequest, "content is required")
		return
	}

	comment, err := h.repo.AddComment(r.Context(), postID, userID, req.Content)
	if err != nil {
		if errors.Is(err, ErrPostNotFound) {
			writeError(w, http.StatusNotFound, "post not found")
			return
		}
		writeError(w, http.StatusInternalServerError, "failed to add comment")
		return
	}
	writeJSON(w, http.StatusCreated, map[string]interface{}{"data": comment})
}

// ListComments handles GET /posts/{id}/comments.
func (h *Handler) ListComments(w http.ResponseWriter, r *http.Request) {
	postID := r.PathValue("id")
	comments, err := h.repo.ListComments(r.Context(), postID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to list comments")
		return
	}
	writeJSON(w, http.StatusOK, map[string]interface{}{"data": comments})
}

// ToggleReaction handles POST /posts/{id}/reactions.
func (h *Handler) ToggleReaction(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}
	postID := r.PathValue("id")

	var req CreateReactionRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if req.ReactionType == "" {
		writeError(w, http.StatusBadRequest, "reaction_type is required")
		return
	}

	added, err := h.repo.ToggleReaction(r.Context(), postID, userID, req.ReactionType)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to toggle reaction")
		return
	}
	status := http.StatusCreated
	if !added {
		status = http.StatusOK
	}
	writeJSON(w, status, map[string]interface{}{"data": map[string]bool{"added": added}})
}

// ToggleBookmark handles POST /posts/{id}/bookmarks.
func (h *Handler) ToggleBookmark(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}
	postID := r.PathValue("id")

	added, err := h.repo.ToggleBookmark(r.Context(), postID, userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to toggle bookmark")
		return
	}
	status := http.StatusCreated
	if !added {
		status = http.StatusOK
	}
	writeJSON(w, status, map[string]interface{}{"data": map[string]bool{"added": added}})
}

// ImportPost handles POST /posts/{id}/imports.
func (h *Handler) ImportPost(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}
	postID := r.PathValue("id")

	imp, err := h.repo.ImportPost(r.Context(), postID, userID)
	if err != nil {
		switch {
		case errors.Is(err, ErrPostNotFound):
			writeError(w, http.StatusNotFound, "post not found")
		case errors.Is(err, ErrAlreadyImported):
			writeError(w, http.StatusConflict, "post already imported")
		default:
			writeError(w, http.StatusInternalServerError, "failed to import post")
		}
		return
	}
	writeJSON(w, http.StatusCreated, map[string]interface{}{"data": imp})
}

func writeJSON(w http.ResponseWriter, status int, v interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v) //nolint:errcheck
}

func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]string{"error": msg})
}
