package notification

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
