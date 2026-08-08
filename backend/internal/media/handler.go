package media

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"scribes-api/internal/middleware"
	"scribes-api/pkg/respond"
)

type Handler struct {
	service Service
}

func NewHandler(service Service) *Handler {
	return &Handler{
		service: service,
	}
}

type PresignRequest struct {
	ContentType string `json:"content_type"`
	SizeBytes   int64  `json:"size_bytes"`
}

type PresignResponse struct {
	UploadUrl string    `json:"upload_url"`
	FileUrl   string    `json:"file_url"`
	UploadID  uuid.UUID `json:"upload_id"`
}

func (h *Handler) HandlePresign(c *gin.Context) {
	ctx := c.Request.Context()
	claims, ok := middleware.ClaimsFromCtx(ctx)
	if !ok {
		respond.Error(c, http.StatusUnauthorized, "Unauthorized")
		return
	}
	userID, err := uuid.Parse(claims.UserID)
	if err != nil {
		respond.Error(c, http.StatusUnauthorized, "Invalid user ID")
		return
	}

	var req PresignRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		respond.Error(c, http.StatusBadRequest, "Invalid request payload")
		return
	}

	if req.SizeBytes > 5242880 {
		respond.Error(c, http.StatusBadRequest, "File exceeds 5MB limit")
		return
	}

	uploadUrl, fileUrl, uploadID, err := h.service.GeneratePresignedUpload(ctx, userID, req.ContentType, req.SizeBytes)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "Failed to generate presigned URL")
		return
	}

	respond.JSON(c, http.StatusOK, PresignResponse{
		UploadUrl: uploadUrl,
		FileUrl:   fileUrl,
		UploadID:  uploadID,
	})
}

type ConfirmRequest struct {
	UploadID  uuid.UUID `json:"upload_id"`
	Url       string    `json:"url"`
	MimeType  string    `json:"mime_type"`
	SizeBytes int64     `json:"size_bytes"`
	WidthPx   *int      `json:"width_px"`
	HeightPx  *int      `json:"height_px"`
}

func (h *Handler) HandleConfirm(c *gin.Context) {
	ctx := c.Request.Context()
	claims, ok := middleware.ClaimsFromCtx(ctx)
	if !ok {
		respond.Error(c, http.StatusUnauthorized, "Unauthorized")
		return
	}
	userID, err := uuid.Parse(claims.UserID)
	if err != nil {
		respond.Error(c, http.StatusUnauthorized, "Invalid user ID")
		return
	}

	var req ConfirmRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		respond.Error(c, http.StatusBadRequest, "Invalid request payload")
		return
	}

	upload, err := h.service.ConfirmUpload(ctx, req.UploadID, userID, req.Url, req.MimeType, req.SizeBytes, req.WidthPx, req.HeightPx)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "Failed to confirm upload")
		return
	}

	respond.JSON(c, http.StatusOK, upload)
}
