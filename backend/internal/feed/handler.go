package feed

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"scribes-api/internal/middleware"
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

func (h *Handler) GetFollowingFeed(c *gin.Context) {
	authorID, ok := getAuthorID(c)
	if !ok {
		return
	}

	cursor := c.Query("cursor")
	limitStr := c.Query("limit")
	var limit int32 = 20
	if limitStr != "" {
		if l, err := strconv.ParseInt(limitStr, 10, 32); err == nil {
			limit = int32(l)
		}
	}

	res, err := h.svc.GetFollowingFeed(c.Request.Context(), cursor, limit, authorID)
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

	var searchQuery *string
	if sq := c.Query("search_query"); sq != "" {
		searchQuery = &sq
	}

	var scriptureBook *string
	if sb := c.Query("scripture_book"); sb != "" {
		scriptureBook = &sb
	}

	var scriptureChapter *int32
	if sc := c.Query("scripture_chapter"); sc != "" {
		if val, err := strconv.ParseInt(sc, 10, 32); err == nil {
			v32 := int32(val)
			scriptureChapter = &v32
		}
	}

	params := ExploreParams{
		Cursor:          cursor,
		Limit:           limit,
		CategoryID:      categoryID,
		SearchQuery:     searchQuery,
		ScriptureBook:   scriptureBook,
		ScriptureChapter: scriptureChapter,
	}

	res, err := h.svc.GetExplore(c.Request.Context(), params)
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
