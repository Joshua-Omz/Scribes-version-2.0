package notification

import (
	"io"
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

func (h *Handler) GetNotifications(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	userID, _ := uuid.Parse(claims.UserID)

	notifications, err := h.svc.GetForUser(c.Request.Context(), userID)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to get notifications")
		return
	}

	hasUnread, err := h.svc.HasUnread(c.Request.Context(), userID)
	if err != nil {
		// Log error, but don't fail the whole request
		hasUnread = false
	}

	respond.JSON(c, http.StatusOK, gin.H{
		"notifications": notifications,
		"has_unread":    hasUnread,
	})
}

func (h *Handler) MarkAllRead(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	userID, _ := uuid.Parse(claims.UserID)

	if err := h.svc.MarkAllRead(c.Request.Context(), userID); err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to mark notifications as read")
		return
	}
	respond.JSON(c, http.StatusOK, gin.H{"message": "ok"})
}

func (h *Handler) ClearAll(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	userID, _ := uuid.Parse(claims.UserID)

	if err := h.svc.ClearAll(c.Request.Context(), userID); err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to clear notifications")
		return
	}
	respond.JSON(c, http.StatusOK, gin.H{"message": "ok"})
}

type BulkRequest struct {
	IDs []uuid.UUID `json:"ids"`
}

func (h *Handler) BulkDelete(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	userID, _ := uuid.Parse(claims.UserID)

	var req BulkRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := h.svc.DeleteBulk(c.Request.Context(), userID, req.IDs); err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to delete notifications")
		return
	}
	respond.JSON(c, http.StatusOK, gin.H{"message": "ok"})
}

func (h *Handler) BulkRead(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	userID, _ := uuid.Parse(claims.UserID)

	var req BulkRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := h.svc.MarkBulkRead(c.Request.Context(), userID, req.IDs); err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to mark notifications as read")
		return
	}
	respond.JSON(c, http.StatusOK, gin.H{"message": "ok"})
}

func (h *Handler) StreamNotifications(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	userID, _ := uuid.Parse(claims.UserID)

	c.Writer.Header().Set("Content-Type", "text/event-stream")
	c.Writer.Header().Set("Cache-Control", "no-cache")
	c.Writer.Header().Set("Connection", "keep-alive")
	c.Writer.Header().Set("Transfer-Encoding", "chunked")

	ch := h.svc.Subscribe(userID)
	defer h.svc.Unsubscribe(userID, ch)

	clientGone := c.Request.Context().Done()
	c.Stream(func(w io.Writer) bool {
		select {
		case <-clientGone:
			return false
		case msg, ok := <-ch:
			if !ok {
				return false
			}
			c.SSEvent("message", msg)
			return true
		}
	})
}
