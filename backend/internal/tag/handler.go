package tag

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"scribes-api/pkg/respond"
)

type Handler struct {
	service Service
}

func NewHandler(service Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) SuggestTags(c *gin.Context) {
	q := c.Query("q")
	limitStr := c.Query("limit")
	var limit int32 = 10
	if l, err := strconv.ParseInt(limitStr, 10, 32); err == nil {
		limit = int32(l)
	}

	tags, err := h.service.SuggestTags(c.Request.Context(), q, limit)
	if err != nil {
		respond.JSON(c, http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	respond.JSON(c, http.StatusOK, tags)
}

func (h *Handler) GetTrendingTags(c *gin.Context) {
	limitStr := c.Query("limit")
	var limit int32 = 20
	if l, err := strconv.ParseInt(limitStr, 10, 32); err == nil {
		limit = int32(l)
	}

	tags, err := h.service.GetTrendingTags(c.Request.Context(), limit)
	if err != nil {
		respond.JSON(c, http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	respond.JSON(c, http.StatusOK, tags)
}
