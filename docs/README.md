# Scribes Documentation Hub

Welcome to the central documentation index for **Scribes**. This repository contains all system specifications, architectural designs, API contracts, engineering guides, UI/UX designs, and sprint plans.

---

## Directory Overview

```
docs/
├── specs/               # High-level product specifications, requirements (SRS), and design (SDD)
├── architecture/        # Subsystem architecture, feature engineering, and interactive HTML diagrams
├── source-of-truth/     # Canonical rules and backend/frontend source-of-truth documents
├── contracts/           # Exhaustive API and feature technical specifications
├── bible/               # Bible feature subsystem specs and implementation handoffs
├── guides/              # Conceptual deep-dives and "How It Works" implementation guides
├── sprints/             # Sprint roadmaps, tracking, and database migration plans
├── fixes/               # Post-mortems, audit reports, and deviation patches
└── ui/                  # UI design brief, elevation guides, and Stitch screen prototypes
```

---

## 1. Specifications (`docs/specs/`)
* [scribes_srs.md](file:///docs/specs/scribes_srs.md) — Software Requirements Specification (Markdown).
* [Scribes_SRS_v2.pdf](file:///docs/specs/Scribes_SRS_v2.pdf) — Formal SRS v2 Document (PDF).
* [scribes_sdd.md](file:///docs/specs/scribes_sdd.md) — Software Design Document.
* [scribes_roadmap.md](file:///docs/specs/scribes_roadmap.md) — Overall project roadmap & sprint tracking.

---

## 2. Architecture & Diagrams (`docs/architecture/`)
* [feature_engineering_inline_scripture.md](file:///docs/architecture/feature_engineering_inline_scripture.md) — Inline scripture expansion architecture and client/server interactions.
* **Interactive Visual Diagrams:**
  * [scribes_architecture.html](file:///docs/architecture/diagrams/scribes_architecture.html) — Interactive system component architecture diagram.
  * [scribes_class_diagram.html](file:///docs/architecture/diagrams/scribes_class_diagram.html) — Interactive domain model and class relationship diagram.
  * [scribes_module_interactions.html](file:///docs/architecture/diagrams/scribes_module_interactions.html) — Module interaction and data flow diagrams.

---

## 3. Source of Truth (`docs/source-of-truth/`)
* [backend_source_of_truth.md](file:///docs/source-of-truth/backend_source_of_truth.md) — Canonical reference for backend invariants, core principles, database schema, and endpoint inventory.
* [onboarding.md](file:///docs/source-of-truth/onboarding.md) — System onboarding guidelines and engineering principles.

---

## 4. API & Technical Contracts (`docs/contracts/`)
* [bible_drawer_contract.md](file:///docs/contracts/bible_drawer_contract.md) — Bible Drawer API, offline schema, and widget contract.
* [comment_contract.md](file:///docs/contracts/comment_contract.md) — Commenting subsystem, nesting, and engagement contracts.
* [export_contract.md](file:///docs/contracts/export_contract.md) — Post document export (PDF, Markdown, Plaintext) contracts.
* [notification_contract.md](file:///docs/contracts/notification_contract.md) — Real-time notification, SSE stream, and inbox contracts.
* [r2_storage_contract.md](file:///docs/contracts/r2_storage_contract.md) — Cloudflare R2 media upload and storage integration contracts.
* [search_recommendations_contract.md](file:///docs/contracts/search_recommendations_contract.md) — Vector embeddings, hybrid search (RRF), and recommendation engine contracts.

---

## 5. Bible Subsystem (`docs/bible/`)
* [hybrid_bible_architecture.md](file:///docs/bible/hybrid_bible_architecture.md) — Hybrid BSB architecture (bundled SQLite offline default + server search/sync).
* [bible_implementation_handoff.md](file:///docs/bible/bible_implementation_handoff.md) — Bible feature execution checklist and validation steps.

---

## 6. Engineering Guides & Deep Dives (`docs/guides/`)
* [how_export_works.md](file:///docs/guides/how_export_works.md) — Deep dive into PDF generation, canvas watermarking, and font embedding.
* [how_images_work.md](file:///docs/guides/how_images_work.md) — Image caching, decoding, pre-rasterization, and memory management.
* [how_search_and_recommendations_work.md](file:///docs/guides/how_search_and_recommendations_work.md) — Conceptual foundations: semantic search, RRF rank fusion, and engagement velocity.

---

## 7. Sprint Plans & Migrations (`docs/sprints/`)
* [frontend_sprints.md](file:///docs/sprints/frontend_sprints.md) — Frontend sprint breakdown and execution phases.
* [migrations_in_sprints.md](file:///docs/sprints/migrations_in_sprints.md) — Database migration inventory and sprint allocations.

---

## 8. Audit Reports & Fixes (`docs/fixes/`)
* [architecture_bug_fix.md](file:///docs/fixes/architecture_bug_fix.md) — Architectural patch and fix documentation.
* [response_upon_reexamination.md](file:///docs/fixes/response_upon_reexamination.md) — Analysis and corrective actions from code re-examinations.
* [urgent_patch_from_deviation.md](file:///docs/fixes/urgent_patch_from_deviation.md) — Root cause analysis and resolution for implementation deviations.

---

## 9. UI / UX Design & Prototypes (`docs/ui/`)
* [scribes_design_brief.md](file:///docs/ui/scribes_design_brief.md) — Typography, palette tokens (Night, Parchment, Silver), and aesthetic foundations.
* [ui_elevation.md](file:///docs/ui/ui_elevation.md) — Premium UI elevation guidelines (micro-animations, glassmorphism, custom toasts).
* [stitch_scribes_sacred_knowledge_platform/](file:///docs/ui/stitch_scribes_sacred_knowledge_platform/) — HTML / PNG visual mockups and interactive Stitch prototype assets.
