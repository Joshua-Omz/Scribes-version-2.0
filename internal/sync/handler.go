package sync

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/Joshua-Omz/scribes/pkg/middleware"
)

// Handler handles the sync endpoint.
type Handler struct {
	repo Repository
}

// NewHandler creates a sync handler.
func NewHandler(repo Repository) *Handler {
	return &Handler{repo: repo}
}

// Delta handles GET /sync.
// Accepts query param last_synced_at (RFC3339). Defaults to zero time (full sync).
func (h *Handler) Delta(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	var since time.Time
	if raw := r.URL.Query().Get("last_synced_at"); raw != "" {
		t, err := time.Parse(time.RFC3339, raw)
		if err != nil {
			writeError(w, http.StatusBadRequest, "last_synced_at must be RFC3339 format")
			return
		}
		since = t
	}

	resp, err := h.repo.Delta(r.Context(), userID, since)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to sync")
		return
	}
	writeJSON(w, http.StatusOK, map[string]interface{}{"data": resp})
}

func writeJSON(w http.ResponseWriter, status int, v interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v) //nolint:errcheck
}

func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]string{"error": msg})
}
