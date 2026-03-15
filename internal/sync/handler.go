// Package sync implements the delta sync engine (pull & push endpoints).
//
// Pull: accepts last_synced_at, returns all workspace records updated after that timestamp.
// Push: accepts client mutations (created/updated/deleted), applies LWW conflict resolution.
package sync

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/Joshua-Omz/scribes/internal/drafts"
	"github.com/Joshua-Omz/scribes/internal/notes"
	"github.com/Joshua-Omz/scribes/internal/posts"
	mw "github.com/Joshua-Omz/scribes/pkg/middleware"
)

// Handler handles sync pull and push endpoints.
type Handler struct {
	notes  *notes.Repository
	drafts *drafts.Repository
	posts  *posts.Repository
}

// NewHandler creates a sync Handler.
func NewHandler(n *notes.Repository, d *drafts.Repository, p *posts.Repository) *Handler {
	return &Handler{notes: n, drafts: d, posts: p}
}

// pullResponse is the payload returned by the pull endpoint.
type pullResponse struct {
	Notes      []*notes.Note   `json:"notes"`
	Drafts     []*drafts.Draft `json:"drafts"`
	Posts      []*posts.Post   `json:"posts"`
	ServerTime time.Time       `json:"server_time"`
}

// Pull returns all records updated after last_synced_at for the authenticated user.
//
// GET /api/sync/pull?last_synced_at=<RFC3339>
func (h *Handler) Pull(w http.ResponseWriter, r *http.Request) {
	claims, _ := mw.ClaimsFromContext(r.Context())

	var since time.Time
	if raw := r.URL.Query().Get("last_synced_at"); raw != "" {
		t, err := time.Parse(time.RFC3339Nano, raw)
		if err != nil {
			writeError(w, http.StatusBadRequest, "last_synced_at must be RFC3339")
			return
		}
		since = t
	}

	n, err := h.notes.ListUpdatedAfter(r.Context(), claims.UserID, since)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "could not fetch notes delta")
		return
	}
	d, err := h.drafts.ListUpdatedAfter(r.Context(), claims.UserID, since)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "could not fetch drafts delta")
		return
	}
	p, err := h.posts.ListUpdatedAfter(r.Context(), since)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "could not fetch posts delta")
		return
	}

	// Guarantee non-nil slices so the client always gets arrays, not null.
	if n == nil {
		n = []*notes.Note{}
	}
	if d == nil {
		d = []*drafts.Draft{}
	}
	if p == nil {
		p = []*posts.Post{}
	}

	writeJSON(w, http.StatusOK, pullResponse{
		Notes:      n,
		Drafts:     d,
		Posts:      p,
		ServerTime: time.Now().UTC(),
	})
}

// pushRequest is the payload accepted by the push endpoint.
type pushRequest struct {
	Notes  []*notes.Note   `json:"notes"`
	Drafts []*drafts.Draft `json:"drafts"`
}

// pushResponse summarises the push result.
type pushResponse struct {
	Applied int       `json:"applied"`
	Skipped int       `json:"skipped"`
	SyncAt  time.Time `json:"sync_at"`
}

// Push accepts client mutations and applies Last-Write-Wins conflict resolution.
//
// POST /api/sync/push
func (h *Handler) Push(w http.ResponseWriter, r *http.Request) {
	claims, _ := mw.ClaimsFromContext(r.Context())

	var req pushRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid push payload")
		return
	}

	applied, skipped := 0, 0

	for _, n := range req.Notes {
		// Enforce ownership – never let a client push to another user's data.
		n.UserID = claims.UserID
		if err := h.notes.Upsert(r.Context(), n); err != nil {
			writeError(w, http.StatusInternalServerError, "could not upsert note")
			return
		}
		applied++
	}
	// drafts – upsert not yet implemented in MVP; count as skipped
	skipped += len(req.Drafts)

	writeJSON(w, http.StatusOK, pushResponse{
		Applied: applied,
		Skipped: skipped,
		SyncAt:  time.Now().UTC(),
	})
}

func writeJSON(w http.ResponseWriter, code int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	_ = json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, code int, msg string) {
	writeJSON(w, code, map[string]string{"error": msg})
}
