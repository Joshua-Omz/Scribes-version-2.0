package note

import (
	"errors"
	"net/http"

	"scribes-api/internal/middleware"
	"scribes-api/pkg/respond"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type Handler struct {
	svc *Service
}

func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}


// getAuthorID is a small helper to pull the authenticated user's ID
// securely from the JWT claims populated by our middleware.
func getAuthorID(c *gin.Context) (uuid.UUID, bool) {
	claims, ok := middleware.ClaimsFromCtx(c.Request.Context())
	if !ok {
		respond.Error(c, http.StatusUnauthorized, "unauthorized")
		return uuid.Nil, false
	}

	authorID, err := uuid.Parse(claims.UserID)
	if err != nil {
		respond.Error(c, http.StatusUnauthorized, "invalid user ID in token")
		return uuid.Nil, false
	}

	return authorID, true
}

func (h *Handler) List(c *gin.Context) {
	authorID, ok := getAuthorID(c)
	if !ok {
		return
	}

	notes, err := h.svc.List(c.Request.Context(), authorID)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to fetch notes")
		return
	}

	respond.JSON(c, http.StatusOK, notes)
}

func (h *Handler) Create(c *gin.Context) {
	authorID, ok := getAuthorID(c)
	if !ok {
		return
	}

	var input CreateInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid json payload")
		return
	}

	note, err := h.svc.Create(c.Request.Context(), authorID, input)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to create note")
		return
	}

	respond.JSON(c, http.StatusCreated, note)
}

func (h *Handler) Update(c *gin.Context) {
	authorID, ok := getAuthorID(c)
	if !ok {
		return
	}

	idParam := c.Param("id")
	noteID, err := uuid.Parse(idParam)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid note id")
		return
	}

	var input CreateInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid json payload")
		return
	}

	note, err := h.svc.Update(c.Request.Context(), authorID, noteID, input)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			respond.Error(c, http.StatusNotFound, "note not found")
			return
		}
		if errors.Is(err, ErrUnauthorized) {
			respond.Error(c, http.StatusForbidden, "unauthorized to modify this note")
			return
		}
		respond.Error(c, http.StatusInternalServerError, "failed to update note")
		return
	}

	respond.JSON(c, http.StatusOK, note)
}

func (h *Handler) Delete(c *gin.Context) {
	authorID, ok := getAuthorID(c)
	if !ok {
		return
	}

	idParam := c.Param("id")
	noteID, err := uuid.Parse(idParam)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid note id")
		return
	}

	err = h.svc.Delete(c.Request.Context(), authorID, noteID)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			respond.Error(c, http.StatusNotFound, "note not found")
			return
		}
		if errors.Is(err, ErrUnauthorized) {
			respond.Error(c, http.StatusForbidden, "unauthorized to delete this note")
			return
		}
		respond.Error(c, http.StatusInternalServerError, "failed to delete note")
		return
	}

	c.Status(http.StatusNoContent)
}

func (h *Handler) Promote(c *gin.Context) {
	authorID, ok := getAuthorID(c)
	if !ok {
		return
	}

	idParam := c.Param("id")
	noteID, err := uuid.Parse(idParam)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid note id")
		return
	}

	draftID, err := h.svc.Promote(c.Request.Context(), authorID, noteID)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			respond.Error(c, http.StatusNotFound, "note not found")
			return
		}
		if errors.Is(err, ErrUnauthorized) {
			respond.Error(c, http.StatusForbidden, "unauthorized to promote this note")
			return
		}
		if err.Error() == "draft creation is not configured" {
			respond.Error(c, http.StatusNotImplemented, "feature not fully configured")
			return
		}
		respond.Error(c, http.StatusInternalServerError, "failed to promote note to draft")
		return
	}

	respond.JSON(c, http.StatusCreated, gin.H{
		"message":  "Note promoted to draft",
		"draft_id": draftID,
	})
}
