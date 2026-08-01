package search

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"scribes-api/pkg/respond"
)

type Handler struct {
	svc Service
}

func NewHandler(svc Service) *Handler {
	return &Handler{svc: svc}
}

func (h *Handler) SearchPosts(c *gin.Context) {
	query := c.Query("q")
	limitStr := c.Query("limit")
	offsetStr := c.Query("offset")

	limit, _ := strconv.Atoi(limitStr)
	if limit == 0 {
		limit = 20
	}
	offset, _ := strconv.Atoi(offsetStr)

	posts, err := h.svc.SearchPosts(c.Request.Context(), query, int32(limit), int32(offset))
	if err != nil {
		respond.JSON(c, http.StatusInternalServerError, gin.H{"error": "failed to search posts"})
		return
	}

	respond.JSON(c, http.StatusOK, gin.H{
		"posts": posts,
	})
}

func (h *Handler) SearchAuthors(c *gin.Context) {
	query := c.Query("q")
	limitStr := c.Query("limit")
	offsetStr := c.Query("offset")

	limit, _ := strconv.Atoi(limitStr)
	if limit == 0 {
		limit = 20
	}
	offset, _ := strconv.Atoi(offsetStr)

	authors, err := h.svc.SearchAuthors(c.Request.Context(), query, int32(limit), int32(offset))
	if err != nil {
		respond.JSON(c, http.StatusInternalServerError, gin.H{"error": "failed to search authors"})
		return
	}

	respond.JSON(c, http.StatusOK, gin.H{
		"authors": authors,
	})
}
