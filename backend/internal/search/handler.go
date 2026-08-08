package search

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"scribes-api/pkg/respond"
)

type Handler struct {
	svc Service
}

func NewHandler(svc Service) *Handler {
	return &Handler{svc: svc}
}

type SearchPostResponse struct {
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
	CurrentVersion int32       `json:"current_version"`
	IsCorrection   bool        `json:"is_correction"`
	KeywordScore   float64     `json:"keyword_score"`
	SemanticScore  float64     `json:"semantic_score"`
	RrfScore       float64     `json:"rrf_score"`
}

type SearchAuthorResponse struct {
	ID          string    `json:"id"`
	Handle      string    `json:"handle"`
	DisplayName string    `json:"display_name"`
	Email       string    `json:"email"`
	Bio         *string   `json:"bio"`
	IsChurch    bool      `json:"is_church"`
	CreatedAt   time.Time `json:"created_at"`
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

	posts, err := h.svc.SearchPosts(c.Request.Context(), query, int32(limit), int32(offset), scriptureBook, scriptureChapter)
	if err != nil {
		respond.JSON(c, http.StatusInternalServerError, gin.H{"error": "failed to search posts"})
		return
	}

	var mapped []SearchPostResponse
	for _, p := range posts {
		var caption *string
		if p.Caption.Valid {
			caption = &p.Caption.String
		}
		var sermonSource *string
		if p.SermonSource.Valid {
			sermonSource = &p.SermonSource.String
		}
		mapped = append(mapped, SearchPostResponse{
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
			CurrentVersion: p.CurrentVersion,
			IsCorrection:   p.IsCorrection,
			KeywordScore:   p.KeywordScore,
			SemanticScore:  p.SemanticScore,
			RrfScore:       p.RrfScore,
		})
	}
    if mapped == nil {
        mapped = []SearchPostResponse{}
    }

	respond.JSON(c, http.StatusOK, gin.H{
		"posts": mapped,
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

	var mapped []SearchAuthorResponse
	for _, a := range authors {
		var bio *string
		if a.Bio.Valid {
			bio = &a.Bio.String
		}
		mapped = append(mapped, SearchAuthorResponse{
			ID:          a.ID.String(),
			Handle:      a.Handle,
			DisplayName: a.DisplayName,
			Email:       a.Email,
			Bio:         bio,
			IsChurch:    a.IsChurch,
			CreatedAt:   a.CreatedAt,
		})
	}
    if mapped == nil {
        mapped = []SearchAuthorResponse{}
    }

	respond.JSON(c, http.StatusOK, gin.H{
		"authors": mapped,
	})
}
