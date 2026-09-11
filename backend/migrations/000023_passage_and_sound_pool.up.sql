-- MIGRATION 023: Passage Panels & Sound Pool

CREATE TYPE passage_panel_type AS ENUM (
    'text',
    'scripture',
    'reflection',
    'image'
);

-- ── Sound Pool (Curated ambient audio for passages) ───────
CREATE TABLE IF NOT EXISTS sound_pool (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    title            TEXT        NOT NULL,
    category         TEXT        NOT NULL, -- 'ambient', 'choral', 'nature', 'liturgical', 'instrumental'
    audio_url        TEXT        NOT NULL UNIQUE,
    duration_seconds INT         NOT NULL,
    is_active        BOOLEAN     NOT NULL DEFAULT true,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_sound_pool_category ON sound_pool (category) WHERE is_active = true;

-- Attach sound_id to posts table
ALTER TABLE posts
    ADD COLUMN IF NOT EXISTS sound_id UUID REFERENCES sound_pool(id);

-- ── Passage Panels (Ordered multi-panel records) ───────────
CREATE TABLE IF NOT EXISTS passage_panels (
    id                   UUID               PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id              UUID               NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    panel_order          INT                NOT NULL,
    panel_type           passage_panel_type NOT NULL,
    content              JSONB              NOT NULL DEFAULT '{}',
    background_image_url TEXT,
    scripture_ref        JSONB,
    created_at           TIMESTAMPTZ        NOT NULL DEFAULT now(),

    CONSTRAINT max_panels_per_post CHECK (panel_order >= 0 AND panel_order < 12),
    UNIQUE (post_id, panel_order)
);

CREATE INDEX IF NOT EXISTS idx_passage_panels_post ON passage_panels (post_id, panel_order ASC);

-- ── Seed Curated Ambient Audio Tracks ─────────────────────
INSERT INTO sound_pool (title, category, audio_url, duration_seconds)
VALUES 
    ('Gregorian Compline', 'choral', 'https://assets.scribes.app/audio/gregorian_compline.mp3', 180),
    ('Cathedral Rain', 'nature', 'https://assets.scribes.app/audio/cathedral_rain.mp3', 240),
    ('Monastery Bells at Dawn', 'liturgical', 'https://assets.scribes.app/audio/monastery_bells.mp3', 150),
    ('Still Waters', 'nature', 'https://assets.scribes.app/audio/still_waters.mp3', 300),
    ('Cello Contemplation in D Minor', 'instrumental', 'https://assets.scribes.app/audio/cello_contemplation.mp3', 210),
    ('Quiet Sanctuary Drone', 'ambient', 'https://assets.scribes.app/audio/sanctuary_drone.mp3', 360)
ON CONFLICT (audio_url) DO NOTHING;
