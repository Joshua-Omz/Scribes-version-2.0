-- 000021_bible.up.sql

CREATE TABLE IF NOT EXISTS bible_translations (
    id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    code              TEXT        NOT NULL UNIQUE,   -- "BSB", "WEB", "NIV"
    name              TEXT        NOT NULL,           -- "Berean Standard Bible"
    language          TEXT        NOT NULL DEFAULT 'en',
    attribution_text  TEXT        NOT NULL,           -- "Berean Standard Bible, public domain"
    source            TEXT        NOT NULL DEFAULT 'self_hosted',  -- 'self_hosted' | 'downloaded'
    is_active         BOOLEAN     NOT NULL DEFAULT true,
    is_default        BOOLEAN     NOT NULL DEFAULT false
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_one_default_translation
    ON bible_translations (is_default) WHERE is_default = true;

CREATE TABLE IF NOT EXISTS bible_books (
    id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    translation_id UUID        NOT NULL REFERENCES bible_translations(id) ON DELETE CASCADE,
    name           TEXT        NOT NULL,          -- "Genesis"
    short_name     TEXT        NOT NULL,           -- "Gen"
    testament      TEXT        NOT NULL,           -- "old" | "new"
    book_order     INT         NOT NULL,           -- 1-66, for canonical ordering
    chapter_count  INT         NOT NULL,
    UNIQUE (translation_id, name)
);

CREATE INDEX IF NOT EXISTS idx_bible_books_order ON bible_books (translation_id, book_order);

CREATE TABLE IF NOT EXISTS bible_verses (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id       UUID        NOT NULL REFERENCES bible_books(id) ON DELETE CASCADE,
    chapter       INT         NOT NULL,
    verse         INT         NOT NULL,
    text          TEXT        NOT NULL,
    UNIQUE (book_id, chapter, verse)
);

CREATE INDEX IF NOT EXISTS idx_bible_verses_lookup
    ON bible_verses (book_id, chapter, verse);

CREATE INDEX IF NOT EXISTS idx_bible_verses_search
    ON bible_verses USING GIN (to_tsvector('english', text));

CREATE TABLE IF NOT EXISTS bible_reading_position (
    user_id       UUID        PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    book_id       UUID        NOT NULL REFERENCES bible_books(id) ON DELETE CASCADE,
    chapter       INT         NOT NULL,
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
