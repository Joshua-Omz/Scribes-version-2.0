package message

import (
	"io"
	"net/http"
	"strconv"
	"time"

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

// ── Message Requests ───────────────────────────

type CreateRequestPayload struct {
	ToUserID     string `json:"to_user_id" binding:"required"`
	FirstMessage string `json:"first_message" binding:"required"`
}

func (h *Handler) SendRequest(c *gin.Context) {
	claims, ok := middleware.ClaimsFromCtx(c.Request.Context())
	if !ok {
		respond.Error(c, http.StatusUnauthorized, "unauthorized")
		return
	}
	fromUserID, _ := uuid.Parse(claims.UserID)

	var req CreateRequestPayload
	if err := c.ShouldBindJSON(&req); err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}

	toUserID, err := uuid.Parse(req.ToUserID)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid to_user_id")
		return
	}

	res, err := h.svc.SendRequest(c.Request.Context(), fromUserID, toUserID, req.FirstMessage)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, err.Error())
		return
	}
	respond.JSON(c, http.StatusCreated, res)
}

func (h *Handler) GetPendingRequests(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	userID, _ := uuid.Parse(claims.UserID)

	requests, err := h.svc.GetPendingRequests(c.Request.Context(), userID)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to get requests")
		return
	}
	respond.JSON(c, http.StatusOK, requests)
}

func (h *Handler) ApproveRequest(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	userID, _ := uuid.Parse(claims.UserID)

	requestID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid request id")
		return
	}

	conv, err := h.svc.ApproveRequest(c.Request.Context(), requestID, userID)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	respond.JSON(c, http.StatusOK, conv)
}

func (h *Handler) RejectRequest(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	userID, _ := uuid.Parse(claims.UserID)

	requestID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid request id")
		return
	}

	if err := h.svc.RejectRequest(c.Request.Context(), requestID, userID); err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	respond.JSON(c, http.StatusOK, gin.H{"status": "rejected"})
}

// ── Conversations ──────────────────────────────

func (h *Handler) GetConversations(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	userID, _ := uuid.Parse(claims.UserID)

	convs, err := h.svc.GetConversations(c.Request.Context(), userID)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to get conversations")
		return
	}
	respond.JSON(c, http.StatusOK, convs)
}

func (h *Handler) BlockConversation(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	userID, _ := uuid.Parse(claims.UserID)

	convID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid conversation id")
		return
	}

	if err := h.svc.BlockConversation(c.Request.Context(), convID, userID); err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	respond.JSON(c, http.StatusOK, gin.H{"status": "blocked"})
}

// ── Messages ───────────────────────────────────

type SendMessagePayload struct {
	Body string `json:"body" binding:"required"`
}

func (h *Handler) SendMessage(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	senderID, _ := uuid.Parse(claims.UserID)

	convID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid conversation id")
		return
	}

	var req SendMessagePayload
	if err := c.ShouldBindJSON(&req); err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}

	msg, err := h.svc.SendMessage(c.Request.Context(), convID, senderID, req.Body)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	respond.JSON(c, http.StatusCreated, msg)
}

func (h *Handler) GetMessages(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	userID, _ := uuid.Parse(claims.UserID)

	convID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid conversation id")
		return
	}

	limitStr := c.Query("limit")
	limit, _ := strconv.Atoi(limitStr)

	cursorTsStr := c.Query("cursor_ts")
	var cursorTs time.Time
	if cursorTsStr == "" {
		cursorTs = time.Now()
	} else {
		parsedTs, err := time.Parse(time.RFC3339, cursorTsStr)
		if err == nil {
			cursorTs = parsedTs
		} else {
			cursorTs = time.Now()
		}
	}

	msgs, err := h.svc.GetMessages(c.Request.Context(), convID, userID, cursorTs, limit)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, err.Error())
		return
	}
	respond.JSON(c, http.StatusOK, msgs)
}

func (h *Handler) SoftDeleteMessage(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	senderID, _ := uuid.Parse(claims.UserID)

	msgID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid message id")
		return
	}

	if err := h.svc.SoftDeleteMessage(c.Request.Context(), msgID, senderID); err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	respond.JSON(c, http.StatusOK, gin.H{"status": "deleted"})
}

// ── SSE Stream ─────────────────────────────────

func (h *Handler) StreamMessages(c *gin.Context) {
	claims, ok := middleware.ClaimsFromCtx(c.Request.Context())
	if !ok {
		respond.Error(c, http.StatusUnauthorized, "unauthorized")
		return
	}
	userID, _ := uuid.Parse(claims.UserID)

	convID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid conversation id")
		return
	}

	// Security check: ensure user is part of the conversation
	// (A proper implementation would check this without fetching all messages,
	//  but for this sprint we can do a lightweight check via the repo if needed.
	//  For brevity, we trust the connection or do a quick db check)
	convs, err := h.svc.GetConversations(c.Request.Context(), userID)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "error verifying conversation")
		return
	}
	
	allowed := false
	for _, conv := range convs {
		if conv.ID == convID {
			allowed = true
			break
		}
	}
	if !allowed {
		respond.Error(c, http.StatusForbidden, "not part of this conversation")
		return
	}

	// Set required headers for SSE
	c.Writer.Header().Set("Content-Type", "text/event-stream")
	c.Writer.Header().Set("Cache-Control", "no-cache")
	c.Writer.Header().Set("Connection", "keep-alive")
	c.Writer.Header().Set("Transfer-Encoding", "chunked")

	// Subscribe to pub/sub
	msgChan := h.svc.Subscribe(convID)
	defer h.svc.Unsubscribe(convID, msgChan)

	c.Stream(func(w io.Writer) bool {
		select {
		case msg, ok := <-msgChan:
			if !ok {
				return false
			}
			c.SSEvent("message", msg)
			return true
		case <-c.Request.Context().Done():
			// Client disconnected
			return false
		}
	})
}
