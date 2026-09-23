package bible

import (
	"errors"
	"net/http"
	"strconv"

	"scribes-api/internal/middleware"
	"scribes-api/pkg/respond"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

// GET /bible/translations
func (h *Handler) GetTranslations(c *gin.Context) {
	translations, err := h.service.GetTranslations(c.Request.Context())
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "Failed to retrieve translations")
		return
	}

	respond.JSON(c, http.StatusOK, gin.H{
		"translations": translations,
	})
}

// POST /admin/bible/translations/upload (PROTECTED: super_admin)
func (h *Handler) UploadTranslation(c *gin.Context) {
	var input BibleInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond.Error(c, http.StatusBadRequest, "Invalid JSON structure: "+err.Error())
		return
	}

	if err := h.service.UploadTranslation(c.Request.Context(), input); err != nil {
		respond.Error(c, http.StatusInternalServerError, "Failed to ingest translation: "+err.Error())
		return
	}

	respond.JSON(c, http.StatusOK, gin.H{"message": "Translation uploaded and ingested successfully"})
}

// GET /bible/books
func (h *Handler) GetBooks(c *gin.Context) {
	translation := c.DefaultQuery("translation", "BSB")
	books, err := h.service.GetBooks(c.Request.Context(), translation)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "Failed to retrieve books")
		return
	}

	respond.JSON(c, http.StatusOK, gin.H{
		"translation": translation,
		"books":       books,
	})
}

// GET /bible/:book/:chapter
func (h *Handler) GetChapter(c *gin.Context) {
	translation := c.DefaultQuery("translation", "BSB")
	book := c.Param("book")
	chapterStr := c.Param("chapter")

	chapterNum, err := strconv.Atoi(chapterStr)
	if err != nil || chapterNum <= 0 {
		respond.Error(c, http.StatusBadRequest, "Invalid chapter number")
		return
	}

	res, err := h.service.GetChapter(c.Request.Context(), translation, book, chapterNum)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			respond.Error(c, http.StatusNotFound, "Book or chapter not found")
			return
		}
		respond.Error(c, http.StatusInternalServerError, "Failed to retrieve chapter")
		return
	}

	respond.JSON(c, http.StatusOK, res)
}

// GET /bible/:book/:chapter/:verseRange
func (h *Handler) GetVerseRange(c *gin.Context) {
	translation := c.DefaultQuery("translation", "BSB")
	book := c.Param("book")
	chapterStr := c.Param("chapter")
	verseRangeStr := c.Param("verseRange")

	chapterNum, err := strconv.Atoi(chapterStr)
	if err != nil || chapterNum <= 0 {
		respond.Error(c, http.StatusBadRequest, "Invalid chapter number")
		return
	}

	res, err := h.service.GetVerseRange(c.Request.Context(), translation, book, chapterNum, verseRangeStr)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			respond.Error(c, http.StatusNotFound, "Verses not found")
			return
		}
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}

	respond.JSON(c, http.StatusOK, res)
}

// GET /bible/search?q=...&limit=...
func (h *Handler) Search(c *gin.Context) {
	translation := c.DefaultQuery("translation", "BSB")
	query := c.Query("q")
	limitStr := c.DefaultQuery("limit", "20")

	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit <= 0 {
		limit = 20
	}

	if query == "" {
		respond.JSON(c, http.StatusOK, gin.H{
			"translation": translation,
			"query":       query,
			"results":     []SearchResultItem{},
		})
		return
	}

	results, err := h.service.Search(c.Request.Context(), translation, query, limit)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "Failed to search verses")
		return
	}

	respond.JSON(c, http.StatusOK, gin.H{
		"translation": translation,
		"query":       query,
		"results":     results,
	})
}

type saveReadingPositionInput struct {
	Book        string `json:"book"`
	BookCode    string `json:"book_code"`
	Chapter     int    `json:"chapter" binding:"required"`
	Verse       int    `json:"verse"`
	Translation string `json:"translation"`
}

func getUserID(c *gin.Context) (uuid.UUID, bool) {
	claims, ok := middleware.ClaimsFromCtx(c.Request.Context())
	if !ok {
		respond.Error(c, http.StatusUnauthorized, "unauthorized")
		return uuid.Nil, false
	}

	userID, err := uuid.Parse(claims.UserID)
	if err != nil {
		respond.Error(c, http.StatusUnauthorized, "invalid user ID in token")
		return uuid.Nil, false
	}

	return userID, true
}

// POST /bible/reading-position (PROTECTED)
func (h *Handler) SaveReadingPosition(c *gin.Context) {
	userID, ok := getUserID(c)
	if !ok {
		return
	}

	var input saveReadingPositionInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond.Error(c, http.StatusBadRequest, "Invalid input: "+err.Error())
		return
	}

	bookIdentifier := input.BookCode
	if bookIdentifier == "" {
		bookIdentifier = input.Book
	}
	if bookIdentifier == "" {
		respond.Error(c, http.StatusBadRequest, "book or book_code is required")
		return
	}

	translation := input.Translation
	if translation == "" {
		translation = "BSB"
	}
	verse := input.Verse
	if verse <= 0 {
		verse = 1
	}

	if err := h.service.SaveReadingPosition(c.Request.Context(), userID, translation, bookIdentifier, input.Chapter, verse); err != nil {
		if errors.Is(err, ErrNotFound) {
			respond.Error(c, http.StatusNotFound, "Book not found")
			return
		}
		respond.Error(c, http.StatusInternalServerError, "Failed to save reading position")
		return
	}

	respond.JSON(c, http.StatusOK, gin.H{"message": "saved"})
}

// GET /bible/reading-position (PROTECTED)
func (h *Handler) GetReadingPosition(c *gin.Context) {
	userID, ok := getUserID(c)
	if !ok {
		return
	}

	pos, err := h.service.GetReadingPosition(c.Request.Context(), userID)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			respond.Error(c, http.StatusNotFound, "No reading position found")
			return
		}
		respond.Error(c, http.StatusInternalServerError, "Failed to get reading position")
		return
	}

	respond.JSON(c, http.StatusOK, pos)
}
