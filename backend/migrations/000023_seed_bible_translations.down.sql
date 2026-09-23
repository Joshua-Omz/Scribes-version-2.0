-- 000023_seed_bible_translations.down.sql

DELETE FROM bible_translations WHERE code IN ('BSB', 'KJV', 'WEB');
