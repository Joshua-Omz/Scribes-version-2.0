import os
import sqlite3
import json
import time
import urllib.request
import urllib.error

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "client", "assets", "bible")
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "bsb.sqlite3")

BSB_META = {
    "code": "BSB",
    "name": "Berean Standard Bible",
    "language": "en",
    "attribution": "Berean Standard Bible, public domain (BSB). Holy Bible, Berean Standard Bible, BSB is produced in cooperation with Bible Hub, Discovery Bible, OpenBible.com, and the Berean Bible Translation Committee.",
    "schema_version": 2
}

def fetch_json(url, max_retries=10):
    for attempt in range(max_retries):
        try:
            req = urllib.request.Request(
                url,
                headers={"User-Agent": "ScribesApp/3.0 (BibleBuilder)"}
            )
            with urllib.request.urlopen(req, timeout=20) as response:
                return json.loads(response.read().decode('utf-8'))
        except Exception as e:
            wait_time = min(30, 2 ** attempt)
            print(f"  [Attempt {attempt+1}/{max_retries}] Network warning for {url}: {e}. Retrying in {wait_time}s...")
            time.sleep(wait_time)
            if attempt == max_retries - 1:
                raise

def init_schema(cursor):
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS translation_meta (
            code              TEXT PRIMARY KEY,
            name              TEXT NOT NULL,
            language          TEXT NOT NULL,
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

    # FTS5 Virtual Table for sub-millisecond BM25 full-text search
    cursor.execute("""
        CREATE VIRTUAL TABLE IF NOT EXISTS verses_fts USING fts5(
            text,
            content='verses',
            content_rowid='id'
        );
    """)

    # Triggers to keep FTS5 synchronized
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

def migrate_existing_database(source_file, target_file):
    print(f"Migrating existing database from {source_file} to new schema...")
    temp_target = target_file + ".tmp"
    if os.path.exists(temp_target):
        os.remove(temp_target)

    src_conn = sqlite3.connect(source_file)
    src_cur = src_conn.cursor()

    tgt_conn = sqlite3.connect(temp_target)
    tgt_cur = tgt_conn.cursor()

    init_schema(tgt_cur)

    # Insert metadata
    tgt_cur.execute(
        "INSERT OR REPLACE INTO translation_meta (code, name, language, attribution, schema_version) VALUES (?, ?, ?, ?, ?)",
        (BSB_META["code"], BSB_META["name"], BSB_META["language"], BSB_META["attribution"], BSB_META["schema_version"])
    )

    # Migrate books
    src_cur.execute("SELECT id, name, short_name, testament, book_order, chapter_count FROM books ORDER BY id ASC")
    books = src_cur.fetchall()
    for b in books:
        canonical_id, name, short_name, testament, book_order, chapter_count = b
        code = short_name.upper()
        tgt_cur.execute(
            "INSERT INTO books (canonical_id, code, name, short_name, testament, book_order, chapter_count) VALUES (?, ?, ?, ?, ?, ?, ?)",
            (canonical_id, code, name, short_name, testament, book_order, chapter_count)
        )

    # Migrate verses with canonical coordinate id
    src_cur.execute("SELECT book_id, chapter, verse, text FROM verses ORDER BY book_id, chapter, verse")
    verses = src_cur.fetchall()
    verses_to_insert = []
    for row in verses:
        b_id, ch, v, text = row
        canonical_id = (b_id * 1000000) + (ch * 1000) + v
        verses_to_insert.append((canonical_id, b_id, ch, v, None, text, 0))

    tgt_cur.executemany(
        "INSERT INTO verses (id, book_id, chapter, verse, verse_end, text, is_omitted) VALUES (?, ?, ?, ?, ?, ?, ?)",
        verses_to_insert
    )

    # Populate FTS5 table
    tgt_cur.execute("INSERT INTO verses_fts(verses_fts) VALUES('rebuild')")

    tgt_conn.commit()
    tgt_cur.execute("PRAGMA user_version = 2;")
    tgt_cur.execute("VACUUM;")
    tgt_conn.commit()

    src_conn.close()
    tgt_conn.close()

    if os.path.exists(source_file):
        os.remove(source_file)
    os.rename(temp_target, target_file)
    print("Migration to version 2 schema complete!")

def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Check if existing database is v1
    if os.path.exists(OUTPUT_FILE):
        conn = sqlite3.connect(OUTPUT_FILE)
        cur = conn.cursor()
        cur.execute("PRAGMA user_version")
        ver = cur.fetchone()[0]
        cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='translation_meta'")
        has_meta = cur.fetchone() is not None
        conn.close()

        if ver < 2 or not has_meta:
            migrate_existing_database(OUTPUT_FILE, OUTPUT_FILE)
            return

    # If file doesn't exist, build from scratch via HelloAO
    print(f"Building fresh SQLite database at: {OUTPUT_FILE}")
    conn = sqlite3.connect(OUTPUT_FILE)
    cursor = conn.cursor()
    init_schema(cursor)

    cursor.execute(
        "INSERT OR REPLACE INTO translation_meta (code, name, language, attribution, schema_version) VALUES (?, ?, ?, ?, ?)",
        (BSB_META["code"], BSB_META["name"], BSB_META["language"], BSB_META["attribution"], BSB_META["schema_version"])
    )
    conn.commit()

    print("Fetching BSB books metadata from HelloAO...")
    books_data = fetch_json("https://bible.helloao.org/api/BSB/books.json")
    books = books_data.get("books", [])

    for idx, b in enumerate(books, 1):
        book_code = b["id"].upper()
        book_name = b["name"]
        order = b["order"]
        num_chapters = b["numberOfChapters"]
        testament = "NT" if order >= 40 else "OT"

        cursor.execute(
            "INSERT OR REPLACE INTO books (canonical_id, code, name, short_name, testament, book_order, chapter_count) VALUES (?, ?, ?, ?, ?, ?, ?)",
            (idx, book_code, book_name, b["id"], testament, order, num_chapters)
        )
        conn.commit()

        cursor.execute("SELECT DISTINCT chapter FROM verses WHERE book_id = ?", (idx,))
        existing_chapters = set(row[0] for row in cursor.fetchall())

        if len(existing_chapters) == num_chapters:
            print(f"[{idx}/66] {book_name} already complete ({num_chapters} chapters).")
            continue

        print(f"[{idx}/66] Importing {book_name} ({num_chapters} chapters)...")
        for ch in range(1, num_chapters + 1):
            if ch in existing_chapters:
                continue
            ch_url = f"https://bible.helloao.org/api/BSB/{b['id']}/{ch}.json"
            ch_data = fetch_json(ch_url)
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
                        coord_id = (idx * 1000000) + (ch * 1000) + v_num
                        verses_to_insert.append((coord_id, idx, ch, v_num, None, v_text, 0))

            if verses_to_insert:
                cursor.executemany(
                    "INSERT INTO verses (id, book_id, chapter, verse, verse_end, text, is_omitted) VALUES (?, ?, ?, ?, ?, ?, ?)",
                    verses_to_insert
                )
                conn.commit()
            time.sleep(0.05)

    cursor.execute("INSERT INTO verses_fts(verses_fts) VALUES('rebuild')")
    cursor.execute("PRAGMA user_version = 2;")
    conn.commit()
    cursor.execute("VACUUM;")
    conn.commit()
    conn.close()

    file_size_mb = os.path.getsize(OUTPUT_FILE) / (1024 * 1024)
    print(f"\n=======================================================")
    print(f"  BIBLE COMPILATION COMPLETE!")
    print(f"Database: {OUTPUT_FILE} ({file_size_mb:.2f} MB)")
    print(f"=======================================================\n")

if __name__ == "__main__":
    main()
