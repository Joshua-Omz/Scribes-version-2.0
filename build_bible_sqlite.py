import os
import sqlite3
import json
import time
import urllib.request
import urllib.error

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "client", "assets", "bible")
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "bsb.sqlite3")

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

def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print(f"Connecting to SQLite database at: {OUTPUT_FILE}")
    conn = sqlite3.connect(OUTPUT_FILE)
    cursor = conn.cursor()

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS books (
            id            INTEGER PRIMARY KEY,
            name          TEXT NOT NULL,
            short_name    TEXT NOT NULL,
            testament     TEXT NOT NULL,
            book_order    INTEGER NOT NULL,
            chapter_count INTEGER NOT NULL
        );
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS verses (
            id       INTEGER PRIMARY KEY AUTOINCREMENT,
            book_id  INTEGER NOT NULL REFERENCES books(id),
            chapter  INTEGER NOT NULL,
            verse    INTEGER NOT NULL,
            text     TEXT NOT NULL
        );
    """)

    cursor.execute("CREATE INDEX IF NOT EXISTS idx_verses_lookup ON verses (book_id, chapter, verse);")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_books_name ON books (name, short_name);")
    conn.commit()

    print("Fetching BSB books metadata from HelloAO...")
    books_data = fetch_json("https://bible.helloao.org/api/BSB/books.json")
    books = books_data.get("books", [])
    print(f"Found {len(books)} books.")

    for idx, b in enumerate(books, 1):
        book_id_str = b["id"]
        book_name = b["name"]
        order = b["order"]
        num_chapters = b["numberOfChapters"]
        testament = "new" if order >= 40 else "old"

        cursor.execute(
            "INSERT OR REPLACE INTO books (id, name, short_name, testament, book_order, chapter_count) VALUES (?, ?, ?, ?, ?, ?)",
            (idx, book_name, book_id_str, testament, order, num_chapters)
        )
        conn.commit()

        # Check existing chapters for this book
        cursor.execute("SELECT DISTINCT chapter FROM verses WHERE book_id = ?", (idx,))
        existing_chapters = set(row[0] for row in cursor.fetchall())

        if len(existing_chapters) == num_chapters:
            print(f"[{idx}/66] {book_name} already complete ({num_chapters} chapters). Skipping.")
            continue

        print(f"[{idx}/66] Importing {book_name} ({num_chapters} chapters, {len(existing_chapters)} already present)...")

        for ch in range(1, num_chapters + 1):
            if ch in existing_chapters:
                continue

            ch_url = f"https://bible.helloao.org/api/BSB/{book_id_str}/{ch}.json"
            ch_data = fetch_json(ch_url)

            content = ch_data.get("chapter", {}).get("content", [])
            verses_to_insert = []

            for item in content:
                if item.get("type") == "verse" and item.get("number", 0) > 0:
                    verse_num = item["number"]
                    text_parts = []
                    for c in item.get("content", []):
                        if isinstance(c, str):
                            text_parts.append(c)
                        elif isinstance(c, dict) and "text" in c:
                            text_parts.append(c["text"])
                    verse_text = " ".join("".join(text_parts).split())
                    if verse_text:
                        verses_to_insert.append((idx, ch, verse_num, verse_text))

            if verses_to_insert:
                cursor.executemany(
                    "INSERT INTO verses (book_id, chapter, verse, text) VALUES (?, ?, ?, ?)",
                    verses_to_insert
                )
                conn.commit()

            time.sleep(0.05) # Friendly throttle

    # Check total verses
    cursor.execute("SELECT count(*) FROM verses")
    total_verses = cursor.fetchone()[0]

    cursor.execute("PRAGMA user_version = 1;")
    conn.commit()
    cursor.execute("VACUUM;")
    conn.commit()
    conn.close()

    file_size_mb = os.path.getsize(OUTPUT_FILE) / (1024 * 1024)
    print(f"\n=======================================================")
    print(f"  BIBLE SEEDING 100% COMPLETE!")
    print(f"Database Path: {OUTPUT_FILE}")
    print(f"Total Books: {len(books)} / 66")
    print(f"Total Verses: {total_verses} / 31,102")
    print(f"Final Size: {file_size_mb:.2f} MB")
    print(f"=======================================================\n")

if __name__ == "__main__":
    main()
