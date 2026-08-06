# Scribes R2 Storage Contract

This document defines the storage architecture and contract for Scribes media uploads, implemented via Cloudflare R2 and accessed through the `internal/storage` Go package.

## 1. Overview

Scribes uses Cloudflare R2 as its object storage backend. The system is designed to minimize server bandwidth by using **Presigned URLs** for direct client uploads, while serving media directly via a **Public Cloudflare CDN URL**. 

There is NO commercial billing layer. Usage is governed entirely by a **Fair-Use Allowance**, tracked per user in the database (`fair_use_policy` and `credit_usage` tables) and audited via the `media_uploads` table.

## 2. Infrastructure & Tooling

*   **Provider**: Cloudflare R2 (S3-compatible API).
*   **Go SDK**: `github.com/minio/minio-go/v7` (chosen for being lean and fully S3-compatible).
*   **Bucket**: A single R2 bucket is used for all media.
*   **Read Access**: All uploaded objects are publicly readable via a mapped CDN domain (e.g., `https://cdn.scribes.app`). No presigned GET URLs are required.

## 3. Storage Hierarchy (Path Prefixes)

The bucket organizes files into exactly 5 prefixes. No files should be stored at the root.

1.  `avatars/` - User profile pictures.
2.  `covers/` - Standard post cover images.
3.  `panels/` - Passage post panel images.
4.  `sounds/` - Sound pool audio files.
5.  `drafts/` - Temporary uploads and work-in-progress drafts.

## 4. The Upload Flow (Presigned PUT)

1.  **Request (Client -> API)**: The Flutter client requests an upload intent by calling a backend endpoint (e.g., `POST /media/upload-intent`), providing file metadata (mime type, size, purpose).
2.  **Validation (API)**: The backend checks the user's `credit_usage` against the `fair_use_policy`. If exceeded, it returns a `429 Too Many Requests`. It also validates size (<= 5MB) and mime type.
3.  **Generation (API -> Client)**: The backend generates a **presigned PUT URL** valid for 15 minutes and returns it to the client, along with the final public CDN URL.
4.  **Upload (Client -> R2)**: The client uploads the binary directly to R2 using the presigned URL.
5.  **Confirmation (Client -> API)**: The client calls the backend to confirm the upload is complete. The backend audits this in the `media_uploads` table and increments the `credit_usage` table if applicable.

## 5. Interface Contract (`internal/storage/service.go`)

The storage service exposes a minimal interface focusing on presigned URL generation and deletion. It does not handle actual binary streaming.

```go
package storage

import (
    "context"
    "time"
)

// StorageService defines the contract for interacting with Cloudflare R2
type StorageService interface {
    // GeneratePresignedUpload generates a presigned PUT URL for direct client uploads.
    // The key should include the appropriate prefix (e.g., "avatars/user-uuid-123.jpg").
    GeneratePresignedUpload(ctx context.Context, key string, contentType string, expiry time.Duration) (string, error)

    // DeleteObject removes an object from the bucket.
    DeleteObject(ctx context.Context, key string) error
    
    // GetPublicURL returns the full CDN URL for a given object key.
    GetPublicURL(key string) string
}
```
