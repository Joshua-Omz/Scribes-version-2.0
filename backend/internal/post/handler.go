package post

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
	svc *Service
}

func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// getAuthorID extracts the authenticated user's ID from the JWT claims.
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

	post, err := h.svc.Create(c.Request.Context(), authorID, input)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to create post")
		return
	}

	respond.JSON(c, http.StatusCreated, post)
}

// GetByID is the PUBLIC endpoint — no auth required.
// Anyone can read a public post. The handler itself doesn't check ownership.
func (h *Handler) GetByID(c *gin.Context) {
	idParam := c.Param("id")
	postID, err := uuid.Parse(idParam)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid post id")
		return
	}

	post, err := h.svc.Get(c.Request.Context(), postID)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			respond.Error(c, http.StatusNotFound, "post not found")
			return
		}
		respond.Error(c, http.StatusInternalServerError, "failed to fetch post")
		return
	}

	respond.JSON(c, http.StatusOK, post)
}

func (h *Handler) List(c *gin.Context) {
	authorID, ok := getAuthorID(c)
	if !ok {
		return
	}

	posts, err := h.svc.List(c.Request.Context(), authorID)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to fetch posts")
		return
	}

	respond.JSON(c, http.StatusOK, posts)
}

func (h *Handler) ListByAuthor(c *gin.Context) {
	authorIDParam := c.Param("id")
	authorID, err := uuid.Parse(authorIDParam)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid author id")
		return
	}

	posts, err := h.svc.List(c.Request.Context(), authorID)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to fetch posts")
		return
	}

	respond.JSON(c, http.StatusOK, posts)
}

func (h *Handler) Update(c *gin.Context) {
	authorID, ok := getAuthorID(c)
	if !ok {
		return
	}

	idParam := c.Param("id")
	postID, err := uuid.Parse(idParam)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid post id")
		return
	}

	var input CreateInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid json payload")
		return
	}

	post, err := h.svc.Update(c.Request.Context(), authorID, postID, input)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			respond.Error(c, http.StatusNotFound, "post not found")
			return
		}
		if errors.Is(err, ErrUnauthorized) {
			respond.Error(c, http.StatusForbidden, "unauthorized to modify this post")
			return
		}
		respond.Error(c, http.StatusInternalServerError, "failed to update post")
		return
	}

	respond.JSON(c, http.StatusOK, post)
}

func (h *Handler) Delete(c *gin.Context) {
	authorID, ok := getAuthorID(c)
	if !ok {
		return
	}

	idParam := c.Param("id")
	postID, err := uuid.Parse(idParam)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid post id")
		return
	}

	err = h.svc.Delete(c.Request.Context(), authorID, postID)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			respond.Error(c, http.StatusNotFound, "post not found")
			return
		}
		if errors.Is(err, ErrUnauthorized) {
			respond.Error(c, http.StatusForbidden, "unauthorized to delete this post")
			return
		}
		respond.Error(c, http.StatusInternalServerError, "failed to delete post")
		return
	}

	c.Status(http.StatusNoContent)
}

func (h *Handler) Revise(c *gin.Context) {
	authorID, ok := getAuthorID(c)
	if !ok {
		return
	}

	idParam := c.Param("id")
	postID, err := uuid.Parse(idParam)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid post id")
		return
	}

	var input ReviseInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid json payload")
		return
	}

	post, err := h.svc.Revise(c.Request.Context(), authorID, postID, input)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			respond.Error(c, http.StatusNotFound, "post not found")
			return
		}
		if errors.Is(err, ErrUnauthorized) {
			respond.Error(c, http.StatusForbidden, "unauthorized to revise this post")
			return
		}
		respond.Error(c, http.StatusInternalServerError, "failed to revise post")
		return
	}

	respond.JSON(c, http.StatusOK, post)
}

func (h *Handler) CreateCorrection(c *gin.Context) {
	authorID, ok := getAuthorID(c)
	if !ok {
		return
	}

	idParam := c.Param("id")
	correctsPostID, err := uuid.Parse(idParam)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid original post id")
		return
	}

	var input CreateInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid json payload")
		return
	}

	post, err := h.svc.CreateCorrection(c.Request.Context(), authorID, correctsPostID, input)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			respond.Error(c, http.StatusNotFound, "original post not found")
			return
		}
		respond.Error(c, http.StatusInternalServerError, "failed to create correction post")
		return
	}

	respond.JSON(c, http.StatusCreated, post)
}

func (h *Handler) ListVersions(c *gin.Context) {
	idParam := c.Param("id")
	postID, err := uuid.Parse(idParam)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid post id")
		return
	}

	versions, err := h.svc.ListVersions(c.Request.Context(), postID)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to fetch versions")
		return
	}

	respond.JSON(c, http.StatusOK, versions)
}

func (h *Handler) GetVersion(c *gin.Context) {
	idParam := c.Param("id")
	postID, err := uuid.Parse(idParam)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid post id")
		return
	}

	versionParam := c.Param("version")
	versionInt, err := strconv.ParseInt(versionParam, 10, 32)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid version number")
		return
	}

	versionInfo, err := h.svc.GetVersion(c.Request.Context(), postID, int32(versionInt))
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			respond.Error(c, http.StatusNotFound, "version not found")
			return
		}
		respond.Error(c, http.StatusInternalServerError, "failed to fetch version")
		return
	}

	respond.JSON(c, http.StatusOK, versionInfo)
}
