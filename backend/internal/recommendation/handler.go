package recommendation

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"scribes-api/pkg/respond"
	"time"
)

type Handler struct {
	svc Service
}

func NewHandler(svc Service) *Handler {
	return &Handler{svc: svc}
}

type RecommendationResponse struct {
	ID             string      `json:"id"`
	AuthorID       string      `json:"author_id"`
	Caption        *string     `json:"caption"`
	Content        interface{} `json:"content"`
	SermonSource   *string     `json:"sermon_source"`
	Visibility     string      `json:"visibility"`
	IsDeleted      bool        `json:"is_deleted"`
	PublishedAt    time.Time   `json:"published_at"`
	AuthorName     string      `json:"author_name"`
	AuthorHandle   string      `json:"author_handle"`
	AuthorIsChurch bool        `json:"author_is_church"`
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

	var mapped []RecommendationResponse
	for _, p := range posts {
		var caption *string
		if p.Caption.Valid {
			caption = &p.Caption.String
		}
		var sermonSource *string
		if p.SermonSource.Valid {
			sermonSource = &p.SermonSource.String
		}
		mapped = append(mapped, RecommendationResponse{
			ID:             p.ID.String(),
			AuthorID:       p.AuthorID.String(),
			Caption:        caption,
			Content:        p.Content,
			SermonSource:   sermonSource,
			Visibility:     string(p.Visibility),
			IsDeleted:      p.IsDeleted,
			PublishedAt:    p.PublishedAt,
			AuthorName:     p.AuthorName,
			AuthorHandle:   p.AuthorHandle,
			AuthorIsChurch: p.AuthorIsChurch,
		})
	}
	if mapped == nil {
		mapped = []RecommendationResponse{}
	}

	respond.JSON(c, http.StatusOK, gin.H{
		"posts": mapped,
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

	var mapped []RecommendationResponse
	for _, p := range posts {
		var caption *string
		if p.Caption.Valid {
			caption = &p.Caption.String
		}
		var sermonSource *string
		if p.SermonSource.Valid {
			sermonSource = &p.SermonSource.String
		}
		mapped = append(mapped, RecommendationResponse{
			ID:             p.ID.String(),
			AuthorID:       p.AuthorID.String(),
			Caption:        caption,
			Content:        p.Content,
			SermonSource:   sermonSource,
			Visibility:     string(p.Visibility),
			IsDeleted:      p.IsDeleted,
			PublishedAt:    p.PublishedAt,
			AuthorName:     p.AuthorName,
			AuthorHandle:   p.AuthorHandle,
			AuthorIsChurch: p.AuthorIsChurch,
		})
	}
	if mapped == nil {
		mapped = []RecommendationResponse{}
	}

	respond.JSON(c, http.StatusOK, gin.H{
		"posts": mapped,
	})
}
