# Implemented Backend Modules & UI Component Mapping

This document outlines the backend modules that have been fully implemented in the Go API and their corresponding upcoming UI components in the Flutter client.

## 1. Authentication (`/api/auth`)
**Backend Support**: 
- Registration (`POST /register`)
- Login/JWT generation (`POST /login`)
- Current User Profile (`GET /me`)

**Ready to Manifest UI Components**:
- **Auth Screen**: Login and Registration forms with `CustomTextField` and `CustomButton`.
- **Profile Widget**: Displaying username and email in a Drawer or Settings page.

## 2. Notes Engine (`/api/notes`)
**Backend Support**:
- Full CRUD operations linked to the authenticated user.
- Private system of record.

**Ready to Manifest UI Components**:
- **Notes List View**: A scrollable list of private notes.
- **Note Editor**: A rich text or markdown editor component for creating and editing notes.
- **Note Card Modal**: A UI card showing the title and an excerpt of the note body.

## 3. Drafts Staging (`/api/drafts`)
**Backend Support**:
- Full CRUD operations.
- Intermediary stage between private Notes and published Posts.

**Ready to Manifest UI Components**:
- **Drafts Dashboard**: A section showing currently active drafts.
- **Draft Editor**: Similar to the Note Editor but potentially with publishing configuration options (e.g., adding categories or scriptures before publishing).

## 4. Public Posts Feed (`/api/posts`)
**Backend Support**:
- Read-only Public Feed (`GET /posts`).
- Single post retrieval (`GET /posts/{id}`).
- Creation/Updates from Drafts to Posts.

**Ready to Manifest UI Components**:
- **Public Feed Screen**: The main timeline view displaying posts from all users chronologically.
- **Post Card**: A component displaying the Post title, author placeholder, category, and an excerpt.
- **Post Detail View**: Full screen reading mode for a single chosen post.

## 5. Sync Engine (`/api/sync`)
**Backend Support**:
- Pull Deltas (`GET /sync/pull?last_synced_at=...`): Fetches only the records that have changed since the client's last sync.
- Push Mutations (`POST /sync/push`): Accepts offline client edits and resolves conflicts with LWW (Last Write Wins).

**Ready to Manifest UI Components**:
- **Sync Status Indicator**: A small top-bar icon showing whether the app is "Online", "Offline", "Syncing", or "Synced".
- **Manual Sync Button**: A button to force a manual pull/push if desired.
- **Conflict Resolver Dialogue**: (Future scope) UI for handling any complex data conflicts.
