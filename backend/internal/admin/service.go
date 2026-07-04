package admin

import (
	"context"
	"errors"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) SubmitReport(ctx context.Context, reporterID uuid.UUID, contentType string, contentID uuid.UUID, reason string) (generated.Report, error) {
	if contentType != "post" && contentType != "comment" && contentType != "message" {
		return generated.Report{}, errors.New("invalid content type")
	}
	if reason == "" {
		return generated.Report{}, errors.New("reason cannot be empty")
	}
	return s.repo.CreateReport(ctx, reporterID, contentType, contentID, reason)
}

func (s *Service) GetPendingReports(ctx context.Context) ([]generated.Report, error) {
	return s.repo.GetPendingReports(ctx)
}

func (s *Service) ReviewReport(ctx context.Context, reportID uuid.UUID, status generated.ReportStatus, reviewerID uuid.UUID) error {
	return s.repo.UpdateReportStatus(ctx, reportID, status, reviewerID)
}
