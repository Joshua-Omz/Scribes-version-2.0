package recommendation

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"scribes-api/pkg/respond"
)

type Handler struct {
	svc Service
}

func NewHandler(svc Service) *Handler {
	return &Handler{svc: svc}
}

func (h *Handler) GetRecommendations(c *gin.Context) {
	sortType := c.Query("sort")
	if sortType == "" {
		sortType = "overall"
	}
	limitStr := c.Query("limit")
	offsetStr := c.Query("offset")

	limit, _ := strconv.Atoi(limitStr)
	if limit == 0 {
		limit = 20
	}
	offset, _ := strconv.Atoi(offsetStr)

	posts, err := h.svc.GetRecommendationsByType(c.Request.Context(), sortType, int32(limit), int32(offset))
	if err != nil {
		respond.JSON(c, http.StatusInternalServerError, gin.H{"error": "failed to get recommendations"})
		return
	}

	respond.JSON(c, http.StatusOK, gin.H{
		"posts": posts,
	})
}

func (h *Handler) GetSimilarPosts(c *gin.Context) {
	postIDStr := c.Param("id")
	postID, err := uuid.Parse(postIDStr)
	if err != nil {
		respond.JSON(c, http.StatusBadRequest, gin.H{"error": "invalid post id"})
		return
	}

	limitStr := c.Query("limit")
	limit, _ := strconv.Atoi(limitStr)
	if limit == 0 {
		limit = 5
	}

	posts, err := h.svc.GetSemanticallySimilarPosts(c.Request.Context(), postID, int32(limit))
	if err != nil {
		respond.JSON(c, http.StatusInternalServerError, gin.H{"error": "failed to get similar posts"})
		return
	}

	respond.JSON(c, http.StatusOK, gin.H{
		"posts": posts,
	})
}
