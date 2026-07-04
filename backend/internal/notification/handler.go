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

func (h *Handler) GetUnreadNotifications(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	userID, _ := uuid.Parse(claims.UserID)

	notifications, err := h.svc.GetUnreadNotifications(c.Request.Context(), userID)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to get notifications")
		return
	}
	respond.JSON(c, http.StatusOK, notifications)
}

func (h *Handler) MarkAsRead(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	userID, _ := uuid.Parse(claims.UserID)

	notifID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid notification id")
		return
	}

	if err := h.svc.MarkAsRead(c.Request.Context(), notifID, userID); err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	respond.JSON(c, http.StatusOK, gin.H{"status": "marked read"})
}
