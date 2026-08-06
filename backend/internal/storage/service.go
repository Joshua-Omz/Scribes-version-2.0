package storage

import (
	"context"
	"time"
)

// StorageService defines the contract for interacting with Cloudflare R2 or any S3-compatible backend.
type StorageService interface {
	// GeneratePresignedUpload generates a presigned PUT URL for direct client uploads.
	// The key should include the appropriate prefix (e.g., "avatars/user-uuid-123.jpg").
	GeneratePresignedUpload(ctx context.Context, key string, contentType string, expiry time.Duration) (string, error)

	// DeleteObject removes an object from the bucket.
	DeleteObject(ctx context.Context, key string) error
	
	// GetPublicURL returns the full CDN URL for a given object key.
	GetPublicURL(key string) string
}
