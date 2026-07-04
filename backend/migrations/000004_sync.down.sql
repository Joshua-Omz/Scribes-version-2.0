DROP INDEX IF EXISTS idx_posts_seq;
DROP INDEX IF EXISTS idx_drafts_seq;
DROP INDEX IF EXISTS idx_notes_seq;

ALTER TABLE posts  DROP COLUMN IF EXISTS server_sequence;
ALTER TABLE drafts DROP COLUMN IF EXISTS server_sequence;
ALTER TABLE notes  DROP COLUMN IF EXISTS server_sequence;
