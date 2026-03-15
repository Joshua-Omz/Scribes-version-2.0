# Scribes — Software Requirements Specification (SRS)

> **Version**: 1.0 — Draft  
> **Project**: Scribes (Local-First Note-Taking & Publishing App)

---

## 1. Introduction

### 1.1 Purpose
This document defines the functional and non-functional requirements for the Scribes MVP application, comprising a Go REST API backend and a Flutter mobile/web client.

### 1.2 Scope
Scribes is a local-first collaborative note-taking and publishing platform. Users can write and organize private notes offline, publish curated drafts as public posts, and synchronise their data with a central Go backend.

### 1.3 Definitions
| Term | Definition |
|------|-----------|
| Note | A private, user-owned writing item stored locally first. |
| Draft | An extracted excerpt from a note, used as a staging area before publishing. |
| Post | A publicly visible item created from a draft. |
| Sync | The delta-based push/pull mechanism keeping client and server in sync. |
| LWW | Last-Write-Wins — conflict resolution strategy for the sync engine. |

---

## 2. Overall Description

### 2.1 Product Perspective
Scribes is a greenfield monorepo application. The backend is a Go modular monolith; the client is a Flutter app targeting Android, iOS, and Web.

### 2.2 User Classes
- **Authenticated User** — can create, edit, delete notes, drafts and posts; can sync.
- **Anonymous User** — can browse the public post feed (read-only).

---

## 3. Functional Requirements

### 3.1 Authentication
- FR-AUTH-01: Users shall register with a unique username, email, and password.
- FR-AUTH-02: Passwords shall be hashed with Argon2id before storage.
- FR-AUTH-03: Successful login shall return a signed HS256 JWT with a 72-hour TTL.
- FR-AUTH-04: Protected endpoints shall reject requests without a valid JWT.

### 3.2 Notes
- FR-NOTE-01: Authenticated users shall perform full CRUD on their own notes.
- FR-NOTE-02: Notes shall support soft-deletion via a `deleted_at` timestamp.

### 3.3 Drafts
- FR-DRAFT-01: Authenticated users shall perform full CRUD on their own drafts.
- FR-DRAFT-02: Drafts shall support soft-deletion via a `deleted_at` timestamp.

### 3.4 Posts
- FR-POST-01: Authenticated users shall create, update, and delete their own posts.
- FR-POST-02: All users (including anonymous) shall retrieve the public post feed.

### 3.5 Sync Engine
- FR-SYNC-01: `GET /api/sync/pull?last_synced_at=<RFC3339>` shall return all records modified after the given timestamp.
- FR-SYNC-02: `POST /api/sync/push` shall accept client mutations and apply them using LWW conflict resolution.

---

## 4. Non-Functional Requirements

| ID | Requirement |
|----|------------|
| NFR-01 | API response time < 300 ms at p95 under normal load. |
| NFR-02 | All passwords stored using Argon2id (never plaintext). |
| NFR-03 | JWT secrets shall never be committed to source control. |
| NFR-04 | The Flutter client shall function fully offline and sync when connectivity is restored. |
| NFR-05 | Docker image shall be built from a multi-stage `scratch` base for minimal attack surface. |
