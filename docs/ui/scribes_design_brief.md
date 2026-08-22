# Scribes — Design Language Brief

**For use with Google Stitch (mockup generation)**  
Version 1.0 · Prepared for Scribes v2.0 Frontend

---

## 1\. Product Identity

Scribes is a spiritual knowledge publishing platform. It treats every published post as a durable, authored artifact — not a social media update. The visual language must communicate **permanence, authorship, and reverence** while remaining entirely usable as a modern mobile and web application.

The design direction is:

**Byzantine illuminated manuscript, reframed through a postmodern editorial lens.**

Think: the structural geometry of a 6th-century gospel codex, the gold leaf discipline of Byzantine iconography, the negative space and typographic restraint of a premium literary magazine. Not nostalgic. Not costume. The ancient informs the bones; the modern owns the surface.

---

## 2\. The Three Themes

Each theme is a different *mood* of the same manuscript. Same DNA, different atmosphere.

---

### Theme 1 — NIGHT

**"The manuscript read by candlelight."**

The primary theme. Dark, rich, intentional. Gold on black reads like ink pressed into vellum illuminated from behind.

| Role | Value | Usage |
| :---- | :---- | :---- |
| Background | `#0A0A0A` | App background, card base |
| Surface | `#111111` | Elevated cards, sheets |
| Surface raised | `#1A1714` | Modals, drawers |
| Primary text | `#F0EDE6` | Body copy, headings |
| Secondary text | `#8A8070` | Captions, timestamps, metadata |
| Gold — primary | `#C9A84C` | CTAs, active states, scripture tags, highlights |
| Gold — muted | `#7A6230` | Borders, dividers, inactive icons |
| Orange — accent | `#D4621A` | Reactions, alerts, live indicators |
| Orange — soft | `#3D2010` | Reaction chip backgrounds |
| Border | `#2A2520` | Card outlines, rule lines |
| Ornament | `#C9A84C` at 20% opacity | Decorative geometric overlays |

**Mood reference for Stitch:** *A leather-bound codex opened at night. Gold letterforms on dark vellum. Candlelight warmth without warmth becoming muddy.*

---

### Theme 2 — PARCHMENT

**"The manuscript in afternoon light."**

The light theme. Not white — parchment. Cream that has aged, not degraded. Gold presses forward against the warm ground. Feels like reading a physical document.

| Role | Value | Usage |
| :---- | :---- | :---- |
| Background | `#F5F0E8` | App background |
| Surface | `#FDFAF4` | Cards, sheets |
| Surface raised | `#FFFFFF` | Modals, focused states |
| Primary text | `#1A1612` | Body copy, headings |
| Secondary text | `#6B6055` | Captions, metadata |
| Gold — primary | `#9A7020` | CTAs, active states, highlights |
| Gold — muted | `#C8B070` | Borders, ornament strokes |
| Orange — accent | `#C4511A` | Reactions, alerts |
| Orange — soft | `#FAEADE` | Reaction backgrounds |
| Border | `#DDD5C0` | Card outlines, dividers |
| Ornament | `#9A7020` at 15% opacity | Decorative overlays |

**Mood reference for Stitch:** *Afternoon in a library. Warm cream pages, deep ink, gold-stamped chapter headers. The kind of book you don't fold pages in.*

---

### Theme 3 — SILVER

**"The manuscript in a modern archive."**

The cool, neutral theme. Silver and white with gold as the only warmth. Feels institutional but not clinical — like a well-curated museum display case. Orange lands sharp and deliberate against the cool ground.

| Role | Value | Usage |
| :---- | :---- | :---- |
| Background | `#F2F2F4` | App background |
| Surface | `#FFFFFF` | Cards, sheets |
| Surface raised | `#FAFAFC` | Modals, elevated surfaces |
| Primary text | `#111116` | Body copy, headings |
| Secondary text | `#72727A` | Captions, metadata |
| Gold — primary | `#B08A2A` | CTAs, active states, highlights |
| Gold — muted | `#D4C080` | Borders, decorative strokes |
| Silver — accent | `#9EA0AA` | Icons, secondary UI chrome |
| Orange — accent | `#D4520A` | Reactions, alerts, live indicators |
| Orange — soft | `#FAEDE4` | Reaction chip backgrounds |
| Border | `#E0E0E6` | Card outlines, dividers |
| Ornament | `#B08A2A` at 12% opacity | Decorative geometric overlays |

**Mood reference for Stitch:** *A digitised manuscript in a gallery interface. Clean white walls, precise labels, one gold object in the case that draws every eye.*

---

## 3\. Typography

Two typefaces. One carries the ancient voice. One carries the modern structure.

### Display / Heading — Cormorant Garamond

- Use for: Post titles, author names on profile, section headers, app wordmark  
- Weights: Light (300) for large display, SemiBold (600) for headings, Bold (700) for emphasis  
- Character: Deeply serifed, high contrast strokes, Renaissance origin — reads as scholarly without being stiff  
- Letter spacing: Slightly tracked out at display sizes (+0.02em to \+0.04em)  
- Line height: Tight at display (1.1), comfortable at body (1.5)

### Body / UI — DM Sans

- Use for: Body text, captions, UI labels, buttons, navigation, metadata  
- Weights: Regular (400) for body, Medium (500) for UI labels, SemiBold (600) for CTAs  
- Character: Geometric, neutral, highly legible at small sizes — the modern counterpart  
- Letter spacing: Default at body, \+0.05em on uppercase labels and badges

### Type Scale (mobile base)

| Token | Size | Font | Weight | Usage |
| :---- | :---- | :---- | :---- | :---- |
| display-xl | 40px | Cormorant Garamond | 300 | Hero post title |
| display-lg | 32px | Cormorant Garamond | 600 | Section title, profile name |
| display-md | 24px | Cormorant Garamond | 600 | Card heading, post title |
| body-lg | 17px | DM Sans | 400 | Post body text |
| body-md | 15px | DM Sans | 400 | Comment text, descriptions |
| label-lg | 13px | DM Sans | 500 | UI labels, nav items |
| label-sm | 11px | DM Sans | 500 | Timestamps, tags, badges |
| caption | 10px | DM Sans | 400 | Fine print, metadata |

---

## 4\. Ornamental System

This is the detail that makes Scribes feel Byzantine without being a costume. Ornament is used sparingly and structurally — never decoratively for decoration's sake.

### Ornament Rules

- **Border corners only.** Illuminated manuscript detail appears at card corners and divider endpoints — never tiled across surfaces.  
- **Gold only.** Ornament is always rendered in the theme's gold token. Never in orange, silver, or text colors.  
- **Geometric, not figurative.** Byzantine cross-knot geometry, interlace patterns, and meander borders. No pictorial illustration.  
- **Opacity-controlled.** Ornamental elements sit at 12–20% opacity in most contexts. They recede — they do not compete with content.  
- **Three placement contexts:**  
  1. **Section dividers** — a thin horizontal rule with a small geometric medallion centred on it  
  2. **Card corners** — a quarter-turn interlace motif at the top-left corner of featured post cards  
  3. **Wordmark surround** — the app name "Scribes" in Cormorant Garamond, flanked by a symmetrical interlace ornament on each side

### Ornament Do Not

- Do not place ornament on every card — reserve for featured/hero contexts only  
- Do not animate ornament  
- Do not use ornament on interactive components (buttons, inputs, chips)  
- Do not scale ornament below 16px — it becomes noise

---

## 5\. Shape & Surface Language

### Border Radius

| Context | Radius |
| :---- | :---- |
| Cards (post, note) | 10px |
| Chips, badges, tags | 4px |
| Buttons | 6px |
| Bottom sheets, modals | 16px top corners |
| Input fields | 6px |
| Avatar — author | 50% (circle) |
| Avatar — anonymous | 8px (slight rounding only) |

### Elevation

Scribes does not use drop shadows in the traditional sense. Elevation is communicated through **border \+ background contrast only** — a slightly lighter surface against the background, outlined by the theme's border token.

Exception: Bottom sheets and modals use a single, very soft shadow (`0 -4px 40px rgba(0,0,0,0.18)` on Night theme).

### Dividers

Thin, 0.5px rule lines in the border token color. On featured section breaks, a centred gold ornament medallion is placed on the rule.

---

## 6\. Iconography

- Style: **Outlined**, 1.5px stroke weight, rounded joins  
- Size: 20px standard, 24px navigation, 16px inline  
- Gold fill state: Active/selected icons switch from outlined to a **gold-filled** variant  
- Source: Use Lucide Icons as the base set — they match the stroke weight and geometric neutrality required  
- Custom icons needed:  
  - "Amen" reaction — stylised cross or flame glyph  
  - "Insightful" reaction — lit candle or open eye  
  - "Thought-Provoking" reaction — quill or scroll glyph  
  - Scripture reference tag — an open book glyph with a bookmark

---

## 7\. Component Behaviour Notes (for Stitch)

### Post Card

- Cormorant Garamond title (display-md, 24px)  
- Author handle in DM Sans label-sm  
- Scripture ref chip in gold border, gold text, label-sm  
- Reaction bar: three custom reaction icons \+ aggregate counts  
- Optional: ornamental corner motif on featured cards (top-left, gold, 16% opacity)  
- Immutability indicator: a small lock icon \+ "v2" version badge on revised posts

### Bottom Navigation

- 4 tabs: Feed · Explore · Compose · Profile  
- Active tab: gold icon fill \+ gold label  
- Inactive: silver/muted icon, no label shown

### Compose FAB (Floating Action Button)

- Octagonal or slightly geometric shape — not a standard circle  
- Gold background, black quill icon  
- Positioned bottom-right, raised

### Reaction Chips

- Small pill shape (4px radius)  
- Orange-soft background, orange-accent text in Night/Silver themes  
- Gold-soft background, gold text in Parchment theme

### Scripture Reference Tag

- Bordered chip: gold border, transparent fill  
- Open book icon \+ "Genesis 1:1" in label-sm  
- Tappable — expands to show full verse context

### Version History Indicator

- Appears below post header on revised posts  
- Small clock icon \+ "Revised · v3" in label-sm, secondary text color  
- Tappable — opens version history bottom sheet

---

## 8\. Stitch Prompt Template

Use the following as your base prompt when generating each screen in Google Stitch. Customise the `[SCREEN NAME]` and `[SCREEN DESCRIPTION]` fields per screen.

---

Design a mobile UI screen for a spiritual knowledge publishing app called Scribes.

THEME: \[Night / Parchment / Silver\]

SCREEN: \[SCREEN NAME\]

DESCRIPTION: \[SCREEN DESCRIPTION\]

Design language:

\- Byzantine illuminated manuscript aesthetic reframed through a postmodern editorial lens

\- Spacious and editorial — premium magazine layout with generous whitespace

\- Typography: Cormorant Garamond for all headings and titles (high-contrast serif, Renaissance feel); DM Sans for all body text, labels, and UI chrome

\- Colour palette (Night theme): Background \#0A0A0A, Surface \#111111, Primary text \#F0EDE6, Gold \#C9A84C, Orange accent \#D4621A, Border \#2A2520

\- Colour palette (Parchment theme): Background \#F5F0E8, Surface \#FDFAF4, Primary text \#1A1612, Gold \#9A7020, Orange \#C4511A, Border \#DDD5C0

\- Colour palette (Silver theme): Background \#F2F2F4, Surface \#FFFFFF, Primary text \#111116, Gold \#B08A2A, Silver accent \#9EA0AA, Orange \#D4520A

\- Ornamental detail: Sparse Byzantine geometric gold ornament at card corners and section dividers only — not on interactive elements

\- Border radius: Cards 10px, buttons 6px, chips 4px, modals 16px top corners

\- Icons: Outlined, 1.5px stroke, Lucide-style — gold fill on active states

\- No drop shadows — elevation via border contrast only

\- Post cards feature: Cormorant Garamond title, author handle, scripture reference chip (gold border), reaction bar with three custom spiritual reactions (Amen, Insightful, Thought-Provoking)

\- Bottom navigation: 4 tabs (Feed, Explore, Compose, Profile) — gold active state

\- The overall feel should be: serious, reverent, unhurried — like opening a beautifully designed theological journal, not a social media app

---

## 9\. What NOT to Design

Instructions for what Stitch should avoid — include these as negative constraints in your prompts.

Avoid:

\- Rounded bubbly UI — this is not a chat or social app aesthetic

\- Bright white backgrounds with blue or purple accents

\- Any gradient that isn't very subtle (near-flat)

\- Drop shadows or card lift effects

\- Playful or rounded iconography

\- Sans-serif headings — all titles must be in Cormorant Garamond

\- Cluttered layouts — every screen must have identifiable breathing room

\- Neon or vibrant accent colors — orange is the only warm accent and it is used sparingly

\- Illustrative or pictorial ornament — geometry only

\- Standard social media patterns (heart reactions, like counts, follower counts visible)

---

*End of Scribes Design Brief v1.0*  
*Pass this document to Google Stitch alongside individual screen prompts.*  
