#!/usr/bin/env python3
"""
Scribes — Bible Translation Packaging & Compression Pipeline
Compiles, validates, optimizes, and compresses SQLite Bible translation artifacts
for static CDN edge distribution (Cloudflare R2 / AWS S3).
"""

import os
import sys
import gzip
import json
import shutil
import hashlib
import sqlite3
import argparse
from typing import Dict, Any, Optional

DEFAULT_CDN_BASE = "https://cdn.scribes.app/bible"

KNOWN_TRANSLATIONS = {
    "BSB": {
        "code": "BSB",
        "name": "Berean Standard Bible",
        "language": "en",
        "attribution": "Berean Standard Bible, public domain (BSB). Holy Bible, Berean Standard Bible, BSB is produced in cooperation with Bible Hub, Discovery Bible, OpenBible.com, and the Berean Bible Translation Committee.",
        "is_bundled": True,
        "version": 1
    },
    "KJV": {
        "code": "KJV",
        "name": "King James Version (1769)",
        "language": "en",
        "attribution": "King James Version (KJV) 1769, Public Domain.",
        "is_bundled": False,
        "version": 1
    },
    "WEB": {
        "code": "WEB",
        "name": "World English Bible",
        "language": "en",
        "attribution": "World English Bible (WEB), Public Domain.",
        "is_bundled": False,
        "version": 1
    }
}

def compute_sha256(filepath: str) -> str:
    """Calculates SHA-256 checksum of a file in streaming chunks."""
    hasher = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(65536):
            hasher.update(chunk)
    return hasher.hexdigest()

def validate_and_optimize_sqlite(db_path: str) -> Dict[str, Any]:
    """Validates the schema invariants and runs VACUUM/optimize."""
    print(f"[*] Validating SQLite schema at: {db_path}")
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()

    # 1. Validate translation_meta
    cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='translation_meta'")
    if not cur.fetchone():
        conn.close()
        raise ValueError("Missing 'translation_meta' table in SQLite database.")

    cur.execute("SELECT code, name, language, attribution, schema_version FROM translation_meta LIMIT 1")
    meta_row = cur.fetchone()
    if not meta_row:
        conn.close()
        raise ValueError("Table 'translation_meta' is empty.")
    meta = {
        "code": meta_row[0],
        "name": meta_row[1],
        "language": meta_row[2],
        "attribution": meta_row[3],
        "schema_version": meta_row[4]
    }

    # 2. Validate books table
    cur.execute("SELECT count(*) FROM books")
    book_count = cur.fetchone()[0]
    if book_count != 66:
        conn.close()
        raise ValueError(f"Expected 66 canonical books, found {book_count}.")

    # 3. Validate verses table
    cur.execute("SELECT count(*) FROM verses")
    verse_count = cur.fetchone()[0]
    if verse_count < 30000:
        conn.close()
        raise ValueError(f"Unexpectedly low verse count: {verse_count}.")

    # 4. Validate FTS5 table
    cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='verses_fts'")
    if not cur.fetchone():
        conn.close()
        raise ValueError("Missing FTS5 virtual table 'verses_fts'.")

    # 5. Optimize database
    print("  -> Executing PRAGMA optimize, page_size, and VACUUM...")
    cur.execute("PRAGMA page_size = 4096;")
    cur.execute("PRAGMA optimize;")
    conn.commit()
    cur.execute("VACUUM;")
    conn.commit()
    conn.close()

    return {
        "meta": meta,
        "book_count": book_count,
        "verse_count": verse_count
    }

def compress_gzip(src_path: str, dst_path: str) -> None:
    """Compresses file using gzip level 9 for maximum CDN transfer savings."""
    print(f"[*] Compressing {src_path} -> {dst_path} (level=9)...")
    with open(src_path, "rb") as f_in:
        with gzip.open(dst_path, "wb", compresslevel=9) as f_out:
            shutil.copyfileobj(f_in, f_out)

def update_manifest(manifest_path: str, translation_entry: Dict[str, Any]) -> Dict[str, Any]:
    """Updates or adds translation entry to manifest.json."""
    data = {"manifest_version": 1, "translations": []}
    if os.path.exists(manifest_path):
        try:
            with open(manifest_path, "r", encoding="utf-8") as f:
                data = json.load(f)
        except Exception as e:
            print(f"  [!] Warning: Could not read existing manifest ({e}), creating fresh.")

    # Remove existing entry with same code
    code = translation_entry["code"]
    translations = [t for t in data.get("translations", []) if t.get("code") != code]
    translations.append(translation_entry)
    # Sort: bundled first, then by name
    translations.sort(key=lambda x: (not x.get("is_bundled", False), x.get("name", "")))
    data["translations"] = translations

    os.makedirs(os.path.dirname(manifest_path), exist_ok=True)
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    return data

def main():
    parser = argparse.ArgumentParser(description="Package SQLite Bible translations for Edge CDN distribution.")
    parser.add_argument("--code", required=True, help="Translation code (e.g. BSB, KJV, WEB)")
    parser.add_argument("--input", required=True, help="Path to input .sqlite3 database file")
    parser.add_argument("--output-dir", default="dist/bible", help="Directory for distribution artifacts")
    parser.add_argument("--version", type=int, default=1, help="Translation artifact version")
    parser.add_argument("--cdn-base", default=DEFAULT_CDN_BASE, help="Base URL for CDN edge downloads")
    parser.add_argument("--is-bundled", action="store_true", help="Flag if this translation is bundled in app assets")

    args = parser.parse_args()

    code = args.code.upper()
    info = KNOWN_TRANSLATIONS.get(code, {
        "code": code,
        "name": f"Translation {code}",
        "language": "en",
        "attribution": f"{code} Public Domain.",
        "is_bundled": args.is_bundled,
        "version": args.version
    })

    if args.is_bundled:
        info["is_bundled"] = True

    input_file = os.path.abspath(args.input)
    if not os.path.exists(input_file):
        print(f"[!] Error: Input file not found: {input_file}", file=sys.stderr)
        sys.exit(1)

    os.makedirs(args.output_dir, exist_ok=True)

    # 1. Validate & optimize
    stats = validate_and_optimize_sqlite(input_file)

    # 2. Prepare artifact filenames
    filename_base = f"{code.lower()}_v{args.version}"
    artifact_raw = os.path.join(args.output_dir, f"{filename_base}.sqlite3")
    artifact_gz = os.path.join(args.output_dir, f"{filename_base}.sqlite3.gz")

    # Copy optimized file to dist
    shutil.copy2(input_file, artifact_raw)

    # Compute uncompressed metrics
    uncompressed_bytes = os.path.getsize(artifact_raw)
    raw_sha256 = compute_sha256(artifact_raw)

    # 3. Compress
    compress_gzip(artifact_raw, artifact_gz)
    compressed_bytes = os.path.getsize(artifact_gz)
    gz_sha256 = compute_sha256(artifact_gz)

    savings_pct = (1.0 - (compressed_bytes / uncompressed_bytes)) * 100.0

    # 4. Manifest Entry
    download_url = f"{args.cdn_base}/{os.path.basename(artifact_gz)}"
    entry = {
        "code": code,
        "name": stats["meta"]["name"] or info.get("name", code),
        "language": stats["meta"]["language"] or info.get("language", "en"),
        "version": args.version,
        "attribution": stats["meta"]["attribution"] or info.get("attribution", ""),
        "is_bundled": info.get("is_bundled", False),
        "uncompressed_bytes": uncompressed_bytes,
        "compressed_bytes": compressed_bytes,
        "sha256": raw_sha256,
        "gz_sha256": gz_sha256,
        "download_url": download_url
    }

    # 5. Write to manifests across project locations
    manifest_locations = [
        os.path.join(args.output_dir, "manifest.json"),
        os.path.join(os.path.dirname(__file__), "..", "client", "assets", "bible", "manifest.json"),
        os.path.join(os.path.dirname(__file__), "..", "backend", "assets", "bible", "manifest.json")
    ]

    for loc in manifest_locations:
        loc = os.path.abspath(loc)
        update_manifest(loc, entry)
        print(f"  -> Updated manifest at: {loc}")

    # Output Summary
    print("\n" + "=" * 64)
    print("  BIBLE TRANSLATION PACKAGING COMPLETE")
    print("=" * 64)
    print(f"  Translation     : {code} ({entry['name']})")
    print(f"  Version         : {args.version}")
    print(f"  Books / Verses  : {stats['book_count']} books, {stats['verse_count']:,} verses")
    print(f"  Uncompressed    : {uncompressed_bytes / (1024*1024):.2f} MB ({uncompressed_bytes:,} bytes)")
    print(f"  SHA-256 (Raw)   : {raw_sha256}")
    print(f"  Gzipped         : {compressed_bytes / (1024*1024):.2f} MB ({compressed_bytes:,} bytes)")
    print(f"  SHA-256 (Gz)    : {gz_sha256}")
    print(f"  Bandwidth Saved : {savings_pct:.1f}%")
    print(f"  CDN Download URL: {download_url}")
    print("=" * 64 + "\n")

if __name__ == "__main__":
    main()
