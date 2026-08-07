-- MIGRATION 018: Media expansion (Cover Image & Post Type)

CREATE TYPE post_type AS ENUM (
    'standard',
    'passage'
);

ALTER TABLE posts
    ADD COLUMN post_type       post_type NOT NULL DEFAULT 'standard',
    ADD COLUMN cover_image_url TEXT;

ALTER TABLE posts
    ADD CONSTRAINT cover_image_standard_only
    CHECK (
        cover_image_url IS NULL
        OR post_type = 'standard'
    );

CREATE INDEX idx_posts_type
    ON posts (post_type, published_at DESC)
    WHERE is_deleted = false;

-- Tracks every file uploaded through POST /media/upload.
-- No credit_cost — this is an audit trail, not a billing ledger.
CREATE TABLE media_uploads (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    uploader_id  UUID        NOT NULL REFERENCES users(id),
    url          TEXT        NOT NULL UNIQUE,
    mime_type    TEXT        NOT NULL,
    size_bytes   BIGINT      NOT NULL,
    width_px     INT,
    height_px    INT,
    post_id      UUID        REFERENCES posts(id),  -- nullable until post is published
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT valid_mime_type CHECK (
        mime_type IN ('image/jpeg', 'image/png', 'image/webp')
    ),
    CONSTRAINT max_size CHECK (
        size_bytes <= 5242880  -- 5MB
    )
);

CREATE INDEX idx_media_uploader ON media_uploads (uploader_id, created_at DESC);
