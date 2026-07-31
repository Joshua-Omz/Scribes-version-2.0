# Scribes — Cloudflare R2 Storage Service Contract
**Version 1.0 · Single source of truth for all media storage**

> R2 is the only storage backend for Scribes. Every image and audio file — regardless of context — goes through this one service. Nothing is stored locally on the server. Nothing is stored in PostgreSQL as binary. The service is a thin, focused wrapper around the R2 S3-compatible API. It does one thing: put files in, get URLs out.

---

## 1. What Goes Into R2

| Asset type | Context | Bucket path prefix | Billing |
|---|---|---|---|
| Cover image | Standard post | `posts/covers/` | Scribe Pro / Elder |
| Passage panel image | Passage post | `posts/panels/` | Scribe Pro / Elder |
| Note attachment image | Private note | `notes/` | Scribe Pro / Elder |
| Profile picture | User avatar | `avatars/` | Free (always) |
| Gospel instrumental | Sound pool | `sounds/` | Super Admin upload only |

**One bucket. Five path prefixes. That is the entire storage topology.**

The bucket is named `scribes-media`. All assets live in it. Access control is handled at the application layer — the service generates the URL, the URL is public via the R2 CDN, but the file path is a UUID so it cannot be guessed.

---

## 2. Package Structure

```
internal/storage/
├── service.go       — the single service all features call
├── r2_client.go     — R2 connection setup, S3-compatible client
├── model.go         — UploadInput, UploadResult, AssetType
└── validator.go     — mime type, size, dimensions validation
```

No handler. No repository. Storage is infrastructure — it is called by other features' services, not by HTTP handlers directly. The upload endpoint (`POST /media/upload`) lives in `internal/media/handler.go` and calls `storage.Service` internally.

---

## 3. Domain Model

```go
// internal/storage/model.go

type AssetType string

const (
    AssetTypePostCover    AssetType = "post_cover"
    AssetTypePassagePanel AssetType = "passage_panel"
    AssetTypeNoteImage    AssetType = "note_image"
    AssetTypeAvatar       AssetType = "avatar"
    AssetTypeSound        AssetType = "sound"
)

// Rules per asset type — enforced by validator.go
var AssetRules = map[AssetType]AssetRule{
    AssetTypePostCover: {
        AllowedMIME:   []string{"image/jpeg", "image/png", "image/webp"},
        MaxSizeBytes:  5 * 1024 * 1024,  // 5MB
        MaxWidthPx:    4096,
        MaxHeightPx:   4096,
        BucketPrefix:  "posts/covers/",
    },
    AssetTypePassagePanel: {
        AllowedMIME:   []string{"image/jpeg", "image/png", "image/webp"},
        MaxSizeBytes:  5 * 1024 * 1024,
        MaxWidthPx:    4096,
        MaxHeightPx:   4096,
        BucketPrefix:  "posts/panels/",
    },
    AssetTypeNoteImage: {
        AllowedMIME:   []string{"image/jpeg", "image/png", "image/webp"},
        MaxSizeBytes:  5 * 1024 * 1024,
        MaxWidthPx:    4096,
        MaxHeightPx:   4096,
        BucketPrefix:  "notes/",
    },
    AssetTypeAvatar: {
        AllowedMIME:   []string{"image/jpeg", "image/png", "image/webp"},
        MaxSizeBytes:  2 * 1024 * 1024,  // 2MB — avatars are smaller
        MaxWidthPx:    1024,
        MaxHeightPx:   1024,
        BucketPrefix:  "avatars/",
    },
    AssetTypeSound: {
        AllowedMIME:   []string{"audio/mpeg", "audio/mp4", "audio/wav"},
        MaxSizeBytes:  50 * 1024 * 1024, // 50MB — audio files are larger
        MaxWidthPx:    0,                // not applicable
        MaxHeightPx:   0,
        BucketPrefix:  "sounds/",
    },
}

type AssetRule struct {
    AllowedMIME  []string
    MaxSizeBytes int64
    MaxWidthPx   int
    MaxHeightPx  int
    BucketPrefix string
}

type UploadInput struct {
    File      io.Reader
    MIMEType  string
    SizeBytes int64
    AssetType AssetType
    UploaderID uuid.UUID   // used for audit trail in media_uploads table
}

type UploadResult struct {
    AssetID   uuid.UUID  // the generated file ID (also the key in R2)
    PublicURL string     // the CDN URL — this is what gets stored in PostgreSQL
    MIMEType  string
    SizeBytes int64
}
```

---

## 4. The Service

```go
// internal/storage/service.go

type Service struct {
    client    *r2Client       // wraps the S3-compatible R2 connection
    validator *Validator
    publicURL string          // e.g. "https://r2.scribes.app"
    bucket    string          // e.g. "scribes-media"
}

func NewService(cfg *config.Config) *Service

// Upload is the only method external packages call.
// It validates, generates a key, uploads to R2, and returns the public URL.
// It does NOT write to PostgreSQL — that is the caller's responsibility.
func (s *Service) Upload(ctx context.Context, input UploadInput) (*UploadResult, error)

// Delete removes a file from R2 by its public URL.
// Called when a post is hard-deleted by an admin
// or when a user replaces their avatar.
// Does NOT touch PostgreSQL — caller handles DB cleanup.
func (s *Service) Delete(ctx context.Context, publicURL string) error

// Exists checks whether a URL belongs to this R2 bucket.
// Used to validate URLs before accepting them in API payloads.
func (s *Service) Exists(ctx context.Context, publicURL string) (bool, error)
```

### Upload internals — step by step

```
Upload(ctx, input):

  1. Validate MIME type against AssetRules[input.AssetType].AllowedMIME
     → ErrInvalidMIMEType if not allowed

  2. Validate size against AssetRules[input.AssetType].MaxSizeBytes
     → ErrFileTooLarge if exceeded

  3. For image types: decode image header to check dimensions
     → ErrImageTooLarge if width or height exceeds max
     → This reads only the header bytes, not the full file

  4. Generate asset key:
     assetID := uuid.New()
     ext     := mimeToExt(input.MIMEType)   // ".jpg", ".mp3" etc.
     key     := prefix + assetID.String() + ext
     // e.g. "posts/covers/a1b2c3d4-...-uuid.webp"

  5. Upload to R2 via S3 PutObject:
     Bucket:      s.bucket
     Key:         key
     Body:        input.File
     ContentType: input.MIMEType

  6. Construct public URL:
     publicURL := s.publicURL + "/" + key
     // e.g. "https://r2.scribes.app/posts/covers/uuid.webp"

  7. Return UploadResult{
       AssetID:   assetID,
       PublicURL: publicURL,
       MIMEType:  input.MIMEType,
       SizeBytes: input.SizeBytes,
     }
```

---

## 5. The R2 Client

```go
// internal/storage/r2_client.go

type r2Client struct {
    s3 *s3.Client
}

func newR2Client(cfg *config.Config) (*r2Client, error) {
    r2Resolver := aws.EndpointResolverWithOptionsFunc(
        func(service, region string, options ...interface{}) (aws.Endpoint, error) {
            return aws.Endpoint{URL: cfg.R2Endpoint}, nil
        },
    )

    awsCfg, err := awsconfig.LoadDefaultConfig(context.Background(),
        awsconfig.WithEndpointResolverWithOptions(r2Resolver),
        awsconfig.WithCredentialsProvider(
            credentials.NewStaticCredentialsProvider(
                cfg.R2AccessKeyID,
                cfg.R2SecretAccessKey,
                "",
            ),
        ),
        awsconfig.WithRegion("auto"),
    )
    if err != nil {
        return nil, fmt.Errorf("r2 config: %w", err)
    }

    return &r2Client{s3: s3.NewFromConfig(awsCfg)}, nil
}

func (c *r2Client) putObject(ctx context.Context, bucket, key string,
    body io.Reader, contentType string) error {

    _, err := c.s3.PutObject(ctx, &s3.PutObjectInput{
        Bucket:      aws.String(bucket),
        Key:         aws.String(key),
        Body:        body,
        ContentType: aws.String(contentType),
    })
    return err
}

func (c *r2Client) deleteObject(ctx context.Context, bucket, key string) error {
    _, err := c.s3.DeleteObject(ctx, &s3.DeleteObjectInput{
        Bucket: aws.String(bucket),
        Key:    aws.String(key),
    })
    return err
}
```

---

## 6. The Validator

```go
// internal/storage/validator.go

type Validator struct{}

type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("%s: %s", e.Field, e.Message)
}

var (
    ErrInvalidMIMEType = &ValidationError{Field: "mime_type", Message: "file type not allowed"}
    ErrFileTooLarge    = &ValidationError{Field: "size",      Message: "file exceeds maximum size"}
    ErrImageTooLarge   = &ValidationError{Field: "dimensions", Message: "image dimensions exceed maximum"}
    ErrEmptyFile       = &ValidationError{Field: "file",      Message: "file is empty"}
)

func (v *Validator) Validate(input UploadInput) error {
    rule, ok := AssetRules[input.AssetType]
    if !ok {
        return &ValidationError{Field: "asset_type", Message: "unknown asset type"}
    }

    // Empty file
    if input.SizeBytes == 0 {
        return ErrEmptyFile
    }

    // MIME type
    allowed := false
    for _, m := range rule.AllowedMIME {
        if m == input.MIMEType { allowed = true; break }
    }
    if !allowed {
        return ErrInvalidMIMEType
    }

    // Size
    if input.SizeBytes > rule.MaxSizeBytes {
        return ErrFileTooLarge
    }

    // Dimensions (images only)
    if rule.MaxWidthPx > 0 {
        cfg, _, err := image.DecodeConfig(input.File)
        if err != nil {
            return &ValidationError{Field: "file", Message: "could not read image"}
        }
        if cfg.Width > rule.MaxWidthPx || cfg.Height > rule.MaxHeightPx {
            return ErrImageTooLarge
        }
    }

    return nil
}
```

---

## 7. How Each Feature Calls the Storage Service

The storage service is injected into each feature's service constructor that needs it. It is never called from a handler directly.

### Profile picture (avatar)

```go
// internal/profile/service.go

func (s *ProfileService) UpdateAvatar(ctx context.Context,
    userID uuid.UUID, file io.Reader, mimeType string, sizeBytes int64) error {

    result, err := s.storage.Upload(ctx, storage.UploadInput{
        File:       file,
        MIMEType:   mimeType,
        SizeBytes:  sizeBytes,
        AssetType:  storage.AssetTypeAvatar,
        UploaderID: userID,
    })
    if err != nil { return err }

    // Delete old avatar from R2 if one exists
    user, _ := s.repo.GetByID(ctx, userID)
    if user.AvatarURL != nil {
        _ = s.storage.Delete(ctx, *user.AvatarURL)  // best-effort, don't fail on old delete
    }

    return s.repo.UpdateAvatarURL(ctx, userID, result.PublicURL)
}
```

### Post cover image

```go
// internal/media/service.go

func (s *MediaService) UploadCoverImage(ctx context.Context,
    uploaderID uuid.UUID, file io.Reader, mimeType string, sizeBytes int64) (*UploadResult, error) {

    // 1. Check billing credits first
    if err := s.billing.CheckAndDeductCredit(ctx, uploaderID, "cover"); err != nil {
        return nil, err  // maps to 402 in handler
    }

    // 2. Upload to R2
    result, err := s.storage.Upload(ctx, storage.UploadInput{
        File:       file,
        MIMEType:   mimeType,
        SizeBytes:  sizeBytes,
        AssetType:  storage.AssetTypePostCover,
        UploaderID: uploaderID,
    })
    if err != nil { return nil, err }

    // 3. Write audit record to media_uploads
    upload, err := s.repo.InsertMediaUpload(ctx, InsertMediaUploadParams{
        UploaderID: uploaderID,
        URL:        result.PublicURL,
        MIMEType:   mimeType,
        SizeBytes:  sizeBytes,
    })
    if err != nil { return nil, err }

    return &UploadResult{
        ID:        upload.ID,
        PublicURL: result.PublicURL,
        MIMEType:  mimeType,
        SizeBytes: sizeBytes,
    }, nil
}
```

### Sound (Super Admin only)

```go
// internal/admin/service.go

func (s *AdminService) AddSound(ctx context.Context,
    adminID uuid.UUID, file io.Reader, mimeType string,
    sizeBytes int64, meta SoundMeta) (*Sound, error) {

    result, err := s.storage.Upload(ctx, storage.UploadInput{
        File:       file,
        MIMEType:   mimeType,
        SizeBytes:  sizeBytes,
        AssetType:  storage.AssetTypeSound,
        UploaderID: adminID,
    })
    if err != nil { return nil, err }

    return s.soundRepo.Insert(ctx, InsertSoundParams{
        Title:        meta.Title,
        Artist:       meta.Artist,
        Category:     meta.Category,
        DurationSecs: meta.DurationSecs,
        StreamURL:    result.PublicURL,
        AddedBy:      adminID,
    })
}
```

### Note image

```go
// internal/note/service.go

func (s *NoteService) AttachImage(ctx context.Context,
    userID uuid.UUID, file io.Reader, mimeType string, sizeBytes int64) (string, error) {

    // Check billing credits
    if err := s.billing.CheckAndDeductCredit(ctx, userID, "panel"); err != nil {
        return "", err
    }

    result, err := s.storage.Upload(ctx, storage.UploadInput{
        File:       file,
        MIMEType:   mimeType,
        SizeBytes:  sizeBytes,
        AssetType:  storage.AssetTypeNoteImage,
        UploaderID: userID,
    })
    if err != nil { return "", err }

    return result.PublicURL, nil
    // Caller embeds this URL inside the note's JSONB content field
}
```

---

## 8. Error Mapping — Service Errors to HTTP Status Codes

This mapping is applied in each feature's handler, not in the storage service itself. The storage service returns typed errors. The handler decides the HTTP response.

| Storage error | HTTP status | Response body |
|---|---|---|
| `ErrInvalidMIMEType` | 400 | `"file type not allowed for this upload"` |
| `ErrFileTooLarge` | 400 | `"file exceeds the maximum allowed size"` |
| `ErrImageTooLarge` | 400 | `"image dimensions exceed the maximum"` |
| `ErrEmptyFile` | 400 | `"file is empty"` |
| `ErrPlanDoesNotIncludeImages` | 402 | `"image uploads require Scribe Pro or Elder plan"` |
| `ErrCreditsExhausted` | 402 | `"you have used all your credits for this month"` |
| R2 network/timeout error | 503 | `"storage service temporarily unavailable"` |

---

## 9. Avatar — Database Addition

The `users` table needs one new column. This is a small migration:

```sql
-- 015_avatar.up.sql

ALTER TABLE users
    ADD COLUMN avatar_url TEXT;

-- No size constraint at DB level — the storage service enforces 2MB.
-- avatar_url is always a full R2 CDN URL or NULL.
-- NULL means "use the default generated avatar on the client".
```

```sql
-- 015_avatar.down.sql
ALTER TABLE users DROP COLUMN IF EXISTS avatar_url;
```

---

## 10. Environment Variables

```bash
# Cloudflare R2 — all required at startup
R2_ENDPOINT=https://<account-id>.r2.cloudflarestorage.com
R2_BUCKET=scribes-media
R2_ACCESS_KEY_ID=<key-from-r2-dashboard>
R2_SECRET_ACCESS_KEY=<secret-from-r2-dashboard>
R2_PUBLIC_URL=https://r2.scribes.app
# R2_PUBLIC_URL is the custom domain configured in R2 dashboard
# pointing to the scribes-media bucket
# Without a custom domain, it would be:
# https://pub-<hash>.r2.dev
```

**Startup validation:** `config.Load()` must panic if any of the five R2 variables are missing. Storage is not an optional dependency — the API cannot function without it.

---

## 11. Wiring in main.go

```go
// cmd/api/main.go

// Storage is initialised once and shared across all features
storageSvc, err := storage.NewService(cfg)
if err != nil {
    log.Fatal("failed to initialise R2 storage:", err)
}

// Inject into each feature service that needs it
mediaSvc   := media.NewService(mediaRepo, storageSvc, billingSvc)
profileSvc := profile.NewService(profileRepo, storageSvc)
noteSvc    := note.NewService(noteRepo, draftSvc, storageSvc, billingSvc)
adminSvc   := admin.NewService(adminRepo, storageSvc, notifSvc)

// Storage service is NOT injected into:
// auth, feed, sync, social, notification, recommendation, search, tag, message
// — these features have no direct file storage concerns
```

---

## 12. The Bucket Structure at a Glance

```
scribes-media/                         ← Cloudflare R2 bucket
├── avatars/
│   └── {uuid}.webp                    — user profile pictures
├── posts/
│   ├── covers/
│   │   └── {uuid}.webp                — standard post cover images
│   └── panels/
│       └── {uuid}.jpg                 — passage panel images
├── notes/
│   └── {uuid}.png                     — images embedded in private notes
└── sounds/
    └── {uuid}.mp3                     — gospel instrumentals
```

Every file path is `prefix/{uuid}.ext`. The UUID is generated server-side at upload time. There is no predictable URL — the only way to know a file's URL is to have been given it by the API. This is the access control model — obscurity by UUID, not signed URLs or auth headers on the CDN.

---

## 13. What the Storage Service Does NOT Do

These are explicit non-responsibilities of `internal/storage/`:

- **Does not resize or compress images.** Files are stored as-uploaded. The Flutter client is responsible for compressing images before upload (using `flutter_image_compress` to ~80% quality before sending). This keeps the server simple.
- **Does not generate thumbnails.** The full-size image is the only stored artifact. If thumbnails are needed in v2, a Cloudflare Image Transformation Worker handles it at the CDN layer without any server changes.
- **Does not stream audio.** `stream_url` points directly to the R2 CDN URL. The Flutter `just_audio` client streams from R2 directly. The Go API is not in the audio delivery path at all.
- **Does not write to PostgreSQL.** It puts files in R2 and returns URLs. Every caller is responsible for persisting the URL in the correct table.
- **Does not handle multipart parsing.** The HTTP handler (`internal/media/handler.go`) parses the multipart form and passes `io.Reader` to the storage service. The storage service never touches `*gin.Context`.

---

## 14. Done Criteria

- [ ] `storage.NewService()` panics at startup if any R2 env variable is missing
- [ ] Uploading a valid JPEG cover image returns a CDN URL in the correct `posts/covers/` prefix
- [ ] Uploading a valid MP3 sound returns a CDN URL in the `sounds/` prefix
- [ ] Uploading a file over the size limit returns `ErrFileTooLarge` — confirmed with a 6MB file
- [ ] Uploading a PDF returns `ErrInvalidMIMEType`
- [ ] Avatar upload replaces the old avatar URL in the users table and deletes the old R2 object
- [ ] Deleting a post with a cover image removes the R2 object (called by admin hard-delete only)
- [ ] The storage service is not imported by: auth, feed, sync, social, notification, search, tag, message — confirmed by go build import check
- [ ] `flutter_image_compress` compresses images to ≤80% quality before the multipart request is sent — confirmed by comparing file sizes before and after
- [ ] Sound files stream directly from R2 to `just_audio` without passing through the Go API

---

*Scribes R2 Storage Service Contract v1.0*
*One bucket · Five prefixes · One service · Zero binary data in PostgreSQL*
