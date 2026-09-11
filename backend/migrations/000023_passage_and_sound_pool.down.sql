-- DOWN MIGRATION 023: Passage Panels & Sound Pool

DROP TABLE IF EXISTS passage_panels;
ALTER TABLE posts DROP COLUMN IF EXISTS sound_id;
DROP TABLE IF EXISTS sound_pool;
DROP TYPE IF EXISTS passage_panel_type;
