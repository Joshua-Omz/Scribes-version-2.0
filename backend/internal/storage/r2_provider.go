package storage

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"

	"scribes-api/internal/config"
)

type r2Provider struct {
	client     *minio.Client
	bucketName string
	cdnDomain  string
}

// NewR2Provider creates a new instance of the StorageService using Cloudflare R2
func NewR2Provider(cfg config.Config) (StorageService, error) {
	endpointStr := cfg.R2Endpoint
	secure := true
	if strings.HasPrefix(endpointStr, "https://") {
		endpointStr = strings.TrimPrefix(endpointStr, "https://")
	} else if strings.HasPrefix(endpointStr, "http://") {
		endpointStr = strings.TrimPrefix(endpointStr, "http://")
		secure = false
	}

	// Ensure cdnDomain is formatted correctly (strip trailing slash)
	cdnDomain := strings.TrimRight(cfg.CDNDomain, "/")
	if cdnDomain == "" {
		// Fallback if not configured
		cdnDomain = "https://cdn.scribes.app"
	}

	minioClient, err := minio.New(endpointStr, &minio.Options{
		Creds:  credentials.NewStaticV4(cfg.R2AccessKeyID, cfg.R2SecretAccessKey, ""),
		Secure: secure,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to initialize R2 client: %w", err)
	}

	return &r2Provider{
		client:     minioClient,
		bucketName: cfg.R2BucketName,
		cdnDomain:  cdnDomain,
	}, nil
}

func (r *r2Provider) GeneratePresignedUpload(ctx context.Context, key string, contentType string, expiry time.Duration) (string, error) {
	// Set the content type so R2 enforces it on upload and serves it correctly
	reqParams := make(map[string]string)
	if contentType != "" {
		reqParams["response-content-type"] = contentType
	}

	presignedURL, err := r.client.PresignedPutObject(ctx, r.bucketName, key, expiry)
	if err != nil {
		return "", fmt.Errorf("failed to generate presigned URL: %w", err)
	}

	return presignedURL.String(), nil
}

func (r *r2Provider) DeleteObject(ctx context.Context, key string) error {
	err := r.client.RemoveObject(ctx, r.bucketName, key, minio.RemoveObjectOptions{})
	if err != nil {
		return fmt.Errorf("failed to delete object %s: %w", key, err)
	}
	return nil
}

func (r *r2Provider) GetPublicURL(key string) string {
	// Clean the key
	cleanKey := strings.TrimLeft(key, "/")
	return fmt.Sprintf("%s/%s", r.cdnDomain, cleanKey)
}
