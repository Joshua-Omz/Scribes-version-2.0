package admin

import (
	"context"
	"database/sql"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

type Repository struct {
	q *generated.Queries
}

func NewRepository(q *generated.Queries, db *sql.DB) *Repository {
	return &Repository{q: q}
}

func (r *Repository) CreateReport(ctx context.Context, reporterID uuid.UUID, contentType string, contentID uuid.UUID, reason string) (generated.Report, error) {
	return r.q.CreateReport(ctx, generated.CreateReportParams{
		ReporterID:  reporterID,
		ContentType: contentType,
		ContentID:   contentID,
		Reason:      reason,
	})
}

func (r *Repository) GetPendingReports(ctx context.Context) ([]generated.Report, error) {
	return r.q.GetPendingReports(ctx)
}

func (r *Repository) UpdateReportStatus(ctx context.Context, reportID uuid.UUID, status generated.ReportStatus, reviewerID uuid.UUID) error {
	return r.q.UpdateReportStatus(ctx, generated.UpdateReportStatusParams{
		ID:         reportID,
		Status:     status,
		ReviewedBy: uuid.NullUUID{UUID: reviewerID, Valid: true},
	})
}
