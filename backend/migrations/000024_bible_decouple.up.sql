-- 000024_bible_decouple.up.sql

-- 1. Drop heavy scripture text tables from PostgreSQL
DROP TABLE IF EXISTS bible_verses CASCADE;
DROP TABLE IF EXISTS bible_books CASCADE;
DROP TABLE IF EXISTS bible_reading_position CASCADE;

-- 2. Add download/cdn metadata columns to bible_translations
ALTER TABLE bible_translations
    ADD COLUMN IF NOT EXISTS download_url TEXT,
    ADD COLUMN IF NOT EXISTS file_size_bytes BIGINT NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS version INT NOT NULL DEFAULT 1;

-- 3. Recreate bible_reading_positions using universal coordinates
CREATE TABLE IF NOT EXISTS bible_reading_positions (
    user_id               UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    book_code             VARCHAR(10) NOT NULL,   -- Standard USFM code, e.g. 'JHN', 'ROM'
    chapter               INT NOT NULL,
    verse                 INT NOT NULL DEFAULT 1,
    preferred_translation VARCHAR(10) NOT NULL DEFAULT 'BSB',
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_bible_reading_positions_user 
    ON bible_reading_positions (user_id);
