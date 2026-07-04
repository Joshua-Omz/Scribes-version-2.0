package admin

import (
	"net/http"

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

type CreateReportPayload struct {
	ContentType string `json:"content_type" binding:"required"`
	ContentID   string `json:"content_id" binding:"required"`
	Reason      string `json:"reason" binding:"required"`
}

func (h *Handler) SubmitReport(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	reporterID, _ := uuid.Parse(claims.UserID)

	var req CreateReportPayload
	if err := c.ShouldBindJSON(&req); err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}

	contentID, err := uuid.Parse(req.ContentID)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid content_id")
		return
	}

	report, err := h.svc.SubmitReport(c.Request.Context(), reporterID, req.ContentType, contentID, req.Reason)
	if err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	respond.JSON(c, http.StatusCreated, report)
}

func (h *Handler) GetPendingReports(c *gin.Context) {
	// A real implementation requires Role == SUPER_ADMIN check here
	// Assuming it's wrapped in an admin-only middleware in the router
	reports, err := h.svc.GetPendingReports(c.Request.Context())
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to get reports")
		return
	}
	respond.JSON(c, http.StatusOK, reports)
}

type UpdateReportPayload struct {
	Status string `json:"status" binding:"required"`
}

func (h *Handler) UpdateReportStatus(c *gin.Context) {
	claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
	reviewerID, _ := uuid.Parse(claims.UserID)

	reportID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid report id")
		return
	}

	var req UpdateReportPayload
	if err := c.ShouldBindJSON(&req); err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}

	status := generated.ReportStatus(req.Status)
	if err := h.svc.ReviewReport(c.Request.Context(), reportID, status, reviewerID); err != nil {
		respond.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	respond.JSON(c, http.StatusOK, gin.H{"status": "updated"})
}
