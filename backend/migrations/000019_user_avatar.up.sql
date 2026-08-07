-- MIGRATION 019: User Avatar

ALTER TABLE users
    ADD COLUMN avatar_url TEXT;
