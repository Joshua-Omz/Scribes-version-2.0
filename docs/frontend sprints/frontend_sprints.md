# Scribes — Frontend Sprint Plan
**Version 1.0 · Flutter Client · Built from plan documents, not verified implementation**

> Read `scribes_frontend_guide.md` first — it has the full assumption list, tech stack, and folder architecture this plan depends on. This document assumes those decisions are settled. Where a sprint depends on a backend endpoint flagged as unverified in the guide, that sprint's done-criteria include an explicit "confirm this endpoint exists and matches" step before building the UI around it.

---

## Ground rules

1. One sprint at a time, same discipline as the backend build.
2. Every sprint ends with the app running on at least one platform (web or a simulator) with the sprint's screens visibly working — not just compiling.
3. Shared design-system widgets (§7 of the guide) are built in Sprint 1, before any screen — this is non-negotiable, every later sprint depends on them existing.
4. Where an endpoint's real shape is unconfirmed, the sprint's first task is confirming it — not guessing and hoping.
5. State management follows the guide's pattern exactly: `AsyncNotifier` + repository, no exceptions invented mid-sprint.

---

## Sprint overview

| # | Sprint | Screens covered | Depends on backend sprint |
|---|---|---|---|
| 1 | Foundation, theming & auth | Splash, Auth Gate | Backend S1 |
| 2 | Onboarding & shared widgets | Onboarding — Topics | Backend S1 (+ verify onboarding endpoint) |
| 3 | Feed & Explore | Primary Feed, Explore | Backend S6 |
| 4 | Post Detail (public + authenticated) | Post Detail | Backend S2, S3, S5 |
| 5 | Compose & Notes | Compose, Notes | Backend S2 |
| 6 | Offline sync integration | (no new screen — wires sync into S2/S5 screens) | Backend S4 |
| 7 | Profile & Notifications | Profile (own + public), Notifications | Backend S8, S9 |
| 8 | Messaging | Direct Messages (inbox + conversation) | Backend S7 |
| 9 | Settings & release hardening | Settings, app-wide polish | Backend S9 |

---

## Sprint 1 — Foundation, Theming & Auth

### What this sprint delivers
A running Flutter app (web + mobile target) with the three-theme system wired end to end, the shared design-system widget library started, and working registration/login against the real backend.

### Screens
- Splash / Brand Entry
- Auth Gate (Register / Login toggle)

### Tasks
- Scaffold the folder architecture from the guide §5
- Implement `ScribesColors`, `ScribesTextStyles`, `ScribesRadius` exactly as specified in guide §4
- Bundle Cormorant Garamond and DM Sans as local fonts — not CDN-loaded
- Build `core/network/api_client.dart` with a `dio` instance and JWT interceptor
- Build `core/network/api_exception.dart` — **first confirm the real error response shape from the backend**, then normalise around it
- Implement `AuthApi` (`data/`) and `AuthRepository` (`domain/` mapping) for `/auth/register` and `/auth/login`
- **Confirm the real register/login response shape** — the guide assumes `{"token": "...", "user": {...}}`; verify before writing the parsing code
- Implement `AuthNotifier` — holds current auth state (unauthenticated / authenticated with User)
- Build the Splash screen exactly per the Stitch prompt — wordmark, ornament flanks, tagline, ghost CTA
- Build the Auth Gate screen — tab switcher, register/login fields, validation, error display
- Implement secure JWT storage (`flutter_secure_storage`) and app-launch check (has token → skip to feed; no token → splash)
- Theme switching mechanism (Riverpod provider) — even though Settings isn't built yet, the provider must exist so later screens can read `ref.watch(themeProvider)`

### Done criteria
- [ ] App launches to Splash on cold start with no stored token
- [ ] Register with valid input creates an account against the real backend and lands on the next screen
- [ ] Register with a duplicate email shows the real 409 error message from the backend, not a generic fallback
- [ ] Login with correct credentials succeeds; wrong password shows a generic "invalid credentials" message matching the backend's intentional non-specific error
- [ ] JWT persists across app restart — relaunching with a valid stored token skips Splash/Auth Gate
- [ ] All three themes render correctly when manually toggled via a temporary debug switch (Settings screen doesn't exist yet)
- [ ] Cormorant Garamond and DM Sans render correctly on both web and at least one mobile target
- [ ] `ApiException` correctly parses whatever the real backend's error shape actually is — confirmed by triggering a real 400 and a real 409

---

## Sprint 2 — Onboarding & Shared Widget Library

### What this sprint delivers
The cold-start topic selection screen, and the full shared design-system widget library that every subsequent sprint depends on.

### Screens
- Onboarding — Topic Selection

### Tasks
- **First: confirm whether a dedicated onboarding-categories endpoint exists on the backend, or whether this data is submitted differently (e.g. as part of registration, or via a generic user-preferences endpoint not in the original 43-endpoint list).** This gap was flagged explicitly in the guide — resolve it before building the screen's data layer.
- Build the topic chip grid UI per the Stitch prompt — minimum 3 selection, gold selected state, disabled CTA until threshold met
- Build `ScribesOrnamentDivider` (shared widget)
- Build `ScribesPostCard` (shared widget) — even though Feed isn't built yet, build and unit-test this in isolation with mock data
- Build `ScribesReactionBar` (shared widget) — same approach, mock data
- Build `ScribesScriptureChip` (shared widget)
- Build `ScribesEmptyState` (shared widget)
- Build `ScribesAutoSaveDot` (shared widget)
- Build `ScribesBottomNav` (shared widget) — 4 tabs, wire to `go_router` navigation
- Build `ScribesUnauthBanner` (shared widget) — fixed positioning, doesn't block scroll

### Done criteria
- [ ] Onboarding screen correctly blocks submission below 3 selections and enables above
- [ ] Selected topics are persisted to the backend via whichever endpoint was confirmed to exist
- [ ] Every shared widget from guide §7 exists, is used with mock/placeholder data in a temporary test harness screen, and visually matches its Stitch prompt spec
- [ ] `ScribesBottomNav` correctly navigates between 4 placeholder route stubs
- [ ] No screen built in this sprint or later re-implements a widget that already exists in `core/widgets/`

---

## Sprint 3 — Feed & Explore

### What this sprint delivers
The two primary discovery surfaces — Following feed and Explore — both reading from the real backend, with correct public/protected access handling.

### Screens
- Primary Feed — Following
- Explore — Public Discovery

### Tasks
- Implement `FeedApi` / `FeedRepository` for `GET /feed`
- Implement `ExploreApi` for `GET /explore` and `GET /categories` — **confirm these truly require zero Authorization header**, test with no token present
- Build keyset pagination client-side — **confirm the real cursor format** (opaque string vs raw timestamp+id) before building the "load more" logic
- Wire `ScribesPostCard` with real data — standard cards on Feed, featured card (symmetrical ornament) on Explore's top post
- Build the category filter chip row on Explore — reads from `GET /categories`
- Build empty states for both screens per the Stitch copy — cold-start Feed empty state, no-results Explore empty state
- Implement cold-start detection: if `GET /feed` returns empty specifically because the user has no follows (not just no posts), redirect messaging matches the Stitch spec ("Your scroll is empty" → "Go to Explore")

### Done criteria
- [ ] Feed shows posts only from followed authors, reverse-chronological
- [ ] Explore loads and renders with zero Authorization header — confirmed by testing in a logged-out state
- [ ] Pagination loads a genuinely different second page with no duplicate posts
- [ ] Category filter on Explore correctly narrows results
- [ ] Featured post card on Explore renders with the symmetrical corner ornament; standard cards do not
- [ ] Empty states match the exact copy specified in the original Stitch prompts

---

## Sprint 4 — Post Detail

### What this sprint delivers
The single most important screen in the app — full public accessibility, reactions, comments, version history, and the outward-facing unauthenticated banner.

### Screens
- Post Detail — Published Artifact

### Tasks
- Implement `PostApi` / `PostRepository` for `GET /posts/:id`, `GET /posts/:id/versions`
- **Confirm the real shape of the `content` JSONB field** — this determines how the rich text renderer parses it. This is the highest-risk unverified assumption in the whole frontend build; do not guess.
- Build the rich text renderer for post body — bold, italic, headings, blockquotes, matching the styling spec (gold-bordered blockquotes for scripture)
- Wire `ScribesScriptureChip` with real data — inline expansion, not modal
- Implement reaction submission (`POST /posts/:id/react`) — **confirm whether the public/author reaction response asymmetry is real** (two different response shapes) or whether it's one shape with a conditional field; build the parsing accordingly
- Implement comment list and submission (`GET /posts/:id/comments`, `POST /posts/:id/comments`)
- Build `@mention` detection in the comment input — visual highlight only in this sprint, tap-to-profile can wait for Sprint 7
- Build the Version History bottom sheet using `GET /posts/:id/versions`
- Build the Correction Post notice banner — conditionally rendered if the post has a linked correction
- Wire `ScribesUnauthBanner` for the fully unauthenticated visitor state — confirm the entire screen renders and functions (except reacting/commenting) with zero token
- Implement the soft-gate bottom sheet ("Join Scribes to respond") for unauthenticated reaction/comment attempts

### Done criteria
- [ ] A logged-out visitor can open a post via direct URL/deep link and read the full content with zero friction
- [ ] Reacting while logged out triggers the soft-gate sheet, not a silent failure or a hard redirect
- [ ] Reacting while logged in updates the reaction bar (via refetch, per the guide's v1 pattern)
- [ ] Scripture chips expand inline without navigating away from the post
- [ ] Version History sheet shows real prior versions when a post has been revised
- [ ] Correction notice only appears on posts that actually have a linked correction
- [ ] Rich text renders correctly for at least: bold, italic, one heading level, one blockquote — confirmed against a real post's real content field

---

## Sprint 5 — Compose & Notes

### What this sprint delivers
The full authoring pipeline — Notes as a private capture space, and Compose as the path to publishing, exactly as designed with the "reception vessel" framing intact.

### Screens
- Notes — Private Workspace (list + individual note)
- Compose — New Post Draft (Write + Preview tabs)

### Tasks
- Implement `NoteApi` / `NoteRepository` for full Notes CRUD
- Build the Notes list screen — notebook filter row, source-type indicators (sermon/study/received/personal), empty state with the exact "Nothing written yet" copy
- Build the individual Note screen — plain text only, no rich formatting toolbar, source tag display
- Implement "Promote to Draft" flow — confirmation sheet copy exact match to Stitch spec
- Implement `DraftApi` / `DraftRepository` for draft CRUD and publish
- Build Compose screen — Write/Preview tabs, title field, ornamental divider, rich text body editor
- Build the floating formatting toolbar (appears on text selection only)
- Build the collapsible metadata panel (scripture, category, caption, sermon source) — inline expansion, not modal
- Implement publish validation (title + body + category required) and the publish confirmation bottom sheet with the exact "cannot be erased" copy
- Wire the autosave mechanism — 3-second debounce, `ScribesAutoSaveDot` reflecting real save state (local Drift write, not yet server-confirmed = grey/local; confirmed = gold)

### Done criteria
- [ ] Creating a Note with no title and no source tag succeeds — these are genuinely optional
- [ ] Promoting a Note to a Draft preserves content exactly, opens the new Draft
- [ ] Publishing a Draft creates a real Post on the backend and the Draft is removed
- [ ] The publish confirmation sheet blocks accidental publishing — "Not yet" returns to editing with content intact
- [ ] Autosave dot correctly reflects three states across an intentional airplane-mode test (local save, offline indicator, then reconnect-and-confirm)
- [ ] Compose's Preview tab renders identically to how the real Post Detail screen renders the same content

---

## Sprint 6 — Offline Sync Integration

### What this sprint delivers
No new screens. This sprint wires the sync protocol (guide §9) into the Notes and Draft flows built in Sprint 5, making them genuinely offline-capable.

### Tasks
- Implement the Drift schema for `notes`, `drafts` with `serverSequence` and `localOnly` columns
- Implement `SyncService` — the single file that owns the entire sync flow
- Wire `connectivity_plus` to detect reconnection and trigger `GET /sync?seq=N`
- **Confirm the real response field name for the max-sequence checkpoint** before hardcoding `max_sequence` — the guide flags this as unverified
- Implement the push flow — local-only records batched to `POST /sync/push`
- Retrofit Notes and Draft repositories to write through Drift first, then sync — rather than calling the API directly on every save
- Handle the conflict case (last-write-wins) gracefully in the UI — if a sync resolves a conflict, the user should not lose data silently; at minimum, log it, ideally surface a subtle notice

### Done criteria
- [ ] Creating a Note in airplane mode succeeds and is visible in the Notes list immediately
- [ ] Reconnecting triggers a sync that pushes the offline-created Note to the backend without user action
- [ ] The Note's `localOnly` flag correctly flips to false after a confirmed sync
- [ ] Two devices (or two app instances) can create content offline and both sync correctly without one silently overwriting the other's unrelated content
- [ ] The sync flow is entirely contained in `SyncService` — no feature's repository contains sync logic directly

---

## Sprint 7 — Profile & Notifications

### What this sprint delivers
Both profile states (own + public), and the calm, non-anxious notification centre.

### Screens
- Profile (private state + public state)
- Notifications

### Tasks
- Implement `ProfileApi` / `ProfileRepository` for `GET /users/:handle`
- **Confirm whether a profile-edit endpoint exists** — the guide flags this as unconfirmed against the 43-endpoint list. Resolve before building the "Edit profile" inline panel.
- Build the shared profile screen with two render states (own vs. visiting) — identity block, no follower counts anywhere, ornamental divider before the post feed
- Implement the Follow button with the soft-gate sheet for logged-out visitors (reuse the Sprint 4 pattern)
- Build the private-state stats row and quick access row (Drafts/Bookmarks/Imports/Notes) — these counts come from local Drift queries where possible (draft/note counts), not new backend calls
- Build the orphaned-account state — anonymised display when visiting a deleted user's profile
- Implement `NotificationApi` for `GET /notifications`
- Build the Notifications screen — grouped by time, real-time vs batched visual distinction (left border accent), intelligent grouping ("Sarah and 4 others reacted")
- Wire the notification bell badge (gold dot) on the Feed header

### Done criteria
- [ ] Visiting your own profile shows private-state elements (stats, quick access, edit); visiting another user's shows public-state elements (follow button)
- [ ] No screen, in any state, displays a follower or following count — grep the built UI code to confirm no such widget exists
- [ ] Visiting a deleted user's profile shows the anonymised state with their posts still visible
- [ ] Notifications list correctly distinguishes real-time-origin items (left border) from batched items visually
- [ ] Grouped notifications render as a single row, not N separate rows, when multiple users react to the same post

---

## Sprint 8 — Messaging

### What this sprint delivers
The full mutual-only, request-gated DM system — inbox, requests, conversation thread.

### Screens
- Direct Messages — Inbox
- Direct Messages — Requests (expanded view)
- Direct Messages — Conversation

### Tasks
- Implement `MessageApi` / `MessageRepository` for the full message endpoint set
- Build the Inbox screen — conversation list, requests banner (conditionally rendered)
- Build the Requests expanded view — accept/decline actions
- Build the Conversation screen — bordered text rows (not chat bubbles), grouped consecutive messages, sparse timestamps
- Implement the input bar — text-only, no attachment affordances by design
- Implement block flow and the "This conversation has ended" state — confirm the UI never reveals which party blocked
- Implement soft-delete for own messages — "[Message deleted]" replacement, row position preserved

### Done criteria
- [ ] A message request to a non-mutual follow correctly creates a pending request, not a direct message
- [ ] Mutual followers can message directly with no request step
- [ ] Blocking a conversation from either side shows the same generic "ended" state to both parties
- [ ] Deleting your own message replaces its body but does not shift surrounding messages' positions
- [ ] No typing indicators, no read receipts anywhere in this feature — confirmed absent, not just unused

---

## Sprint 9 — Settings & Release Hardening

### What this sprint delivers
The administrative home screen, live theme switching wired for real, and the cross-cutting polish pass before this is a shippable v1.

### Screens
- Settings

### Tasks
- Build the Settings screen exactly per the Stitch spec — appearance, notifications, privacy, account, data/export, about, account actions
- Wire the theme selector to the real `themeProvider` built in Sprint 1 — confirm live switching works across every screen built so far, not just newly built ones
- Implement notification preference toggles — **confirm whether the backend has a preferences endpoint**; if not, this may need to be a Sprint 9 backend addition or a client-only setting in v1
- Implement the Delete Account flow — confirmation sheet with the exact "type DELETE to confirm" pattern, calling `DELETE /account`
- Implement Export — `GET /posts/:id/export?format=md|txt`, triggering a real file download on web and a share sheet on mobile
- Cross-cutting pass: confirm every screen built in Sprints 1–8 respects the currently selected theme correctly, confirm every empty state matches its specified copy, confirm no screen anywhere shows a follower/following count
- Performance pass: confirm feed/explore scrolling performance is acceptable with realistic data volumes (test against seeded backend data, not 3 mock posts)
- Accessibility pass: minimum tap target sizes, text scaling doesn't break layouts, sufficient contrast in all three themes

### Done criteria
- [ ] Theme switching in Settings instantly updates every previously-visited screen without requiring app restart
- [ ] Delete Account correctly requires exact "DELETE" text match before enabling the destructive action
- [ ] Export downloads a real file with correct content on at least web; mobile share sheet at minimum opens correctly
- [ ] Full cross-app grep/review confirms zero follower-count displays, zero view-count displays, zero read-time displays anywhere in the UI
- [ ] App has been manually walked through end-to-end at least once per theme: register → onboard → publish → react → comment → message → settings → delete account (on a disposable test account)

---

## What this plan deliberately does not cover

- **Automated widget/integration testing** — not scoped here. Worth adding once the UI is stable, but v1 velocity favours manual verification against the done-criteria checklists.
- **Localization** — folder is reserved in the architecture but no work is planned in these 9 sprints.
- **Push notification infrastructure** (APNs/FCM wiring) — the Notifications screen in Sprint 7 covers in-app notification display via polling/refetch; true push delivery is a separate, later scope decision.
- **App store submission process** — build hardening, yes; submission logistics, no.

---

*Scribes Frontend Sprint Plan v1.0*
*9 sprints · built from plan documents · every unverified assumption flagged explicitly at its point of use*
*Read alongside: scribes_frontend_guide.md*