# Scribes Landing Page — Aesthetic Laws
**Version 1.0 · Handover document for code-based model implementation**

> This document governs every visual, typographic, motion, and copy decision on the Scribes landing page. It is not a style guide in the generic sense. It is a set of inviolable laws derived from the Scribes design identity — Byzantine illuminated manuscript aesthetic reframed through a postmodern editorial lens. A code-based model implementing or modifying this page must read this document in full before touching a single line. When in doubt, the law wins over convenience.

---

## 1. The One Sentence That Governs Everything

> **The page must feel like opening the cover of a significant book — not launching an app.**

Every decision flows from this. If a proposed element feels like a SaaS product page, a social media platform, or a tech startup launch — it is wrong for Scribes. Revise it until it feels like a manuscript, a literary journal, or a theological text given digital form.

---

## 2. Colour Laws

### The palette — six values, no others

| Name | Hex | Role |
|---|---|---|
| Ink | `#0C0A08` | Page background — the vellum night |
| Vellum | `#F2EDE4` | Primary text — aged manuscript cream |
| Gold | `#C9A84C` | Primary accent — Byzantine gold leaf |
| Gold Glow | `#E8C97A` | Hover state of gold only |
| Ember | `#D4621A` | Reaction accent, live indicators — used sparingly |
| Muted Ink | `#8A8070` | Secondary text, captions, metadata |

**Law 1 — No colour outside these six.** Not a shade lighter, not a tint darker. If a new element requires a colour not on this list, it is asking the wrong question. Rethink the element, not the palette.

**Law 2 — Gold is not decoration.** Gold appears on: active states, CTA buttons, eyebrow labels, ornamental elements, pull quotes, section dividers. It does not appear on body text, card backgrounds, or anywhere it would become wallpaper. Rarity is what gives it weight.

**Law 3 — Ember is rarer than gold.** Ember (`#D4621A`) is reserved for reaction indicators and live signals only. It does not appear on CTAs, nav elements, or decorative purposes. If you find yourself reaching for ember in a non-reaction context, you are using the wrong colour.

**Law 4 — The background is not black.** It is `#0C0A08` — ink-black with a trace of warm brown. Never use `#000000`. The warmth is intentional — it references the aged quality of manuscript vellum even in the dark theme.

**Law 5 — Opacity for ornament, not for text.** Ornamental elements (grid lines, circle halos, watermark text, divider lines) use opacity to recede. Text never uses opacity — use `var(--muted)` (`#8A8070`) for secondary text instead. Opacity on text creates accessibility failures.

**Law 6 — No gradients on surfaces.** The grid background may use a `linear-gradient` to create the grid pattern itself, but no card, section, or container may have a gradient fill. Surfaces are flat. Depth comes from border contrast, not gradient.

---

## 3. Typography Laws

### The two typefaces — both required, no substitutions

| Role | Face | Source |
|---|---|---|
| Display / headings / pull quotes / post titles / wordmark | Cormorant Garamond | Google Fonts — must be bundled or preconnected |
| Body / UI / labels / captions / navigation / buttons | DM Sans | Google Fonts — must be bundled or preconnected |

**Law 7 — Cormorant Garamond is for meaning. DM Sans is for function.** Every heading, post title, blockquote, ornamental label, and the wordmark itself uses Cormorant Garamond. Every button label, nav item, eyebrow tag, body paragraph, and caption uses DM Sans. There is no third typeface. There are no exceptions.

**Law 8 — Display text is light (weight 300), not bold.** Hero titles, section headings, and pull quotes use `font-weight: 300` in Cormorant Garamond. The heaviness of the manuscript comes from the typeface itself — a 300-weight Cormorant at 72px has more presence than a 700-weight sans at the same size. Only post card titles and the wordmark use 600. Never 700 on display text.

**Law 9 — Italic is used for emotional emphasis, not structural.** Cormorant Garamond italic is used on: the gold-coloured emphasis words in hero titles, pull quotes, the hero subheading, the footer verse. It is not used for de-emphasis or as a generic styling tool. Every italic is a choice.

**Law 10 — Letter spacing on eyebrow labels.** Every uppercase label above a section title (the small all-caps tag lines) uses `letter-spacing: 3px` and `text-transform: uppercase` in DM Sans at `font-size: 10-11px`, `font-weight: 500`, colour `var(--gold)`. This is the visual grammar for "here begins a new section." It is not used on body text, headings, or buttons.

**Law 11 — Line height is generous.** Body text: `line-height: 1.75–1.8`. Display headings: `line-height: 1.05–1.1`. Pull quotes: `line-height: 1.3`. Never compress line height to save space — the spaciousness is the design.

### The type scale

| Token | Size | Face | Weight | Used for |
|---|---|---|---|---|
| `display-xl` | `clamp(52px, 8vw, 96px)` | Cormorant | 300 | Hero title |
| `display-lg` | `clamp(36px, 5vw, 60px)` | Cormorant | 300 | Section titles |
| `display-md` | `clamp(28px, 4.5vw, 52px)` | Cormorant | 300 | Pull quotes, Habakkuk |
| `display-sm` | `22–26px` | Cormorant | 600 | Post card titles, mission headings |
| `body-lg` | `16px` | DM Sans | 300 | Section body text |
| `body-md` | `14–15px` | DM Sans | 300 | Card excerpts, step descriptions |
| `label` | `13–14px` | DM Sans | 400–500 | Buttons, nav, post category tags |
| `eyebrow` | `10–11px` | DM Sans | 500 | Section eyebrows, step numbers |
| `caption` | `12px` | DM Sans | 400 | Post authors, reactions, footer copy |

---

## 4. Layout Laws

**Law 12 — The grid is 60px gutters on desktop, 24px on mobile.** The primary section container is `max-width: 1200px`, centred. Individual sections use `padding: 120px 60px` on desktop and `padding: 80px 24px` on mobile. This is not negotiable — the breathing room is the design.

**Law 13 — No cards with drop shadows.** Elevation is communicated through border contrast only — a `0.5px solid var(--border)` outline where `--border` is `rgba(201,168,76,0.18)`. Drop shadows are a material design convention and they are not part of this visual language. If something needs to feel elevated, it uses a slightly different background (`#131008` surface vs `#0C0A08` background) and a border.

**Law 14 — Border radius is architectural, not stylistic.** Buttons use `border-radius: 3px` — barely rounded, almost square. Cards in grid systems use `border-radius: 0` — they are cells in a structure, not floating objects. The only rounded elements are the ornamental circle halos, which are decorative geometry. Nothing uses `border-radius` above `4px` except bottom sheets (which do not exist on the landing page).

**Law 15 — Section dividers use the ornamental medallion pattern.** Where a visual break is needed mid-page within a section, use the ornamental divider: a `0.5px` horizontal rule with a `linear-gradient(90deg, transparent, var(--gold), transparent)` — flanking a rotated diamond shape (a `div` with `transform: rotate(45deg)`, `border: 0.5px solid var(--gold)`, `opacity: 0.6`). This element appears no more than three times on the entire page.

**Law 16 — Grid systems are 1px-bordered gap structures, not spaced card grids.** The mission grid and post card grid both use `gap: 1px` with a `background: var(--border)` on the grid container, and the individual cells have the page background colour. This creates the appearance of hairline rules between cells rather than visible gaps or spacing. It is a manuscript layout — text in ruled columns — not a card gallery.

**Law 17 — No centred body text.** Pull quotes, hero subheadings, and the Habakkuk section are centred. Section body text (the paragraphs below section titles) is always left-aligned. Centred body paragraphs are a generic design pattern that makes reading harder and signals low intention.

---

## 5. Ornamental Laws

**Law 18 — Ornament recedes, never competes.** Every ornamental element operates at reduced opacity: grid background lines at `rgba(201,168,76,0.025)`, circle halos at `opacity: 0.06` and `opacity: 0.03`, watermark text at `opacity: 0.03`, ornamental divider at `opacity: 0.6`. The moment ornament is visible enough to be the first thing a reader notices, it has failed.

**Law 19 — Ornament is geometric, not figurative.** The cross-diamond shape (rotated square), concentric circles, and hairline rules are the ornamental vocabulary. No flourishes, no script calligraphy, no pictorial illustration, no SVG icons used decoratively. Ornament on this page is architectural geometry only.

**Law 20 — The background grid.** A `60px × 60px` grid of `rgba(201,168,76,0.025)` lines covers the entire page background via `position: fixed`. This is the only full-page decorative element. It is implemented with CSS `background-image: linear-gradient` repeated grid lines — not SVG, not canvas. It is `pointer-events: none` and `z-index: 0`.

**Law 21 — The watermark text pattern.** Large ghosted text behind a section — used in the final CTA section where "Scribes" sits at `font-size: clamp(80px, 15vw, 200px)`, `color: var(--gold)`, `opacity: 0.03`. This pattern is used once on the page. Never more than once. It is `position: absolute`, `user-select: none`, `pointer-events: none`.

**Law 22 — Circle halos are for the vision section only.** Two concentric circles in gold at low opacity sit behind the Habakkuk quote section. This is a direct reference to the radiance and glory imagery in the manuscript tradition. They appear in no other section. They are `position: absolute`, created with `border-radius: 50%`, `border: 0.5px solid var(--gold)`.

---

## 6. Motion Laws

**Law 23 — Motion is restrained and purposeful.** Two animations exist on this page: the ticker scroll and the scroll-reveal on sections. No parallax, no floating elements, no pulsing glows, no animated gradients. If a proposed animation cannot be justified by asking "what does this communicate about the content?" — it does not ship.

**Law 24 — The ticker is the only continuous animation.** The excerpt ticker (`animation: ticker 40s linear infinite`) runs continuously and pauses on hover (`animation-play-state: paused`). The 40-second duration is deliberate — it is slow enough to be read, not so fast as to feel urgent. If the duration is shortened to below 30 seconds, the ticker loses its meditative quality and starts to feel like a news crawler. Do not shorten it.

**Law 25 — Scroll reveal is opacity + vertical translate.** Every section uses `opacity: 0; transform: translateY(24px)` as its initial state, transitioning to `opacity: 1; transform: translateY(0)` over `0.8s ease` when it enters the viewport (IntersectionObserver, threshold `0.12`). The translate distance is `24px` — not `40px` (too dramatic) and not `8px` (imperceptible). Each section reveals once and the observer disconnects.

**Law 26 — Hover states are subtle transitions.** Button hover: background shifts from `var(--gold)` to `var(--glow)` over `0.2s`. Ghost button hover: border-color and text shift to `var(--gold)` over `0.2s`. Card hover: background shifts by one step (`#110E09`). Mission cell hover: a 3px gold left border appears at `opacity: 1` (from `opacity: 0`) over `0.3s`. No scale transforms on hover except the primary button which uses `transform: translateY(-1px)` — a 1px lift only.

**Law 27 — Reduced motion is respected.** The ticker animation and all reveal transitions must be disabled under `@media (prefers-reduced-motion: reduce)`. The ticker becomes a static display. The reveals become immediately visible (no transition). This is a hard requirement, not optional polish.

---

## 7. Copy Laws

**Law 28 — The voice is serious, reverent, and unhurried.** Scribes copy reads like a theological journal, not a product announcement. Short declarative sentences. No exclamation marks, anywhere. No superlatives ("best", "most powerful", "revolutionary"). No feature-speak ("seamlessly", "effortlessly", "intuitively").

**Law 29 — Gold italic words in headings are load-bearing.** In the hero title: *"finds its scribes."* In the section titles: *"a taste of the Word."* / *"to permanent teaching."* These italic gold phrases carry the theological meaning of the heading. They are not decorative italics — they are the thesis. Changing them requires rethinking the section's entire purpose.

**Law 30 — The Habakkuk quote is verbatim and attributed.** The verse reads: *"For the earth will be filled with the knowledge of the glory of the Lord, as the waters cover the sea."* Attribution: Habakkuk 2:14 · ESV. This is the vision of the platform. It does not get paraphrased, shortened, or translated to a different version without explicit product-level approval. The attribution always appears.

**Law 31 — The closing question is the emotional core.** The final CTA heading — *"What has been given to you to say?"* — is the same question that appears in the Compose screen's empty-state placeholder in the app. It is the throughline between the landing page and the product. This copy must not be changed to a generic CTA like "Start writing today" or "Join Scribes." It is specifically this question.

**Law 32 — Ticker excerpts must sound like real believers writing.** The scrolling excerpts must be theologically grounded, literarily considered, and free of cliché. They are not inspirational quotes — they are the kind of thing a serious believer would actually write in a Scribes post. Before replacing any ticker item, read it aloud. If it sounds like a coffee mug, rewrite it.

**Law 33 — Post card excerpts are the platform's proof.** The three sample post cards on the page (Theology, Prayer, Hermeneutics) are the page's strongest argument for what Scribes produces. Their writing must be of the same quality as the ticker — substantive, challenging, the kind of reading that makes a person want to read more. They are not lorem ipsum with a theological skin. If they are ever replaced, the replacements must maintain the same intellectual and spiritual register.

**Law 34 — No second-person sales language.** "You will discover," "You'll be amazed," "Your faith will grow" — none of this. The copy describes what Scribes is and what it carries. The reader draws their own conclusions. The platform trusts its content to make the case.

---

## 8. Structural Laws (Page Sections in Order)

The page must contain these sections in this exact order. Sections may be extended but not removed or reordered without a product decision documented here.

| # | Section | Purpose | Must contain |
|---|---|---|---|
| 1 | Navigation | Wordmark + single CTA | Logo (Cormorant Garamond), "Join the community" CTA, gold button |
| 2 | Hero | Brand thesis | Eyebrow, display title with gold italic, serif subheading, two action buttons |
| 3 | Ticker | Platform proof by doing | Scrolling post excerpts, pause on hover, "From the community" label |
| 4 | Mission | Why Scribes exists | Section eyebrow, title with gold italic, body paragraph, 2×2 mission grid |
| 5 | Habakkuk | The vision | Eyebrow with reference, verbatim verse, attribution, closing interpretive paragraph |
| 6 | How it works | Product explanation | Three steps (Capture / Refine / Publish), content type chips |
| 7 | Post preview | Platform content proof | Three sample post cards with realistic copy |
| 8 | Final CTA | Conversion | "What has been given to you to say?", two buttons (create account / read without account) |
| 9 | Footer | Reference and close | Wordmark, Habakkuk verse, copyright |

---

## 9. What This Page Must Never Contain

These elements are explicitly prohibited. A code-based model must not add any of the following regardless of perceived UX benefit or aesthetic intention.

- Hero section screenshots, app mockups, or device frames
- Pricing tables or pricing mentions of any kind
- Testimonial sections with avatar photos and star ratings
- "As seen in" or press logo strips
- Feature comparison tables
- Animated gradient backgrounds, mesh gradients, or aurora effects
- Neon or vibrant accent colours outside the defined palette
- Drop shadows on any element
- Rounded corners above `4px` on any non-circular element
- Social proof counters ("10,000 believers have joined")
- Auto-playing video or audio of any kind
- Cookie consent banners or pop-up overlays that interrupt reading
- Any element that describes Scribes as a "social media platform," "app," or "tool" — it is a platform and a community
- Emoji anywhere on the page
- Sans-serif headings — all titles are Cormorant Garamond without exception
- Any text that implies Scribes is only for pastors or church leaders — it is for all believers

---

## 10. Responsive Laws

**Law 35 — Mobile breakpoint is 900px.** Below 900px: navigation padding collapses to `24px`, all section padding collapses to `80px 24px`, the mission grid becomes a single column, the how-it-works grid becomes a single column, the post card grid becomes a single column. The ticker remains functional but may have reduced font size at very narrow widths.

**Law 36 — The ticker requires `overflow: hidden` on its container.** At all viewport widths. Without this the infinite loop creates horizontal scroll on mobile. This is a hard requirement.

**Law 37 — Type scales use `clamp()`.** All display-level text uses CSS `clamp()` with a minimum, preferred (viewport-relative), and maximum value. This prevents layout breaks at unexpected viewport sizes without media query fragmentation.

---

## 11. Implementation Notes for the Code Model

- Load Cormorant Garamond and DM Sans via Google Fonts with `<link rel="preconnect">` for both `fonts.googleapis.com` and `fonts.gstatic.com` — this is required for performance, not optional
- The scroll reveal uses `IntersectionObserver` with `threshold: 0.12` — do not use scroll event listeners
- The ticker is pure CSS animation on a `width: max-content` flex container with duplicated items for seamless looping — do not use JavaScript for the ticker motion
- All six colour values should be defined as CSS custom properties on `:root` — never inline hex values in component styles
- The ornamental divider is a pure CSS element — no SVG required
- The grid background is `position: fixed` with `z-index: 0` and `pointer-events: none` — the rest of the page content sits at `position: relative; z-index: 1` or higher
- `backdrop-filter: blur(12px)` on the navigation requires a semi-transparent background (`rgba(12,10,8,0.92)`) to be visible — confirm this renders correctly across target browsers
- The `@media (prefers-reduced-motion: reduce)` block must disable both the ticker animation and the reveal transitions — this is an accessibility requirement, not cosmetic

---

*Scribes Landing Page — Aesthetic Laws v1.0*
*Governs all implementation and modification of the Scribes public landing page.*
*These laws are derived from the Scribes design brief v1.1 and the screen-by-screen design system established across the full product design process.*
*When a law and a convenience conflict, the law wins.*