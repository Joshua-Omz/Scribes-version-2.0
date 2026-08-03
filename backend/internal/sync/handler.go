package sync

import (
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

func (h *Handler) Pull(c *gin.Context) {
	claims, ok := middleware.ClaimsFromCtx(c.Request.Context())
	if !ok {
		respond.Error(c, http.StatusUnauthorized, "unauthorized")
		return
	}

	authorID, err := uuid.Parse(claims.UserID)
	if err != nil {
		respond.Error(c, http.StatusUnauthorized, "invalid user ID")
		return
	}

	seqStr := c.Query("seq")
	var lastSeq int64 = 0
	if seqStr != "" {
		seq, err := strconv.ParseInt(seqStr, 10, 64)
		if err != nil {
			respond.Error(c, http.StatusBadRequest, "invalid seq parameter")
			return
		}
		lastSeq = seq
	}

	events, err := h.svc.Pull(c.Request.Context(), authorID, lastSeq)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to pull sync events")
		return
	}

	// If no events, return empty array instead of null
	if events == nil {
		events = []SyncEvent{}
	}

	respond.JSON(c, http.StatusOK, events)
}

type pushRequest struct {
	Events []SyncPushEvent `json:"events" binding:"required"`
}

func (h *Handler) Push(c *gin.Context) {
	claims, ok := middleware.ClaimsFromCtx(c.Request.Context())
	if !ok {
		respond.Error(c, http.StatusUnauthorized, "unauthorized")
		return
	}

	authorID, err := uuid.Parse(claims.UserID)
	if err != nil {
		respond.Error(c, http.StatusUnauthorized, "invalid user ID")
		return
	}

	var req pushRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid request body")
		return
	}

	if len(req.Events) == 0 {
		respond.JSON(c, http.StatusOK, SyncPushResult{Applied: 0, MaxSequence: 0})
		return
	}

	result, err := h.svc.Push(c.Request.Context(), authorID, req.Events)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to push sync events")
		return
	}

	respond.JSON(c, http.StatusOK, result)
}
