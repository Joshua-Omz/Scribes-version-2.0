package social

import (
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

func (h *Handler) Follow(c *gin.Context) {
	claims, ok := middleware.ClaimsFromCtx(c.Request.Context())
	if !ok {
		respond.Error(c, http.StatusUnauthorized, "unauthorized")
		return
	}
	followerID, _ := uuid.Parse(claims.UserID)
	followeeID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid user id")
		return
	}

	if err := h.svc.Follow(c.Request.Context(), followerID, followeeID); err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	respond.JSON(c, http.StatusOK, gin.H{"status": "followed"})
}

func (h *Handler) Unfollow(c *gin.Context) {
	claims, ok := middleware.ClaimsFromCtx(c.Request.Context())
	if !ok {
		respond.Error(c, http.StatusUnauthorized, "unauthorized")
		return
	}
	followerID, _ := uuid.Parse(claims.UserID)
	followeeID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid user id")
		return
	}

	if err := h.svc.Unfollow(c.Request.Context(), followerID, followeeID); err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to unfollow")
		return
	}
	respond.JSON(c, http.StatusOK, gin.H{"status": "unfollowed"})
}

type ReactRequest struct {
	Type string `json:"type" binding:"required"`
}

func (h *Handler) React(c *gin.Context) {
	claims, ok := middleware.ClaimsFromCtx(c.Request.Context())
	if !ok {
		respond.Error(c, http.StatusUnauthorized, "unauthorized")
		return
	}
	userID, _ := uuid.Parse(claims.UserID)
	postID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid post id")
		return
	}

	var req ReactRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}

	if err := h.svc.React(c.Request.Context(), postID, userID, req.Type); err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to react")
		return
	}
	respond.JSON(c, http.StatusOK, gin.H{"status": "reacted"})
}

func (h *Handler) Unreact(c *gin.Context) {
	claims, ok := middleware.ClaimsFromCtx(c.Request.Context())
	if !ok {
		respond.Error(c, http.StatusUnauthorized, "unauthorized")
		return
	}
	userID, _ := uuid.Parse(claims.UserID)
	postID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid post id")
		return
	}

	if err := h.svc.Unreact(c.Request.Context(), postID, userID); err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to unreact")
		return
	}
	respond.JSON(c, http.StatusOK, gin.H{"status": "unreacted"})
}

type CommentRequest struct {
	Body     string   `json:"body" binding:"required"`
	Mentions []string `json:"mentions"`
}

func (h *Handler) AddComment(c *gin.Context) {
	claims, ok := middleware.ClaimsFromCtx(c.Request.Context())
	if !ok {
		respond.Error(c, http.StatusUnauthorized, "unauthorized")
		return
	}
	authorID, _ := uuid.Parse(claims.UserID)
	postID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid post id")
		return
	}

	var req CommentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}

	var mentions []uuid.UUID
	for _, m := range req.Mentions {
		if uid, err := uuid.Parse(m); err == nil {
			mentions = append(mentions, uid)
		}
	}

	comment, err := h.svc.AddComment(c.Request.Context(), postID, authorID, req.Body, mentions)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to add comment")
		return
	}
	respond.JSON(c, http.StatusCreated, comment)
}

func (h *Handler) GetComments(c *gin.Context) {
	postID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid post id")
		return
	}

	comments, err := h.svc.GetComments(c.Request.Context(), postID)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to fetch comments")
		return
	}
	respond.JSON(c, http.StatusOK, comments)
}

type PatchCommentRequest struct {
	Action string `json:"action" binding:"required"` // hide or delete
}

func (h *Handler) PatchComment(c *gin.Context) {
	claims, ok := middleware.ClaimsFromCtx(c.Request.Context())
	if !ok {
		respond.Error(c, http.StatusUnauthorized, "unauthorized")
		return
	}
	userID, _ := uuid.Parse(claims.UserID)
	commentID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid comment id")
		return
	}

	var req PatchCommentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}

	switch req.Action {
	case "hide":
		err = h.svc.HideComment(c.Request.Context(), commentID, userID)
	case "delete":
		err = h.svc.DeleteComment(c.Request.Context(), commentID, userID)
	default:
		respond.Error(c, http.StatusBadRequest, "invalid action")
		return
	}

	if err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	respond.JSON(c, http.StatusOK, gin.H{"status": req.Action + "d"})
}

type SaveRequest struct {
	Type string `json:"type" binding:"required"`
}

func (h *Handler) SavePost(c *gin.Context) {
	claims, ok := middleware.ClaimsFromCtx(c.Request.Context())
	if !ok {
		respond.Error(c, http.StatusUnauthorized, "unauthorized")
		return
	}
	userID, _ := uuid.Parse(claims.UserID)
	postID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid post id")
		return
	}

	var req SaveRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}

	if err := h.svc.SavePost(c.Request.Context(), userID, postID, req.Type); err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to save post")
		return
	}
	respond.JSON(c, http.StatusOK, gin.H{"status": "saved"})
}

func (h *Handler) UnsavePost(c *gin.Context) {
	claims, ok := middleware.ClaimsFromCtx(c.Request.Context())
	if !ok {
		respond.Error(c, http.StatusUnauthorized, "unauthorized")
		return
	}
	userID, _ := uuid.Parse(claims.UserID)
	postID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid post id")
		return
	}

	var req SaveRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}

	if err := h.svc.UnsavePost(c.Request.Context(), userID, postID, req.Type); err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to unsave post")
		return
	}
	respond.JSON(c, http.StatusOK, gin.H{"status": "unsaved"})
}
