package media

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
	"scribes-api/internal/db/generated"
	"scribes-api/internal/storage"
)

type Service interface {
	GeneratePresignedUpload(ctx context.Context, uploaderID uuid.UUID, contentType string, sizeBytes int64) (string, uuid.UUID, error)
	ConfirmUpload(ctx context.Context, uploadID uuid.UUID, uploaderID uuid.UUID, url string, mimeType string, sizeBytes int64, widthPx, heightPx *int) (*generated.MediaUpload, error)
}

type service struct {
	db      *generated.Queries
	storage storage.StorageService
}

func NewService(db *generated.Queries, storage storage.StorageService) Service {
	return &service{
		db:      db,
		storage: storage,
	}
}

func (s *service) GeneratePresignedUpload(ctx context.Context, uploaderID uuid.UUID, contentType string, sizeBytes int64) (string, uuid.UUID, error) {
	// Generate a unique key for the upload
	uploadID := uuid.New()
	key := "uploads/" + uploaderID.String() + "/" + uploadID.String()

	// Presigned URL expires in 15 minutes
	url, err := s.storage.GeneratePresignedUpload(ctx, key, contentType, 15*time.Minute)
	if err != nil {
		return "", uuid.Nil, err
	}

	return url, uploadID, nil
}

func (s *service) ConfirmUpload(ctx context.Context, uploadID uuid.UUID, uploaderID uuid.UUID, url string, mimeType string, sizeBytes int64, widthPx, heightPx *int) (*generated.MediaUpload, error) {
	// Insert into media_uploads audit trail
	var w sql.NullInt32
	if widthPx != nil {
		w = sql.NullInt32{Int32: int32(*widthPx), Valid: true}
	}
	var h sql.NullInt32
	if heightPx != nil {
		h = sql.NullInt32{Int32: int32(*heightPx), Valid: true}
	}

	upload, err := s.db.InsertMediaUpload(ctx, generated.InsertMediaUploadParams{
		UploaderID: uploaderID,
		Url:        url,
		MimeType:   mimeType,
		SizeBytes:  sizeBytes,
		WidthPx:    w,
		HeightPx:   h,
		PostID:     uuid.NullUUID{}, // PostID is null until attached to a post
	})
	
	if err != nil {
		return nil, err
	}

	return &upload, nil
}
