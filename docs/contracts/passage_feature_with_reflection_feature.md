# Scribes — Compose Entry Point & Post Type Selection Contract
**Version 1.0 · The single source of truth for how a user starts writing Standard, Passage, or Reflection**

> This contract did not exist as a standalone, current document before now. Passage's composer entry point was specified once, inside the original `scribes_media_contracts.md` (pre-billing-removal) — that document is superseded, and its composer section was never re-written into `scribes_media_contracts_v2.md`, which only references the panel builder widget as "unchanged" without actually restating how a user gets there. This document closes that gap, corrects the stale billing-tier upsell language the old spec still carried, and extends the entry point to cover Reflection as the third post type.

---

## 1. Why This Needed Its Own Document

Two real problems, both worth naming plainly rather than quietly fixing:

1. **The only existing spec for how Passage is entered was written before the no-commercial-layer correction.** It described an "upgrade sheet" gating images behind "Scribe Pro and Elder plans" — language that has no meaning anymore, since Scribes has no tiers. If Passage's composer were implemented directly from that old document, it would ship a paywall prompt for a product that has explicitly, permanently, decided never to have one.
2. **Reflection was designed in the previous conversation without a settled compose entry point to attach to** — building its UX around "however Passage already works" would have meant building on top of an assumption, not a verified current spec. This document settles the entry point once, for all three types together, so nothing downstream has to guess again.

---

## 2. The Corrected Model — No Type Selector Tab, No Upgrade Sheet

The old spec's approach — two underlined tab labels ("Writing" / "Passage") at the top of a single Compose screen — technically works for two types, but it has two problems once there are three: it doesn't scale cleanly to three tabs without feeling cramped, and it treats all three types as equally weighted choices in a menu, when they are not equally weighted in practice. Reflection is meant to be the *fast, low-friction* option; burying it as a third tab alongside two much heavier authoring flows undercuts that.

**The corrected entry point: tapping the Compose FAB opens a lightweight type-selection step first, not directly into an editor.**

```
Tap Compose FAB
        │
        ▼
┌─────────────────────────────────────┐
│                                       │
│   What would you like to create?     │  ← Cormorant Garamond, display-sm
│                                       │
│   ┌─────────────────────────────┐   │
│   │  ✒  Reflection                │   │  ← listed first — lowest friction,
│   │  A quick thought, verse,      │   │     most common action, deserves
│   │  or question                  │   │     top position
│   └─────────────────────────────┘   │
│                                       │
│   ┌─────────────────────────────┐   │
│   │  📄  Standard Post             │   │
│   │  Write a full reflection      │   │
│   │  or teaching                  │   │
│   └─────────────────────────────┘   │
│                                       │
│   ┌─────────────────────────────┐   │
│   │  🗂  Passage                   │   │
│   │  Build a structured,          │   │
│   │  multi-panel devotional       │   │
│   └─────────────────────────────┘   │
│                                       │
└─────────────────────────────────────┘
```

This is presented as a bottom sheet (per Scribes' established preference for inline/sheet interactions over full-screen modals where reasonable), styled per the glassmorphic addendum — this is exactly the kind of transient, floating chrome §2 of that addendum classifies as glass, not paper: gold edge, frosted blur against whatever screen is behind it.

Tapping any option navigates directly into that type's dedicated composer — no further tab-switching once inside. If a user picked wrong, they back out of the sheet-launched composer and reopen the FAB to pick again, rather than switching type mid-flow. This keeps each composer's state simple: it only ever needs to know how to build one type of post, never how to convert between them.

---

## 3. The Three Composers, Each Fully Separate

```
lib/features/compose/presentation/
├── compose_type_sheet.dart       — the selection sheet in §2
├── standard_composer.dart         — full Quill editor + cover image picker
├── passage_composer.dart          — panel builder (was PassagePanelBuilder, now its own screen)
└── reflection_composer.dart       — lightweight single-block composer
```

### Standard Composer

Unchanged from what already exists conceptually — full rich-text editor (Quill/Delta), cover image picker, scripture attach action. No tab selector needed inside this screen anymore, since type was already chosen at the sheet.

### Passage Composer

This is where the corrected, de-billing'd version of the old spec lands:

```dart
class PassageComposerScreen extends StatelessWidget {
  // Vertical list of panel cards — same structure as the original PassagePanelBuilder:
  //   Each panel: type selector (text/image/scripture) + content area + drag handle + delete
  //   "Add panel" button, disabled at 12 panels ("Maximum 12 panels reached")
  //   Sound selector at the bottom — SoundPickerSheet, 5 category filter chips,
  //     preview via just_audio, "No sound" always available at top
}
```

**What's explicitly removed from the old spec:** the "Images bring your teaching to life... available on Scribe Pro and Elder plans" upgrade sheet. Per `scribes_media_contracts_v2.md`, image and sound attachment is available to every user identically, gated only by the universal fair-use monthly allowance — never by a tier. If a user hits their monthly allowance while building a Passage panel, they see the **allowance notice** already specified in that document (§ "Revised Flutter Upgrade Sheet → Allowance Notice"), not the old upsell copy:

```
"You've reached this month's limit."
"You've used all 60 panel images available this month. Your allowance resets on {date}."
[ Got it ]
"This limit exists to keep Scribes sustainable for everyone — not a paywall."
```

This is the one substantive correction this document makes to existing behavior, not just new specification — anyone who had already begun implementing Passage's composer from the old file needs this swapped in.

### Reflection Composer

As specified in `scribes_reflection_post_type_contract.md` §7 — compact single-block Quill input, live character counter approaching 500, scripture-attach action reusing the same picker as Standard, single inline image picker (populating `reflection_image_url`, never `cover_image_url`), and the upfront immutability notice before publish.

---

## 4. Why Reflection Is Listed First in the Selection Sheet

This is a deliberate product decision, not an alphabetical accident: **Reflection should be the path of least resistance.** A platform that wants people to actually publish — not just draft and abandon — benefits from making the lightest option the most visible one. Standard and Passage remain fully available and equally functional; they're just not first in line, because they ask more of the author before anything gets published.

If usage data later shows this ordering doesn't match how people actually use the app, this is a one-line reorder in `compose_type_sheet.dart` — worth flagging as an assumption to revisit post-launch, not a permanent judgment.

---

## 5. Non-Negotiables

1. **No post-type upgrade sheet or paywall language anywhere in any composer, ever.** Per the platform-wide no-commercial-layer rule — this document exists partly to correct a violation of that rule that was already written into an old spec file.
2. **Type is chosen once, at the entry sheet, before any composer opens.** No mid-composition type-switching — each composer only ever builds one type.
3. **The FAB itself remains exactly as specified in `scribes_design_brief.md`** — octagonal, gold, black quill icon, bottom-right, raised, now additionally carrying the soft gold glow from the glassmorphic addendum. This document changes what happens *after* the tap, not the FAB's own appearance.

---

## 6. Done Criteria

- [ ] Tapping the Compose FAB opens the type-selection sheet, not directly into an editor
- [ ] Sheet lists Reflection first, then Standard, then Passage
- [ ] Sheet is styled as glass per the glassmorphic addendum — gold edge, frosted blur against the screen behind it
- [ ] Each of the three options navigates to its own dedicated, fully separate composer screen
- [ ] Passage composer's panel builder shows the **allowance notice** (not an upgrade/paywall sheet) when the monthly image or sound allowance is reached — confirmed by direct testing, not just code review, since this is the exact class of stale-spec bug this document was written to catch
- [ ] No composer screen contains any reference to "plans," "tiers," "Scribe Pro," or "Elder" anywhere in code or copy

---

## 7. What This Document Supersedes

`scribes_media_contracts.md` (the original, pre-billing-removal version) — specifically its "Passage composer" section — is now fully superseded for entry-point and composer-structure purposes by this document. That file should be treated as historical record only, per the existing versioning convention already established in `scribes_onboarding.md`. `scribes_media_contracts_v2.md` remains the correct source for Passage's underlying data model, immutability rules, and fair-use allowance mechanics — this document only replaces its composer/entry-point description, which v2 had left unwritten.

---

*Scribes Compose Entry Point & Post Type Selection Contract v1.0*
*One FAB, one selection step, three fully separate composers, zero paywalls*