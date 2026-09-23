-- 000022_bible_decouple.down.sql

DROP TABLE IF EXISTS bible_reading_positions;
ALTER TABLE bible_translations DROP COLUMN IF EXISTS download_url;
ALTER TABLE bible_translations DROP COLUMN IF EXISTS file_size_bytes;
ALTER TABLE bible_translations DROP COLUMN IF EXISTS version;

CREATE TABLE IF NOT EXISTS bible_books (
    id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    translation_id UUID        NOT NULL REFERENCES bible_translations(id) ON DELETE CASCADE,
    name           TEXT        NOT NULL,
    short_name     TEXT        NOT NULL,
    testament      TEXT        NOT NULL,
    book_order     INT         NOT NULL,
    chapter_count  INT         NOT NULL,
    UNIQUE (translation_id, name)
);

CREATE TABLE IF NOT EXISTS bible_verses (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id       UUID        NOT NULL REFERENCES bible_books(id) ON DELETE CASCADE,
    chapter       INT         NOT NULL,
    verse         INT         NOT NULL,
    text          TEXT        NOT NULL,
    UNIQUE (book_id, chapter, verse)
);

CREATE TABLE IF NOT EXISTS bible_reading_position (
    user_id       UUID        PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    book_id       UUID        NOT NULL REFERENCES bible_books(id) ON DELETE CASCADE,
    chapter       INT         NOT NULL,
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
