package message

import (
	"io"
	"net/http"
	"strconv"
	"time"

	"scribes-api/internal/db/generated"
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

	if fromUserID == toUserID {
		respond.Error(c, http.StatusBadRequest, "cannot send message request to yourself")
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

func (h *Handler) SearchContacts(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	userID, _ := uuid.Parse(claims.UserID)

	query := c.Query("q")
	
	contacts, err := h.svc.SearchContacts(c.Request.Context(), userID, query)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to search contacts")
		return
	}
	respond.JSON(c, http.StatusOK, contacts)
}

type DirectConversationPayload struct {
	ToUserID string `json:"to_user_id" binding:"required"`
}

func (h *Handler) DirectConversation(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	userID, _ := uuid.Parse(claims.UserID)

	var payload DirectConversationPayload
	if err := c.ShouldBindJSON(&payload); err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}

	toUserID, err := uuid.Parse(payload.ToUserID)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid to_user_id")
		return
	}

	if userID == toUserID {
		respond.Error(c, http.StatusBadRequest, "cannot message yourself")
		return
	}

	conv, err := h.svc.GetOrCreateDirectConversation(c.Request.Context(), userID, toUserID)
	if err != nil {
		respond.Error(c, http.StatusForbidden, err.Error())
		return
	}

	respond.JSON(c, http.StatusOK, conv)
}

// ── Messages ───────────────────────────────────

type MessageDTO struct {
	ID             uuid.UUID  `json:"id"`
	ConversationID uuid.UUID  `json:"conversation_id"`
	SenderID       uuid.UUID  `json:"sender_id"`
	Body           string     `json:"body"`
	IsDeleted      bool       `json:"is_deleted"`
	SentAt         time.Time  `json:"sent_at"`
	ReplyToID      *uuid.UUID `json:"reply_to_id"`
	EditedAt       *time.Time `json:"edited_at"`
}

func toMessageDTO(m generated.Message) MessageDTO {
	dto := MessageDTO{
		ID:             m.ID,
		ConversationID: m.ConversationID,
		SenderID:       m.SenderID,
		Body:           m.Body,
		IsDeleted:      m.IsDeleted,
		SentAt:         m.SentAt,
	}
	if m.ReplyToID.Valid {
		dto.ReplyToID = &m.ReplyToID.UUID
	}
	if m.EditedAt.Valid {
		dto.EditedAt = &m.EditedAt.Time
	}
	return dto
}

type SendMessagePayload struct {
	Body      string  `json:"body" binding:"required"`
	ReplyToID *string `json:"reply_to_id,omitempty"`
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

	var replyTo *uuid.UUID
	if req.ReplyToID != nil {
		id, err := uuid.Parse(*req.ReplyToID)
		if err == nil {
			replyTo = &id
		}
	}

	msg, err := h.svc.SendMessage(c.Request.Context(), convID, senderID, req.Body, replyTo)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	respond.JSON(c, http.StatusCreated, toMessageDTO(msg))
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
	var dtos []MessageDTO
	for _, m := range msgs {
		dtos = append(dtos, toMessageDTO(m))
	}
	if dtos == nil {
		dtos = []MessageDTO{}
	}
	respond.JSON(c, http.StatusOK, dtos)
}

type UpdateMessagePayload struct {
	Body string `json:"body" binding:"required"`
}

func (h *Handler) UpdateMessage(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	senderID, _ := uuid.Parse(claims.UserID)

	// Conversation ID isn't strictly needed for the DB query since message ID + sender ID is enough,
	// but it's in the route /conversations/:id/messages/:msg_id
	msgID, err := uuid.Parse(c.Param("msg_id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid message id")
		return
	}

	var req UpdateMessagePayload
	if err := c.ShouldBindJSON(&req); err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}

	msg, err := h.svc.UpdateMessage(c.Request.Context(), msgID, senderID, req.Body)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	respond.JSON(c, http.StatusOK, toMessageDTO(msg))
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
			c.SSEvent("message", toMessageDTO(*msg))
			return true
		case <-c.Request.Context().Done():
			// Client disconnected
			return false
		}
	})
}
