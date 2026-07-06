package feed

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"scribes-api/pkg/respond"
)

type Handler struct {
	svc *Service
}

func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

func (h *Handler) GetFeed(c *gin.Context) {
	// The feed endpoint should technically be authenticated, but we handle it just like explore for now
	// as per the implementation plan (no follows yet).

	cursor := c.Query("cursor")
	limitStr := c.Query("limit")
	var limit int32 = 20
	if limitStr != "" {
		if l, err := strconv.ParseInt(limitStr, 10, 32); err == nil {
			limit = int32(l)
		}
	}

	res, err := h.svc.GetFeed(c.Request.Context(), cursor, limit)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid request")
		return
	}

	respond.JSON(c, http.StatusOK, res)
}

func (h *Handler) GetExplore(c *gin.Context) {
	cursor := c.Query("cursor")
	limitStr := c.Query("limit")
	var limit int32 = 20
	if limitStr != "" {
		if l, err := strconv.ParseInt(limitStr, 10, 32); err == nil {
			limit = int32(l)
		}
	}

	categoryStr := c.Query("category_id")
	var categoryID *uuid.UUID
	if categoryStr != "" {
		id, err := uuid.Parse(categoryStr)
		if err == nil {
			categoryID = &id
		} else {
			respond.Error(c, http.StatusBadRequest, "invalid category_id")
			return
		}
	}

	res, err := h.svc.GetExplore(c.Request.Context(), cursor, limit, categoryID)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid request")
		return
	}

	respond.JSON(c, http.StatusOK, res)
}

func (h *Handler) GetCategories(c *gin.Context) {
	cats, err := h.svc.ListCategories(c.Request.Context())
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to load categories")
		return
	}
	respond.JSON(c, http.StatusOK, cats)
}
