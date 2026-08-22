# Scribes — Bible Drawer & Quick-Read Feature Contract
**Version 2.0 · Tap-to-read scripture · Self-hosted Bible database**

> Two related features in one contract: (1) tapping any scripture reference chip anywhere in the app opens a quick-read overlay, and (2) a full Bible is accessible from a drawer for open reading and searching. Both are powered by the same self-hosted scripture database — no runtime dependency on an external Bible API. This version corrects stale totals from v1.0, adds the provider abstraction that keeps future translation downloads (e.g. YouVersion) architecturally cheap, and notes the connection to the export template.

---

## 1. The Data Source Decision

**Source: the Free Use Bible API dataset (AO Lab / HelloAO), imported once into Scribes' own PostgreSQL tables.**

Why self-hosted rather than calling an external API at runtime:
- Zero external dependency in the read path — the Bible works even if AO Lab's service is down
- Zero latency from a third-party round trip — scripture reads are local queries
- No rate limits to worry about at scale
- The dataset is public domain / openly licensed — self-hosting is fully permitted and the intended usage pattern via their CLI tool
- Consistent with Scribes having no commercial layer — a free ministry platform sits cleanly inside every Bible provider's open-access terms, with no risk of a paywall or subscription tripping a licensing clause later

**Translation for v1: Berean Standard Bible (BSB).**

Modern, highly readable English, explicitly released into the public domain for this exact purpose. It matches the accessible-but-serious tone Scribes is going for — not archaic KJV language, not a paraphrase that loses precision. The schema below is deliberately built to support additional translations — both self-hosted re-imports (like WEB) and, eventually, on-demand downloads from an external provider like YouVersion — without any structural change later. See §10.

---

## 2. Database Schema

```sql
-- 016_bible.up.sql

-- ── Translations ─────────────────────────────────────
-- Supports multiple translations from day one, even though
-- v1 ships with only BSB active. attribution_text exists
-- specifically so any future downloaded translation can carry
-- its own required credit line without a schema change.
CREATE TABLE bible_translations (
    id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    code              TEXT        NOT NULL UNIQUE,   -- "BSB", "WEB", "NIV"
    name              TEXT        NOT NULL,           -- "Berean Standard Bible"
    language          TEXT        NOT NULL DEFAULT 'en',
    attribution_text  TEXT        NOT NULL,           -- "Berean Standard Bible, public domain"
    source            TEXT        NOT NULL DEFAULT 'self_hosted',  -- 'self_hosted' | 'downloaded'
    is_active         BOOLEAN     NOT NULL DEFAULT true,
    is_default        BOOLEAN     NOT NULL DEFAULT false
);

-- Only one translation may be default at a time
CREATE UNIQUE INDEX idx_one_default_translation
    ON bible_translations (is_default) WHERE is_default = true;

-- ── Books ────────────────────────────────────────────
CREATE TABLE bible_books (
    id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    translation_id UUID        NOT NULL REFERENCES bible_translations(id),
    name           TEXT        NOT NULL,          -- "Genesis"
    short_name     TEXT        NOT NULL,           -- "Gen"
    testament      TEXT        NOT NULL,           -- "old" | "new"
    book_order     INT         NOT NULL,           -- 1-66, for canonical ordering
    chapter_count  INT         NOT NULL,
    UNIQUE (translation_id, name)
);

CREATE INDEX idx_bible_books_order ON bible_books (translation_id, book_order);

-- ── Verses ───────────────────────────────────────────
-- The actual scripture text. This is the largest table —
-- ~31,000 verses per translation.
CREATE TABLE bible_verses (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id       UUID        NOT NULL REFERENCES bible_books(id),
    chapter       INT         NOT NULL,
    verse         INT         NOT NULL,
    text          TEXT        NOT NULL,
    UNIQUE (book_id, chapter, verse)
);

CREATE INDEX idx_bible_verses_lookup
    ON bible_verses (book_id, chapter, verse);

-- Full-text search across all verse text — powers the Bible drawer's search
CREATE INDEX idx_bible_verses_search
    ON bible_verses USING GIN (to_tsvector('english', text));

-- ── Reading progress (optional, per-user) ────────────
-- Tracks the last position a user was reading in the Bible drawer.
-- Not required for v1 but trivial to add — one row per user.
CREATE TABLE bible_reading_position (
    user_id       UUID        PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    book_id       UUID        NOT NULL REFERENCES bible_books(id),
    chapter       INT         NOT NULL,
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**Data size estimate:** BSB has 66 books, ~1,189 chapters, ~31,000 verses. At an average of 100 bytes per verse row, the entire Bible occupies roughly 3-4MB in PostgreSQL. This is a negligible addition to database size — there is no scaling concern here at all, even with several translations cached over time.

### Import process (one-time, not runtime)

```bash
# Using the official HelloAO CLI tool to export BSB in a usable format
npx @helloao/cli export --translation BSB --format json --output ./bible-data/

# A one-off Go script (cmd/import-bible/main.go) reads the exported JSON
# and inserts into bible_translations, bible_books, bible_verses.
# This runs once during initial Scribes deployment setup —
# it is not part of the sprint/migration pipeline, it is a data seed script.
```

---

## 3. Backend Package: `internal/bible/`

```
internal/bible/
├── handler.go      — all Bible read endpoints
├── service.go       — lookup, parsing, search
├── repository.go    — bible_* table queries
├── provider.go       — BibleProvider interface (see §10)
└── model.go         — Verse, Chapter, Book, Translation domain types
```

### Domain model

```go
// internal/bible/model.go

type Translation struct {
    ID              uuid.UUID
    Code            string
    Name            string
    AttributionText string
    Source          string  // "self_hosted" | "downloaded"
    IsActive        bool
}

type Book struct {
    ID           uuid.UUID
    Name         string
    ShortName    string
    Testament    string
    Order        int
    ChapterCount int
}

type Verse struct {
    Book    string  // book name, denormalised for convenience in response
    Chapter int
    Verse   int
    Text    string
}

type Chapter struct {
    Book    string
    Chapter int
    Verses  []Verse
}

// A reference as parsed from an existing scripture_refs row
// or from the Bible drawer's own navigation
type Reference struct {
    Book       string
    Chapter    int
    VerseStart int
    VerseEnd   *int  // nil = single verse
}
```

### Service methods

```go
// internal/bible/service.go

type Service struct {
    repo *Repository
}

func NewService(repo *Repository) *Service

// GetVerseRange — the quick-read tap handler.
// Takes a scripture_refs row's data directly.
func (s *Service) GetVerseRange(ctx context.Context, ref Reference) ([]Verse, error)

// GetChapter — the drawer's full chapter reading view.
func (s *Service) GetChapter(ctx context.Context, bookName string, chapter int) (*Chapter, error)

// GetBooks — the drawer's book/chapter navigation list.
func (s *Service) GetBooks(ctx context.Context) ([]Book, error)

// Search — full-text search across all verse text.
func (s *Service) Search(ctx context.Context, query string, limit int) ([]Verse, error)

// SaveReadingPosition — persists where the user left off in the drawer.
func (s *Service) SaveReadingPosition(ctx context.Context, userID uuid.UUID, ref Reference) error

// GetReadingPosition — resumes the drawer at the last position.
func (s *Service) GetReadingPosition(ctx context.Context, userID uuid.UUID) (*Reference, error)
```

---

## 4. API Endpoints

All Bible endpoints are **PUBLIC** — scripture reading requires no authentication, consistent with the outward design principle. Only `SaveReadingPosition` and `GetReadingPosition` require auth, since they're tied to a specific user.

```
GET  /bible/books                                     PUBLIC
GET  /bible/:book/:chapter                            PUBLIC
GET  /bible/:book/:chapter/:verse_start-:verse_end    PUBLIC
GET  /bible/search                                    PUBLIC
GET  /bible/reading-position                          PROTECTED
POST /bible/reading-position                          PROTECTED
```

### `GET /bible/books`

```
Response 200:
{
  "translation": "BSB",
  "books": [
    { "name": "Genesis", "short_name": "Gen", "testament": "old", "order": 1, "chapter_count": 50 },
    { "name": "Exodus",  "short_name": "Exo", "testament": "old", "order": 2, "chapter_count": 40 },
    ...
  ]
}
```

### `GET /bible/:book/:chapter`

Used by the Bible drawer's full-chapter reading view.

```
Example: GET /bible/romans/8

Response 200:
{
  "translation": "BSB",
  "book": "Romans",
  "chapter": 8,
  "verses": [
    { "verse": 1, "text": "Therefore there is now no condemnation for those who are in Christ Jesus," },
    { "verse": 2, "text": "because through Christ Jesus the law of the Spirit of life has set you free from the law of sin and death." },
    ...
  ]
}

Response 404: book or chapter does not exist
```

### `GET /bible/:book/:chapter/:verse_start-:verse_end`

This is **the quick-read tap endpoint** — the one triggered by tapping any `ScribesScriptureChip` anywhere in the app.

```
Example: GET /bible/genesis/1/1-3

Response 200:
{
  "translation": "BSB",
  "reference": "Genesis 1:1-3",
  "verses": [
    { "verse": 1, "text": "In the beginning God created the heavens and the earth." },
    { "verse": 2, "text": "Now the earth was formless and void..." },
    { "verse": 3, "text": "And God said, \"Let there be light,\" and there was light." }
  ]
}

Single verse: GET /bible/john/3/16-16 also works, or
              GET /bible/john/3/16 (no range) also supported
```

### `GET /bible/search`

Powers the Bible drawer's search field — different from the platform-wide `/search` endpoint (that searches posts and authors; this searches scripture text only).

```
Query:  ?q=steadfast love&limit=20

Response 200:
{
  "results": [
    { "book": "Psalm", "chapter": 136, "verse": 1,
      "text": "Give thanks to the LORD, for He is good; His loving devotion endures forever." },
    ...
  ]
}
```

### `POST /bible/reading-position`

```
Auth:  PROTECTED
Body:  { "book": "Romans", "chapter": 8 }
Response 200: { "message": "saved" }
```

### `GET /bible/reading-position`

```
Auth:  PROTECTED
Response 200:
{ "book": "Romans", "chapter": 8, "updated_at": "2025-06-14T20:00:00Z" }

Response 404: no saved position yet (client defaults to Genesis 1)
```

---

## 5. Connecting to the Existing Scripture Tag System

This is the key integration point. `scripture_refs` (used on Posts) already stores `book`, `chapter`, `verse_start`, `verse_end`. **No schema change needed there.** The `ScribesScriptureChip` widget simply calls the new Bible endpoint using the data it already has.

```
Existing flow (before this feature):
  Post has a scripture_refs row: { book: "Romans", chapter: 8, verse_start: 28, verse_end: 30 }
  Tapping the chip expands inline to show... nothing, or static text baked into the post

New flow (with this feature):
  Tapping the chip calls: GET /bible/romans/8/28-30
  Renders the real BSB verse text inline, live from the Bible database
  No dependency on the post author having typed the verse text themselves
```

This is a meaningful quality improvement — previously the scripture chip's inline expansion had no defined data source. Now it has one, and it's authoritative.

---

## 6. Flutter Implementation

### New feature package

```
lib/features/bible/
├── data/
│   ├── bible_api.dart
│   └── bible_repository.dart
├── domain/
│   ├── verse.dart
│   ├── chapter.dart
│   └── book.dart
├── application/
│   ├── bible_drawer_notifier.dart     — current book/chapter, navigation state
│   └── verse_lookup_provider.dart     — used by ScribesScriptureChip
└── presentation/
    ├── bible_drawer.dart              — the full drawer widget
    ├── bible_book_list.dart
    ├── bible_chapter_view.dart
    ├── bible_search_bar.dart
    └── quick_verse_sheet.dart          — the tap-to-read overlay
```

### The quick-read tap experience (`ScribesScriptureChip` — extended)

This is the existing widget from the design brief, now wired to real data:

```dart
// lib/core/widgets/scribes_scripture_chip.dart — extended behaviour

class ScribesScriptureChip extends ConsumerWidget {
  final Reference reference;  // { book, chapter, verseStart, verseEnd }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showQuickRead(context, ref),
      child: /* existing chip visual — gold border, book icon, "Genesis 1:1" */,
    );
  }

  void _showQuickRead(BuildContext context, WidgetRef ref) {
    // Per the original design brief: "expands inline, never as a modal"
    // Implementation: an expanding inline panel below the chip,
    // NOT a bottom sheet, NOT a new screen.
    // Fetches via verseLookupProvider(reference)
    // Shows: verse text in Cormorant Garamond italic, BSB attribution caption
    // A small "Read full chapter →" link at the bottom opens the Bible Drawer
    //   pre-navigated to this exact chapter
  }
}
```

**This preserves the original design law from the design brief:** *"Tappable — expands inline to show full verse context. Not a modal — inline expansion only."* The quick-read behaviour was already specified; this feature is what finally gives it real data.

### The Bible Drawer

```dart
// lib/features/bible/presentation/bible_drawer.dart

// Opened via:
//   - A dedicated icon in the app's navigation chrome (book icon)
//   - The "Read full chapter →" link inside any quick-read expansion
//   - Deep link from a scripture reference anywhere in the app

class BibleDrawer extends ConsumerStatefulWidget {
  // Implemented as a Flutter Drawer widget (slides in from the side)
  // or an EndDrawer, per platform convention — right side on most apps

  // Layout:
  //   Header: "Holy Bible" in Cormorant Garamond + translation badge "BSB"
  //   Search bar: DM Sans, searches verse text via GET /bible/search
  //   Book list (default view): Old Testament / New Testament sections
  //     Each book: name + chapter count, tappable
  //   Chapter view (after book selected):
  //     Chapter number selector (horizontal scrollable chips, 1 to N)
  //     Verse text: Cormorant Garamond body-lg, verse numbers as small
  //       gold superscript before each verse — classic Bible typesetting
  //     Smooth scroll, no pagination within a chapter
  //   Navigation: swipe or tap arrows for next/previous chapter
  //   Resume: on drawer open, if a saved reading_position exists,
  //     opens directly to that chapter instead of the book list
}
```

### Bible Drawer verse typesetting

This deserves its own note because it's a design decision, not just a data-binding one:

```dart
// Verse rendering pattern — classic Bible typesetting adapted to Scribes' voice

RichText(
  text: TextSpan(children: [
    TextSpan(
      text: '${verse.number} ',
      style: TextStyle(
        fontFamily: 'CormorantGaramond',
        fontSize: 11,               // superscript-style, small
        color: theme.gold,
        fontFeatures: [FontFeature.superscripts()],
      ),
    ),
    TextSpan(
      text: verse.text,
      style: TextStyle(
        fontFamily: 'CormorantGaramond',
        fontSize: 19,
        height: 1.8,
        color: theme.primaryText,
      ),
    ),
  ]),
)
```

Cormorant Garamond for the verse body — not DM Sans. Scripture is display-register text in the Scribes design language, consistent with how blockquotes render inside published posts. The Bible reads like it belongs to the same manuscript world as everything else in the app.

---

## 7. Where the Drawer is Accessible From

The Bible lives in the drawer. Concretely, this means:

- A book icon in the global navigation chrome (likely beside or near the notification bell in the Feed header) opens the Bible Drawer directly, with no scripture reference context — just open reading
- Every scripture chip's quick-read expansion includes a "Read full chapter →" link that opens the same drawer, pre-navigated
- The drawer persists reading position across sessions via `bible_reading_position`

This means there are two entry points into the same drawer — cold (just reading) and warm (from a specific reference) — and they converge on the same widget with different initial state.

---

## 8. Connection to Post Export

`scribes_export_template_design_guide.md` requires the scripture reference chip's styling to be pixel-faithful between in-app and exported PDF/image output. Practically, this means:

- When a published Post carrying a `scripture_refs` row is exported, the exported chip's verse text (if rendered inline in the export, rather than just the reference label) must be sourced from the same `bible_verses` table — never re-typed or paraphrased by the export pipeline
- The BSB attribution caption rule (non-negotiable #2 below) applies equally to export output — if verse text appears on an exported page, the attribution appears with it, same as it does in-app
- This is a shared dependency worth flagging to whoever builds the export pipeline: it needs read access to `internal/bible/` service methods, specifically `GetVerseRange`, not a duplicate implementation

---

## 9. Non-Negotiables for This Feature

1. **The Bible is always public.** No endpoint under `/bible/*` requires auth except reading-position save/get, which is inherently personal.
2. **Attribution is always visible.** A small caption naming the translation — "Berean Standard Bible" for BSB — appears wherever verse text is shown, in-app or exported, honouring the translation's public domain release terms and giving proper credit.
3. **No external API call at runtime for the default translation.** BSB is fully self-hosted in PostgreSQL. If AO Lab's service disappears entirely, Scribes' Bible continues to work unaffected. (This does not preclude an optional, explicitly user-triggered download of additional translations from an external provider — see §10 — but that is a one-time cache operation, not a runtime dependency.)
4. **Scripture chip inline expansion, never a modal.** This was already a design law from the original brief — this feature does not violate it, it fulfils it with real data.
5. **Verse text is immutable.** There is no edit endpoint for `bible_verses`. If a translation update is needed, it is a re-import, not an API-driven edit.
6. **No commercial gating of scripture, ever.** Consistent with Scribes having no commercial layer anywhere, Bible reading — including any future downloaded translation — is never placed behind a paywall, subscription, or premium tier. This is also what keeps the platform cleanly inside every Bible API provider's free/open-access terms.

---

## 10. Future Work — Additional Translation Downloads (Not Built in v1)

This section exists so that when translation downloads are built, they extend this schema rather than requiring a redesign. **Nothing in this section is implemented yet** — it documents the intended shape only.

### The provider abstraction

```go
// internal/bible/provider.go

type BibleProvider interface {
    ListAvailableTranslations(ctx context.Context) ([]Translation, error)
    GetChapter(ctx context.Context, translationCode, book string, chapter int) (*Chapter, error)
    GetVerseRange(ctx context.Context, translationCode string, ref Reference) ([]Verse, error)
}

// SelfHostedProvider serves BSB (and any other translation already
// cached in bible_verses) directly from PostgreSQL — this is what
// powers every endpoint in §4 today.
type SelfHostedProvider struct { repo *Repository }

// YouVersionProvider (future) — calls the YouVersion Platform API
// on demand, then caches the result into bible_verses permanently,
// converting a repeated external dependency into a one-time import.
type YouVersionProvider struct { apiKey string }
```

### Cache-on-download, not stream-on-read

```
User taps "Download NIV" in the Bible Drawer settings
        │
        ▼
Backend calls YouVersionProvider once: fetch all 66 books × all chapters
        │
        ▼
Backend inserts into bible_translations (source = 'downloaded'),
bible_books, bible_verses — exactly the same tables BSB already lives in
        │
        ▼
NIV now behaves identically to BSB — self-hosted, fast, zero further
dependency on YouVersion for that translation ever again
```

This is why `bible_translations.source` and `attribution_text` already exist in the §2 schema today, even though only BSB is seeded in v1 — adding a second translation later is a data-population task against existing tables, not a migration.

### Why this is deferred, not abandoned

Scribes having no commercial layer resolves the main licensing risk providers like YouVersion flag (future paywalls or ads can revoke API access) — but the download-and-cache flow itself is still real implementation work: the provider interface, a download-trigger endpoint, and a Flutter-side offline sync extension so a downloaded translation is available without a live connection. Estimated at roughly 1-2 weeks of focused work when prioritized. Not needed for Bible v1 to ship and function correctly with BSB alone.

---

## 11. Done Criteria

### Backend
- [ ] BSB data is fully imported — 66 books, all chapters, ~31,000 verses present in `bible_verses`
- [ ] `GET /bible/books` returns all 66 books in correct canonical order
- [ ] `GET /bible/romans/8` returns all verses of Romans 8 correctly
- [ ] `GET /bible/genesis/1/1-3` returns exactly verses 1 through 3
- [ ] `GET /bible/search?q=steadfast+love` returns relevant verse matches
- [ ] All `/bible/*` GET endpoints work with zero Authorization header — independently curl-verified, not just assumed from router code
- [ ] `POST /bible/reading-position` persists correctly per user
- [ ] Invalid book name returns 404, not 500

### Frontend
- [ ] Tapping any `ScribesScriptureChip` anywhere in the app expands inline with real BSB verse text — not a modal
- [ ] The "Read full chapter →" link opens the Bible Drawer pre-navigated to the correct chapter
- [ ] The Bible Drawer opens from the dedicated navigation icon with no reference context, defaulting to the last reading position (or Genesis 1 if none saved)
- [ ] Verse numbers render as small gold Cormorant Garamond superscripts before each verse
- [ ] Search within the drawer returns and displays matching verses
- [ ] Attribution caption is visible wherever verse text appears, in-app and in export output
- [ ] Drawer navigation (book list → chapter view → verse text) works smoothly with no jank
- [ ] Reading position persists across app restarts for authenticated users

---

## 12. Updated Totals

| Metric | Before this feature | After this feature |
|---|---|---|
| Endpoints | 64 (post no-billing correction: 67 − 3 billing endpoints removed) | 64 + 6 = **70 endpoints** |
| Tables | 30 (post no-billing correction: 33 − 3 billing tables + 1 fair_use_policy) | 30 + 4 = **34 tables** |
| Migrations | 015 (avatar column, per the R2 storage contract) | + 016 = **16 migrations** |

This reconciles with the totals in `scribes_media_contracts_v2.md` — the platform stands at 70 endpoints, 34 tables, 16 migrations once Bible and the no-billing correction are both accounted for together.

---

*Scribes Bible Drawer & Quick-Read Feature Contract v2.0*
*Self-hosted BSB · 6 endpoints, all but two public · Provider-abstracted for future translation downloads · Zero commercial gating, ever*