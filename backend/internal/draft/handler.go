package draft

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

	drafts, err := h.svc.List(c.Request.Context(), authorID)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to fetch drafts")
		return
	}

	respond.JSON(c, http.StatusOK, drafts)
}

func (h *Handler) Get(c *gin.Context) {
	authorID, ok := getAuthorID(c)
	if !ok {
		return
	}

	idParam := c.Param("id")
	draftID, err := uuid.Parse(idParam)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid draft id")
		return
	}

	draft, err := h.svc.GetByID(c.Request.Context(), authorID, draftID)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			respond.Error(c, http.StatusNotFound, "draft not found")
			return
		}
		if errors.Is(err, ErrUnauthorized) {
			respond.Error(c, http.StatusForbidden, "unauthorized to view this draft")
			return
		}
		respond.Error(c, http.StatusInternalServerError, "failed to fetch draft")
		return
	}

	respond.JSON(c, http.StatusOK, draft)
}

func (h *Handler) Create(c *gin.Context) {
	authorID, ok := getAuthorID(c)
	if !ok {
		return
	}

	var input CreateInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid json payload: "+err.Error())
		return
	}

	draft, err := h.svc.Create(c.Request.Context(), authorID, input)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to create draft")
		return
	}

	respond.JSON(c, http.StatusCreated, draft)
}

func (h *Handler) Update(c *gin.Context) {
	authorID, ok := getAuthorID(c)
	if !ok {
		return
	}

	idParam := c.Param("id")
	draftID, err := uuid.Parse(idParam)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid draft id")
		return
	}

	var input CreateInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid json payload: "+err.Error())
		return
	}

	draft, err := h.svc.Update(c.Request.Context(), authorID, draftID, input)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			respond.Error(c, http.StatusNotFound, "draft not found")
			return
		}
		if errors.Is(err, ErrUnauthorized) {
			respond.Error(c, http.StatusForbidden, "unauthorized to modify this draft")
			return
		}
		respond.Error(c, http.StatusInternalServerError, "failed to update draft")
		return
	}

	respond.JSON(c, http.StatusOK, draft)
}

func (h *Handler) Delete(c *gin.Context) {
	authorID, ok := getAuthorID(c)
	if !ok {
		return
	}

	idParam := c.Param("id")
	draftID, err := uuid.Parse(idParam)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid draft id")
		return
	}

	err = h.svc.Delete(c.Request.Context(), authorID, draftID)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			respond.Error(c, http.StatusNotFound, "draft not found")
			return
		}
		if errors.Is(err, ErrUnauthorized) {
			respond.Error(c, http.StatusForbidden, "unauthorized to delete this draft")
			return
		}
		respond.Error(c, http.StatusInternalServerError, "failed to delete draft")
		return
	}

	c.Status(http.StatusNoContent)
}

func (h *Handler) Publish(c *gin.Context) {
	authorID, ok := getAuthorID(c)
	if !ok {
		return
	}

	idParam := c.Param("id")
	draftID, err := uuid.Parse(idParam)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid draft id")
		return
	}

	post, err := h.svc.Publish(c.Request.Context(), authorID, draftID)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			respond.Error(c, http.StatusNotFound, "draft not found")
			return
		}
		if errors.Is(err, ErrUnauthorized) {
			respond.Error(c, http.StatusForbidden, "unauthorized to publish this draft")
			return
		}
		respond.Error(c, http.StatusInternalServerError, "failed to publish draft")
		return
	}

	respond.JSON(c, http.StatusCreated, post)
}
