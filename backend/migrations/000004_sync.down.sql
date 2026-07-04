DROP INDEX IF EXISTS idx_posts_seq;
DROP INDEX IF EXISTS idx_drafts_seq;
DROP INDEX IF EXISTS idx_notes_seq;

ALTER TABLE posts  DROP COLUMN IF EXISTS server_sequence;
ALTER TABLE drafts DROP COLUMN IF EXISTS server_sequence;
ALTER TABLE notes  DROP COLUMN IF EXISTS server_sequence;
DROP TRIGGER IF EXISTS update_posts_sequence ON posts;
DROP TRIGGER IF EXISTS update_drafts_sequence ON drafts;
DROP TRIGGER IF EXISTS update_notes_sequence ON notes;

DROP FUNCTION IF EXISTS update_server_sequence();

DROP SEQUENCE IF EXISTS global_sequence;
