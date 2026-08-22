# How the Media & Cover Image Pipeline Works

This document explains the end-to-end media upload, optimistic preview, draft persistence, and publication lifecycle in Scribes.

---

## 1. Complete End-to-End Pipeline

```
[1] User picks & crops image in PublishMetadataScreen
    │
    ├─► Immediate: Set composeProvider.coverImageUrl = local cropped path
    │   └─► Instant 0ms local preview in UI via ScribesImageResolver
    │
    └─► Background Upload: MediaApi.uploadImage(File, mimeType)
        │
        ├─► POST /media/upload/presign (Sends {content_type, size_bytes})
        │   └─► Returns {upload_url, file_url, upload_id}
        │
        ├─► PUT upload_url (Direct to Cloudflare R2 / S3 storage)
        │
        ├─► POST /media/upload/confirm
        │   └─► Inserts record into PostgreSQL media_uploads table
        │
        └─► Update: composeProvider.coverImageUrl = uploaded file_url
```

---

## 2. Draft Storage & Publishing

When the user taps "Publish":

1. **Client Draft Serialization (`compose_provider.dart`)**:
   Constructs `contentMap` including:
   ```dart
   final contentMap = {
     'title': state.title,
     'excerpt': excerptText.trim(),
     'body': deltaJson,
     'cover_image_url': state.coverImageUrl,
     'post_type': state.postType,
     'caption': state.caption,
     'tags': state.tags,
     'scripture_refs': state.scriptureRefs.map((r) => r.toJson()).toList(),
   };
   ```
2. **Local Drift Database**: Saved into SQLite drafts table with full JSON payload.
3. **Cloud Publish (`POST /drafts/:id/publish`)**:
   Hits Go backend `draft.Service.Publish()`.
4. **Backend Unpacking (`backend/internal/draft/service.go`)**:
   Unmarshals metadata from `draft.Content` and creates permanent post:
   ```go
   var meta struct {
       CoverImageUrl *string `json:"cover_image_url"`
       PostType      string  `json:"post_type"`
   }
   _ = json.Unmarshal(d.Content, &meta)

   p, err := s.postSvc.Create(ctx, authorID, post.CreateInput{
       Content:       d.Content,
       Caption:       d.Caption,
       SermonSource:  d.SermonSource,
       Tags:          tags,
       ScriptureRefs: scriptureRefs,
       CoverImageUrl: meta.CoverImageUrl,
       PostType:      meta.PostType,
   })
   ```
5. **PostgreSQL Posts Table**:
   Stores `cover_image_url` and `post_type` directly on the `posts` row.

---

## 3. Dual-Key Compatibility Invariant

The presign endpoint supports both `content_type` and `mime_type` to avoid client-backend contract drift:

```go
type PresignRequest struct {
    ContentType string `json:"content_type"`
    MimeType    string `json:"mime_type"`
    SizeBytes   int64  `json:"size_bytes"`
}
```
