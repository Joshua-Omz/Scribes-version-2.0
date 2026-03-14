package users

import (
	"encoding/json"
	"net/http"

	"github.com/Joshua-Omz/scribes/pkg/middleware"
)

// Handler handles user endpoints.
type Handler struct {
	repo Repository
}

// NewHandler creates a users handler.
func NewHandler(repo Repository) *Handler {
	return &Handler{repo: repo}
}

// Me handles GET /users/me.
func (h *Handler) Me(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	user, err := h.repo.GetByID(r.Context(), userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to fetch user")
		return
	}
	if user == nil {
		writeError(w, http.StatusNotFound, "user not found")
		return
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{"data": user})
}

func writeJSON(w http.ResponseWriter, status int, v interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v) //nolint:errcheck
}

func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]string{"error": msg})
}
