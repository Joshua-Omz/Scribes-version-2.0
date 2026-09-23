-- 000023_seed_bible_translations.up.sql

INSERT INTO bible_translations (
    code, name, language, attribution_text, source, is_active, is_default, download_url, file_size_bytes, version
) VALUES 
(
    'BSB',
    'Berean Standard Bible',
    'en',
    'Berean Standard Bible, public domain (BSB). Holy Bible, Berean Standard Bible, BSB is produced in cooperation with Bible Hub, Discovery Bible, OpenBible.com, and the Berean Bible Translation Committee.',
    'bundled',
    true,
    true,
    'https://cdn.scribes.app/bible/bsb_v1.sqlite3.gz',
    3891411,
    1
),
(
    'KJV',
    'King James Version (1769)',
    'en',
    'King James Version (KJV) 1769, Public Domain.',
    'edge_download',
    true,
    false,
    'https://cdn.scribes.app/bible/kjv_v1.sqlite3.gz',
    3950000,
    1
),
(
    'WEB',
    'World English Bible',
    'en',
    'World English Bible (WEB), Public Domain.',
    'edge_download',
    true,
    false,
    'https://cdn.scribes.app/bible/web_v1.sqlite3.gz',
    4100000,
    1
)
ON CONFLICT (code) DO UPDATE
SET 
    name = EXCLUDED.name,
    attribution_text = EXCLUDED.attribution_text,
    source = EXCLUDED.source,
    download_url = EXCLUDED.download_url,
    file_size_bytes = EXCLUDED.file_size_bytes,
    version = EXCLUDED.version;
