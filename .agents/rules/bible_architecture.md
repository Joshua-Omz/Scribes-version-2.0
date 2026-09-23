# Scribes — Multi-Version Offline Bible Architecture Source of Truth
**Version 1.0 · Static Edge Distribution · Local Multi-SQLite · Universal Referencing**

> Scribes delivers scripture reading, searching, and multi-version comparison using a decentralized, offline-first edge architecture (similar to YouVersion). Core scripture text is completely decoupled from backend application servers.

---

### 1. Static Edge Distribution Invariant
* **Zero Scripture Read API Load:** Backend application servers MUST NOT serve scripture text, chapters, or verses via dynamic REST/GraphQL API endpoints.
* **Pre-Compiled SQLite Artifacts:** Bible translations are compiled at build time into immutable, vacuumed SQLite database files containing full text, pre-computed B-Tree indexes on `(book_id, chapter, verse)`, and SQLite `FTS5` virtual tables for instant lexical search.
* **Edge CDN Delivery:** Translation SQLite files are hosted on Cloudflare R2 / AWS S3 and distributed via CDN. Downloading a translation is a direct static HTTP GET against the CDN edge (or bundled in local assets for the default BSB translation).

### 2. Isolated Multi-Database File Architecture
* **One SQLite File Per Translation:** Each translation is stored on the client as an independent SQLite database file (e.g., `<app_doc_dir>/bible/bsb.sqlite3`, `<app_doc_dir>/bible/kjv.sqlite3`).
* **Zero Dynamic Schema Migration on Text:** Adding or removing a translation is purely a filesystem operation (download file / delete file). Never alter or rebuild a master Bible database when managing translations.
* **Local Search Execution:** All scripture text search queries run locally against the active translation's SQLite FTS5 table with zero network latency.

### 3. Universal Referencing Schema
* **Standardized Book & Verse Identifiers:** All translation databases MUST conform to a universal canonical schema (standard 3-letter USFM/OSIS book codes, canonical book order 1–66, chapter numbers, and verse numbers).
* **Zero-Network Parallel Reading:** Parallel view or translation switching performs local queries across the respective SQLite database connections using the universal reference ID (e.g. `JHN.3.16` or canonical integer index `book_order * 1,000,000 + chapter * 1,000 + verse`).

### 4. Decoupled User Data Synchronization
* **Storage Segregation:** User-generated data (highlights, notes, bookmarks, reading position) MUST NEVER be stored in translation SQLite files. They reside strictly in the primary Drift application database (`scribes_user.db`).
* **Relational Foreign Key By Reference:** User annotations reference scripture via universal composite keys `(book_code, chapter, verse)`.
* **Sync Boundary:** Offline mutations to user data are queued locally as `pending_sync` and batched to `/sync/push`. The backend application server handles only user mutation syncing, never Bible text delivery.
