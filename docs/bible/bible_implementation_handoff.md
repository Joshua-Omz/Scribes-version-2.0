# Scribes — Bible Feature Implementation Handoff
**Version 1.0 · Ready-to-build spec, referencing the full contract**

> The complete design is already specified in `scribes_bible_drawer_contract.md`. This document is the execution checklist — what to build, in what order, and how to prove it actually works before declaring it done. Given the sync patch history, verification is treated as seriously as implementation here.

---

## Before Writing Any Code

1. Confirm `scribes_bible_drawer_contract.md` is available to whoever implements this — it has the full schema, all six endpoints, and the Flutter widget specs.
2. This is a **new, isolated feature** — it does not touch `posts`, `notes`, `sync`, or any existing table. Zero risk of the kind of cross-feature breakage that happened with the follow-endpoint mapping bug.
3. Confirm the BSB import source is ready before writing backend code — the import script needs real data to run against, not a placeholder.

---

## Build Order

### Step 1 — Data import (do this first, independently of any API work)

```bash
# Using the HelloAO CLI per the contract's §2
npx @helloao/cli export --translation BSB --format json --output ./bible-data/

# Then run the one-off import script (not part of the migration pipeline)
go run cmd/import-bible/main.go --input ./bible-data/ --translation BSB
```

**Verification before proceeding:**
```sql
-- Run directly against the database, not assumed
SELECT COUNT(*) FROM bible_books;    -- expect exactly 66
SELECT COUNT(*) FROM bible_verses;   -- expect approximately 31,000
SELECT * FROM bible_books ORDER BY book_order LIMIT 5;  -- confirm Genesis is first, correct order
```

If these counts are off, stop here. Do not build the API layer against incomplete data.

### Step 2 — Migration 016 (schema)

Run exactly the SQL from the contract §2 — `bible_translations`, `bible_books`, `bible_verses`, `bible_reading_position`. This is additive-only, zero risk to existing tables.

### Step 3 — Backend package `internal/bible/`

Build in this order, verifying each layer compiles before moving to the next — same discipline as the sync fix:

1. `model.go` — domain types
2. `repository.go` — the four query methods (`GetVerseRange`, `GetChapter`, `GetBooks`, `Search`)
3. `service.go` — thin orchestration over the repository
4. `handler.go` — the six endpoints

### Step 4 — Router wiring

```go
// internal/server/router.go

// All PUBLIC — no Authorization header required, per the contract's non-negotiable #1
r.GET("/bible/books", bibleHandler.GetBooks)
r.GET("/bible/:book/:chapter", bibleHandler.GetChapter)
r.GET("/bible/:book/:chapter/:verseRange", bibleHandler.GetVerseRange)
r.GET("/bible/search", bibleHandler.Search)

// PROTECTED — tied to a specific user
protected.GET("/bible/reading-position", bibleHandler.GetReadingPosition)
protected.POST("/bible/reading-position", bibleHandler.SaveReadingPosition)
```

**Immediately verify these are actually public** — this is the exact class of thing that silently broke before (routes ending up in the wrong middleware group). Test with zero Authorization header before writing any Flutter code against them:

```bash
curl "https://your-api/bible/books"
# Expected: 200 with full book list — no token, no error

curl "https://your-api/bible/romans/8"
# Expected: 200 with all verses of Romans 8 — no token
```

### Step 5 — Flutter feature package

Build `lib/features/bible/` per the contract §6 — data, domain, application, presentation layers, following the same feature-based architecture as every other Scribes feature.

### Step 6 — Wire the existing `ScribesScriptureChip`

This is the integration point that gives the feature its actual value — the chip already exists per the original design brief, it just needs its `onTap` to call the new endpoint instead of doing nothing or showing static text. This should be a small, contained change to one existing widget file, not a rewrite.

### Step 7 — Build the Bible Drawer UI

Per contract §6 — book list, chapter view, search, verse typesetting with the gold superscript numbers described in the contract. Wire the navigation icon into the app chrome per §7.

---

## The Verification That Actually Matters

Given the pattern from Patch 2, the standard here is: **inside-the-app confirmation is not sufficient on its own.** Two checks, both required before this is called done.

### Inside-app check
- Tap a scripture chip on any post → confirm real BSB verse text renders inline, not a modal
- Open the Bible Drawer from the nav icon → confirm it opens to Genesis 1 (or a saved position) with real text
- Search "steadfast love" in the drawer → confirm real matching verses return

### Independent check — outside the app
```bash
curl "https://your-api/bible/genesis/1/1-3"
```
Confirm the response contains actual Genesis 1:1-3 text, correctly attributed to BSB, with no auth token. This proves the data path works independent of whatever the Flutter client is doing — the same principle that caught the sync gap applies here: never trust the UI's word for what the backend actually returned.

---

## Done Criteria — Copied Directly From the Contract, Restated as a Checklist

- [ ] 66 books, ~31,000 verses confirmed present via direct SQL query
- [ ] All six `/bible/*` endpoints respond correctly
- [ ] All GET endpoints under `/bible/*` work with **zero Authorization header** — independently curl-verified, not just assumed from router code
- [ ] `ScribesScriptureChip` tap shows real verse text inline (not modal) anywhere it appears — Post Detail, Compose preview, Post cards
- [ ] Bible Drawer opens from nav icon, navigates books → chapters → verses smoothly
- [ ] Search returns real matching results
- [ ] Reading position persists across app restart for authenticated users
- [ ] BSB attribution caption visible wherever verse text renders

---

*Scribes Bible Feature Implementation Handoff v1.0*
*Full design: scribes_bible_drawer_contract.md — this document is the execution and verification layer*
*Isolated feature — zero risk to sync, posts, or any existing table*