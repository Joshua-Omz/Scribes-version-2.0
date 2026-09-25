#!/usr/bin/env python3
"""
Scribes — Multi-Translation Bible Builder & Edge Packager
Compiles complete 66-book Bible translation databases (KJV, WEB, BBE, ASV, and
custom imports for NIV, NLT, MSG) into Schema v2 SQLite artifacts with canonical
integer coordinates and FTS5 full-text search tables.

Usage:
    # 1. Build and package King James Version (KJV)
    python scripts/build_bible_translations.py --translation KJV

    # 2. Build and package World English Bible (WEB)
    python scripts/build_bible_translations.py --translation WEB

    # 3. Build with your live Cloudflare R2 Public Dev URL
    python scripts/build_bible_translations.py --translation KJV --r2-url https://pub-xxxxxx.r2.dev

    # 4. Import a custom translation (e.g. NIV, NLT, MSG) from a JSON file:
    python scripts/build_bible_translations.py --custom-json /path/to/niv.json --code NIV --name "New International Version" --attribution "Biblica, Inc."
"""

import os
import sys
import gzip
import json
import time
import shutil
import hashlib
import sqlite3
import argparse
import urllib.request
import urllib.error
from typing import Dict, Any, List, Optional

# Standard 66 Canonical Books (Protestant Canon: 39 OT, 27 NT)
CANONICAL_BOOKS = [
    (1, "GEN", "Genesis", "Gen", "OT", 1, 50),
    (2, "EXO", "Exodus", "Exo", "OT", 2, 40),
    (3, "LEV", "Leviticus", "Lev", "OT", 3, 27),
    (4, "NUM", "Numbers", "Num", "OT", 4, 36),
    (5, "DEU", "Deuteronomy", "Deu", "OT", 5, 34),
    (6, "JOS", "Joshua", "Jos", "OT", 6, 24),
    (7, "JDG", "Judges", "Jdg", "OT", 7, 21),
    (8, "RUT", "Ruth", "Rut", "OT", 8, 4),
    (9, "1SA", "1 Samuel", "1Sa", "OT", 9, 31),
    (10, "2SA", "2 Samuel", "2Sa", "OT", 10, 24),
    (11, "1KI", "1 Kings", "1Ki", "OT", 11, 22),
    (12, "2KI", "2 Kings", "2Ki", "OT", 12, 25),
    (13, "1CH", "1 Chronicles", "1Ch", "OT", 13, 29),
    (14, "2CH", "2 Chronicles", "2Ch", "OT", 14, 36),
    (15, "EZR", "Ezra", "Ezr", "OT", 15, 10),
    (16, "NEH", "Nehemiah", "Neh", "OT", 16, 13),
    (17, "EST", "Esther", "Est", "OT", 17, 10),
    (18, "JOB", "Job", "Job", "OT", 18, 42),
    (19, "PSA", "Psalms", "Psa", "OT", 19, 150),
    (20, "PRO", "Proverbs", "Pro", "OT", 20, 31),
    (21, "ECC", "Ecclesiastes", "Ecc", "OT", 21, 12),
    (22, "SNG", "Song of Solomon", "Sng", "OT", 22, 8),
    (23, "ISA", "Isaiah", "Isa", "OT", 23, 66),
    (24, "JER", "Jeremiah", "Jer", "OT", 24, 52),
    (25, "LAM", "Lamentations", "Lam", "OT", 25, 5),
    (26, "EZK", "Ezekiel", "Ezk", "OT", 26, 48),
    (27, "DAN", "Daniel", "Dan", "OT", 27, 12),
    (28, "HOS", "Hosea", "Hos", "OT", 28, 14),
    (29, "JOL", "Joel", "Jol", "OT", 29, 3),
    (30, "AMO", "Amos", "Amo", "OT", 30, 9),
    (31, "OBA", "Obadiah", "Oba", "OT", 31, 1),
    (32, "JON", "Jonah", "Jon", "OT", 32, 4),
    (33, "MIC", "Micah", "Mic", "OT", 33, 7),
    (34, "NAM", "Nahum", "Nam", "OT", 34, 3),
    (35, "HAB", "Habakkuk", "Hab", "OT", 35, 3),
    (36, "ZEP", "Zephaniah", "Zep", "OT", 36, 3),
    (37, "HAG", "Haggai", "Hag", "OT", 37, 2),
    (38, "ZEC", "Zechariah", "Zec", "OT", 38, 14),
    (39, "MAL", "Malachi", "Mal", "OT", 39, 4),
    (40, "MAT", "Matthew", "Mat", "NT", 40, 28),
    (41, "MRK", "Mark", "Mrk", "NT", 41, 16),
    (42, "LUK", "Luke", "Luk", "NT", 42, 24),
    (43, "JHN", "John", "Jhn", "NT", 43, 21),
    (44, "ACT", "Acts", "Act", "NT", 44, 28),
    (45, "ROM", "Romans", "Rom", "NT", 45, 16),
    (46, "1CO", "1 Corinthians", "1Co", "NT", 46, 16),
    (47, "2CO", "2 Corinthians", "2Co", "NT", 47, 13),
    (48, "GAL", "Galatians", "Gal", "NT", 48, 6),
    (49, "EPH", "Ephesians", "Eph", "NT", 49, 6),
    (50, "PHP", "Philippians", "Php", "NT", 50, 4),
    (51, "COL", "Colossians", "Col", "NT", 51, 4),
    (52, "1TH", "1 Thessalonians", "1Th", "NT", 52, 5),
    (53, "2TH", "2 Thessalonians", "2Th", "NT", 53, 3),
    (54, "1TI", "1 Timothy", "1Ti", "NT", 54, 6),
    (55, "2TI", "2 Timothy", "2Ti", "NT", 55, 4),
    (56, "TIT", "Titus", "Tit", "NT", 56, 3),
    (57, "PHM", "Philemon", "Phm", "NT", 57, 1),
    (58, "HEB", "Hebrews", "Heb", "NT", 58, 13),
    (59, "JAS", "James", "Jas", "NT", 59, 5),
    (60, "1PE", "1 Peter", "1Pe", "NT", 60, 5),
    (61, "2PE", "2 Peter", "2Pe", "NT", 61, 3),
    (62, "1JN", "1 John", "1Jn", "NT", 62, 5),
    (63, "2JN", "2 John", "2Jn", "NT", 63, 1),
    (64, "3JN", "3 John", "3Jn", "NT", 64, 1),
    (65, "JUD", "Jude", "Jud", "NT", 65, 1),
    (66, "REV", "Revelation", "Rev", "NT", 66, 22),
]

KNOWN_PUBLIC_SOURCES = {
    "KJV": {
        "code": "KJV",
        "name": "King James Version (1769)",
        "language": "en",
        "attribution": "King James Version (KJV) 1769, Public Domain.",
        "url": "https://raw.githubusercontent.com/thiagobodruk/bible/master/json/en_kjv.json",
        "format": "bodruk_json"
    },
    "WEB": {
        "code": "WEB",
        "name": "World English Bible",
        "language": "en",
        "attribution": "World English Bible (WEB), Public Domain.",
        "url": "https://raw.githubusercontent.com/thiagobodruk/bible/master/json/en_web.json",
        "format": "bodruk_json"
    },
    "NIV": {
        "code": "NIV",
        "name": "New International Version",
        "language": "en",
        "attribution": "THE HOLY BIBLE, NEW INTERNATIONAL VERSION®, NIV® Copyright © 1973, 1978, 1984, 2011 by Biblica, Inc.® Used by permission. All rights reserved worldwide.",
        "url": "https://raw.githubusercontent.com/thiagobodruk/bible/master/json/en_niv.json",
        "format": "bodruk_json"
    },
    "NLT": {
        "code": "NLT",
        "name": "New Living Translation",
        "language": "en",
        "attribution": "Holy Bible, New Living Translation, copyright © 1996, 2004, 2015 by Tyndale House Foundation. Used by permission of Tyndale House Publishers, Inc., Carol Stream, Illinois 60188. All rights reserved.",
        "url": "https://raw.githubusercontent.com/thiagobodruk/bible/master/json/en_nlt.json",
        "format": "bodruk_json"
    },
    "ESV": {
        "code": "ESV",
        "name": "English Standard Version",
        "language": "en",
        "attribution": "The Holy Bible, English Standard Version. ESV® Text Edition: 2016. Copyright © 2001 by Crossway Bibles, a publishing ministry of Good News Publishers.",
        "url": "https://raw.githubusercontent.com/thiagobodruk/bible/master/json/en_esv.json",
        "format": "bodruk_json"
    },
    "NKJV": {
        "code": "NKJV",
        "name": "New King James Version",
        "language": "en",
        "attribution": "Scripture taken from the New King James Version®. Copyright © 1982 by Thomas Nelson. Used by permission. All rights reserved.",
        "url": "https://raw.githubusercontent.com/thiagobodruk/bible/master/json/en_nkjv.json",
        "format": "bodruk_json"
    },
    "ASV": {
        "code": "ASV",
        "name": "American Standard Version (1901)",
        "language": "en",
        "attribution": "American Standard Version (ASV) 1901, Public Domain.",
        "url": "https://raw.githubusercontent.com/thiagobodruk/bible/master/json/en_asv.json",
        "format": "bodruk_json"
    },
    "BBE": {
        "code": "BBE",
        "name": "Bible in Basic English",
        "language": "en",
        "attribution": "Bible in Basic English (BBE), Public Domain.",
        "url": "https://raw.githubusercontent.com/thiagobodruk/bible/master/json/en_bbe.json",
        "format": "bodruk_json"
    }
}

def compute_sha256(filepath: str) -> str:
    hasher = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(65536):
            hasher.update(chunk)
    return hasher.hexdigest()

def fetch_json(url: str, retries: int = 5) -> Any:
    req = urllib.request.Request(
        url,
        headers={"User-Agent": "ScribesBibleBuilder/4.0"}
    )
    for attempt in range(retries):
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                return json.loads(resp.read().decode("utf-8-sig"))
        except Exception as e:
            if attempt == retries - 1:
                raise
            time.sleep(2 ** attempt)

def init_database_schema(cursor: sqlite3.Cursor):
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS translation_meta (
            code              TEXT PRIMARY KEY,
            name              TEXT NOT NULL,
            language          TEXT NOT NULL DEFAULT 'en',
            attribution       TEXT NOT NULL,
            schema_version    INTEGER NOT NULL DEFAULT 2
        );
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS books (
            canonical_id  INTEGER PRIMARY KEY,
            code          TEXT NOT NULL UNIQUE,
            name          TEXT NOT NULL,
            short_name    TEXT NOT NULL,
            testament     TEXT NOT NULL,
            book_order    INTEGER NOT NULL,
            chapter_count INTEGER NOT NULL
        );
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS verses (
            id         INTEGER PRIMARY KEY,
            book_id    INTEGER NOT NULL REFERENCES books(canonical_id),
            chapter    INTEGER NOT NULL,
            verse      INTEGER NOT NULL,
            verse_end  INTEGER,
            text       TEXT NOT NULL,
            is_omitted INTEGER NOT NULL DEFAULT 0
        );
    """)

    cursor.execute("CREATE INDEX IF NOT EXISTS idx_books_code ON books (code);")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_books_order ON books (book_order);")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_verses_lookup ON verses (book_id, chapter, verse);")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_verses_range ON verses (book_id, chapter, verse, verse_end);")

    # FTS5 Full-Text Search Table
    cursor.execute("""
        CREATE VIRTUAL TABLE IF NOT EXISTS verses_fts USING fts5(
            text,
            content='verses',
            content_rowid='id'
        );
    """)

    cursor.execute("""
        CREATE TRIGGER IF NOT EXISTS verses_ai AFTER INSERT ON verses BEGIN
            INSERT INTO verses_fts(rowid, text) VALUES (new.id, new.text);
        END;
    """)
    cursor.execute("""
        CREATE TRIGGER IF NOT EXISTS verses_ad AFTER DELETE ON verses BEGIN
            INSERT INTO verses_fts(verses_fts, rowid, text) VALUES('delete', old.id, old.text);
        END;
    """)
    cursor.execute("""
        CREATE TRIGGER IF NOT EXISTS verses_au AFTER UPDATE ON verses BEGIN
            INSERT INTO verses_fts(verses_fts, rowid, text) VALUES('delete', old.id, old.text);
            INSERT INTO verses_fts(rowid, text) VALUES (new.id, new.text);
        END;
    """)

def seed_canonical_books(cursor: sqlite3.Cursor):
    for book in CANONICAL_BOOKS:
        cursor.execute(
            """INSERT OR REPLACE INTO books 
               (canonical_id, code, name, short_name, testament, book_order, chapter_count)
               VALUES (?, ?, ?, ?, ?, ?, ?)""",
            book
        )

def build_from_bodruk_json(cursor: sqlite3.Cursor, raw_data: List[Dict[str, Any]]) -> int:
    """Imports 66 books from Thiago Bodruk structure [ { chapters: [ [ "verse 1", ... ] ] } ]"""
    total_verses = 0
    verses_to_insert = []

    for book_idx, book_data in enumerate(raw_data):
        if book_idx >= 66:
            break
        canonical_id = book_idx + 1
        chapters = book_data.get("chapters", [])

        for ch_idx, chapter_verses in enumerate(chapters):
            chapter_num = ch_idx + 1
            for v_idx, verse_text in enumerate(chapter_verses):
                verse_num = v_idx + 1
                clean_text = " ".join(str(verse_text).strip().split())
                if clean_text:
                    coord_id = (canonical_id * 1000000) + (chapter_num * 1000) + verse_num
                    verses_to_insert.append((coord_id, canonical_id, chapter_num, verse_num, None, clean_text, 0))
                    total_verses += 1

    cursor.executemany(
        "INSERT INTO verses (id, book_id, chapter, verse, verse_end, text, is_omitted) VALUES (?, ?, ?, ?, ?, ?, ?)",
        verses_to_insert
    )
    return total_verses

def build_from_helloao_api(cursor: sqlite3.Cursor, translation_id: str) -> int:
    """Streams and imports chapters directly from HelloAO API."""
    print(f"[*] Fetching books from HelloAO API for {translation_id}...")
    catalog = fetch_json(f"https://bible.helloao.org/api/{translation_id}/books.json")
    books = catalog.get("books", [])
    total_verses = 0

    for book_entry in books:
        book_id_str = book_entry.get("id")
        # Match with canonical book
        matched = next((b for b in CANONICAL_BOOKS if b[1].lower() == book_id_str.lower() or b[3].lower() == book_id_str.lower()), None)
        if not matched:
            continue

        canonical_id = matched[0]
        chapter_count = book_entry.get("numberOfChapters", matched[6])
        print(f"  -> [{canonical_id}/66] {matched[2]} ({chapter_count} chapters)...")

        for ch in range(1, chapter_count + 1):
            ch_data = fetch_json(f"https://bible.helloao.org/api/{translation_id}/{book_id_str}/{ch}.json")
            content = ch_data.get("chapter", {}).get("content", [])
            verses_to_insert = []

            for item in content:
                if item.get("type") == "verse" and item.get("number", 0) > 0:
                    v_num = item["number"]
                    text_parts = []
                    for c in item.get("content", []):
                        if isinstance(c, str):
                            text_parts.append(c)
                        elif isinstance(c, dict) and "text" in c:
                            text_parts.append(c["text"])
                    v_text = " ".join("".join(text_parts).split())
                    if v_text:
                        coord_id = (canonical_id * 1000000) + (ch * 1000) + v_num
                        verses_to_insert.append((coord_id, canonical_id, ch, v_num, None, v_text, 0))
                        total_verses += 1

            if verses_to_insert:
                cursor.executemany(
                    "INSERT INTO verses (id, book_id, chapter, verse, verse_end, text, is_omitted) VALUES (?, ?, ?, ?, ?, ?, ?)",
                    verses_to_insert
                )
            time.sleep(0.02)

    return total_verses

def build_from_generic_json(cursor: sqlite3.Cursor, json_path: str) -> int:
    """
    Imports custom translations (e.g. NIV, NLT, MSG) from a local JSON file.
    Supports either:
      Format A: [ { "chapters": [ [ "verse 1", "verse 2" ] ] } ]
      Format B: { "verses": [ { "book": "JHN", "chapter": 3, "verse": 16, "text": "..." } ] }
    """
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    if isinstance(data, list):
        return build_from_bodruk_json(cursor, data)

    if isinstance(data, dict) and "books" in data and isinstance(data["books"], list):
        return build_from_bodruk_json(cursor, data["books"])

    if isinstance(data, dict) and "verses" in data and isinstance(data["verses"], list):
        verses_to_insert = []
        total_verses = 0
        book_map = {b[1].upper(): b[0] for b in CANONICAL_BOOKS}
        name_map = {b[2].lower(): b[0] for b in CANONICAL_BOOKS}

        for item in data["verses"]:
            raw_book = str(item.get("book", "")).upper()
            c_id = book_map.get(raw_book) or name_map.get(raw_book.lower())
            if not c_id:
                continue
            ch = int(item.get("chapter", 1))
            v = int(item.get("verse", 1))
            text = str(item.get("text", "")).strip()
            if text:
                coord_id = (c_id * 1000000) + (ch * 1000) + v
                verses_to_insert.append((coord_id, c_id, ch, v, None, text, 0))
                total_verses += 1

        cursor.executemany(
            "INSERT INTO verses (id, book_id, chapter, verse, verse_end, text, is_omitted) VALUES (?, ?, ?, ?, ?, ?, ?)",
            verses_to_insert
        )
        return total_verses

    raise ValueError(f"Unrecognized JSON structure in {json_path}")

def update_manifest(manifest_path: str, entry: Dict[str, Any]):
    data = {"manifest_version": 1, "translations": []}
    if os.path.exists(manifest_path):
        try:
            with open(manifest_path, "r", encoding="utf-8") as f:
                data = json.load(f)
        except Exception:
            pass

    code = entry["code"].upper()
    existing = [t for t in data.get("translations", []) if t.get("code") != code]
    existing.append(entry)
    existing.sort(key=lambda x: (not x.get("is_bundled", False), x.get("name", "")))
    data["translations"] = existing

    os.makedirs(os.path.dirname(manifest_path), exist_ok=True)
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def build_translation(trans_code: str, custom_info: Optional[Dict[str, Any]], custom_json: Optional[str], output_dir: str, cdn_bible_base: str):
    trans_code = trans_code.upper()
    info = KNOWN_PUBLIC_SOURCES.get(trans_code, {
        "code": trans_code,
        "name": f"Translation {trans_code}",
        "language": "en",
        "attribution": f"{trans_code} translation.",
    })

    if custom_info:
        if custom_info.get("name"):
            info["name"] = custom_info["name"]
        if custom_info.get("attribution"):
            info["attribution"] = custom_info["attribution"]

    temp_db_path = os.path.join(output_dir, f"{trans_code.lower()}_build.sqlite3")
    if os.path.exists(temp_db_path):
        os.remove(temp_db_path)

    print(f"\n=======================================================")
    print(f"  SCRIBES BIBLE COMPILATION PIPELINE: {trans_code}")
    print(f"  Name: {info['name']}")
    print(f"  Target CDN Base: {cdn_bible_base}")
    print(f"=======================================================\n")

    conn = sqlite3.connect(temp_db_path)
    cur = conn.cursor()

    print(f"[*] Initializing schema v2 with FTS5 and canonical coordinates for {trans_code}...")
    init_database_schema(cur)
    seed_canonical_books(cur)

    cur.execute(
        "INSERT INTO translation_meta (code, name, language, attribution, schema_version) VALUES (?, ?, ?, ?, 2)",
        (trans_code, info["name"], info.get("language", "en"), info["attribution"])
    )
    conn.commit()

    total_verses = 0
    if custom_json:
        print(f"[*] Importing from custom JSON: {custom_json}...")
        total_verses = build_from_generic_json(cur, custom_json)
    elif info.get("format") == "bodruk_json":
        print(f"[*] Downloading text from source mirror: {info['url']}...")
        raw_data = fetch_json(info["url"])
        total_verses = build_from_bodruk_json(cur, raw_data)
    elif info.get("format") == "helloao":
        total_verses = build_from_helloao_api(cur, "ENGWEBP")
    else:
        raise ValueError(f"Unknown source configuration for {trans_code}")

    print(f"[*] Rebuilding FTS5 full-text search virtual index ({total_verses} verses)...")
    cur.execute("INSERT INTO verses_fts(verses_fts) VALUES('rebuild');")
    cur.execute("PRAGMA user_version = 2;")
    conn.commit()

    print("[*] Optimizing database with VACUUM and ANALYZE...")
    cur.execute("VACUUM;")
    cur.execute("ANALYZE;")
    conn.commit()
    conn.close()

    artifact_raw = os.path.join(output_dir, f"{trans_code.lower()}_v1.sqlite3")
    artifact_gz = os.path.join(output_dir, f"{trans_code.lower()}_v1.sqlite3.gz")
    shutil.copy2(temp_db_path, artifact_raw)
    os.remove(temp_db_path)

    uncompressed_bytes = os.path.getsize(artifact_raw)
    raw_sha256 = compute_sha256(artifact_raw)

    print(f"[*] Compressing database with Gzip (level 9)...")
    with open(artifact_raw, "rb") as f_in:
        with gzip.open(artifact_gz, "wb", compresslevel=9) as f_out:
            shutil.copyfileobj(f_in, f_out)

    compressed_bytes = os.path.getsize(artifact_gz)
    gz_sha256 = compute_sha256(artifact_gz)

    download_url = f"{cdn_bible_base}/{trans_code.lower()}_v1.sqlite3.gz"

    manifest_entry = {
        "code": trans_code,
        "name": info["name"],
        "language": info.get("language", "en"),
        "version": 1,
        "attribution": info["attribution"],
        "is_bundled": False,
        "uncompressed_bytes": uncompressed_bytes,
        "compressed_bytes": compressed_bytes,
        "sha256": raw_sha256,
        "gz_sha256": gz_sha256,
        "download_url": download_url
    }

    print(f"[*] Updating dist/bible/manifest.json...")
    update_manifest(os.path.join(output_dir, "manifest.json"), manifest_entry)

    client_manifest = os.path.join("client", "assets", "bible", "manifest.json")
    if os.path.exists(os.path.dirname(client_manifest)):
        update_manifest(client_manifest, manifest_entry)

    print(f"\n=======================================================")
    print(f"  SUCCESSFULLY PACKAGED {trans_code}!")
    print(f"  SQLite Database:     {artifact_raw} ({uncompressed_bytes / (1024*1024):.2f} MB)")
    print(f"  Compressed Archive:  {artifact_gz} ({compressed_bytes / (1024*1024):.2f} MB)")
    print(f"  SQLite SHA-256:      {raw_sha256}")
    print(f"  GZip SHA-256:        {gz_sha256}")
    print(f"  Download URL:        {download_url}")
    print(f"=======================================================\n")

def main():
    parser = argparse.ArgumentParser(description="Build and package full SQLite Bible translations for Scribes.")
    parser.add_argument("--translation", default="KJV", help="Translation code (e.g. KJV, WEB, NIV, NLT, ALL, or comma-separated list)")
    parser.add_argument("--code", help="Custom translation code (e.g. NIV, NLT, MSG)")
    parser.add_argument("--name", help="Custom translation full name")
    parser.add_argument("--attribution", help="Custom translation attribution text")
    parser.add_argument("--custom-json", help="Path to local JSON file for custom translation import")
    parser.add_argument("--output-dir", default="dist/bible", help="Output directory for packaged artifacts")
    parser.add_argument("--r2-url", default="", help="Your live Cloudflare R2 Public Dev URL or custom domain (e.g. https://pub-xxxxxx.r2.dev)")

    args = parser.parse_args()

    r2_base = args.r2_url.strip().rstrip("/")
    if not r2_base:
        r2_base = os.getenv("R2_PUBLIC_URL", "").strip().rstrip("/")
    if not r2_base:
        r2_base = "https://cdn.scribes.app"

    cdn_bible_base = f"{r2_base}/bible"
    os.makedirs(args.output_dir, exist_ok=True)

    if args.custom_json:
        code = (args.code or "CUSTOM").upper()
        custom_info = {"name": args.name, "attribution": args.attribution}
        build_translation(code, custom_info, args.custom_json, args.output_dir, cdn_bible_base)
    else:
        req = args.translation.strip().upper()
        if req == "ALL":
            codes = list(KNOWN_PUBLIC_SOURCES.keys())
        else:
            codes = [c.strip().upper() for c in req.split(",") if c.strip()]

        for code in codes:
            build_translation(code, None, None, args.output_dir, cdn_bible_base)

    print("\nNext step: Publish to your live Cloudflare R2 bucket:")
    print("  cd backend && go run ./cmd/publish-bible\n")

if __name__ == "__main__":
    main()
