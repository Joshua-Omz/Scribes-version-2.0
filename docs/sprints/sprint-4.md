# Sprint 4 — The Publishing Pipeline & Feeds

**Phase**: 2 (Local-First Client)  
**Week**: 8  
**Status**: 🔲 Pending

---

## Goal

Build the core product transformation: the pipeline from a private Note → Draft → published Post, and the public chronological feeds.

---

## Deliverables

| Task | Status | Notes |
|---|---|---|
| Note → Draft extraction UI | 🔲 | "Extract to Draft" action on Note detail screen |
| Draft editing screen | 🔲 | Full rich-text editor pre-filled from Note |
| Publish screen | 🔲 | Final review before posting |
| Category picker | 🔲 | Dropdown/chips; maps to `posts.category` |
| Scripture tag input | 🔲 | Free-text; maps to `posts.scripture` |
| Primary feed (chronological) | 🔲 | `GET /api/posts` → `ORDER BY created_at DESC` |
| Explore feed (by category) | 🔲 | `GET /api/posts?category=<name>` |

---

## Publishing Flow

```
Note (private, Drift)
  │  "Extract to Draft"
  ▼
Draft (private, Drift + server)
  │  "Publish"
  ▼
Post (public, server)
  │
  ▼
Feeds (Primary / Explore)
```

---

## UI Screens

| Screen | Route | Notes |
|---|---|---|
| Workspace (Notes list) | `/workspace` | |
| Note detail / editor | `/workspace/notes/:id` | |
| Draft queue | `/drafts` | |
| Draft editor | `/drafts/:id` | |
| Publish screen | `/publish` | |
| Primary feed | `/feed` | |
| Explore feed | `/explore` | |
