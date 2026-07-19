Comments & Interactions: API Contract and Schema

1. Database Schema (PostgreSQL)

The authoritative schema for comments, ensuring author moderation (is_hidden) and notification triggers (mentions) are preserved.

CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    author_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    mentions UUID[] DEFAULT '{}', -- Populated by backend parsing @handles for notifications
    is_hidden BOOLEAN DEFAULT FALSE, -- Post author moderation toggle
    is_deleted BOOLEAN DEFAULT FALSE, -- Soft-delete toggle
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_comments_post_id ON comments(post_id);


2. REST API Endpoints (No Versioning Prefix)

Create a Comment

Route: POST /posts/{post_id}/comments

Auth: Required (JWT)

Request Body:

{
  "content": "This is a profound insight on grace. @joshua"
}


Backend Behavior: The Go handler intercepts the content, extracts any @handles, resolves them to UUIDs, saves them to the mentions array, and fires an event to the notification worker.

Fetch Comments (Flat List)

Route: GET /posts/{post_id}/comments

Auth: Optional

Response Body: Array sorted chronologically.

[
  {
    "id": "c1a2b3c4...",
    "author_id": "u9x8y7z6...",
    "content": "This is a profound insight on grace. @joshua",
    "mentions": ["j1k2l3m4..."],
    "is_hidden": false,
    "is_deleted": false,
    "created_at": "2026-07-18T21:00:00Z"
  }
]


Hide a Comment (Author Moderation)

Route: PATCH /comments/{id}/hide

Auth: Required (Must be the author of the parent Post)

Request Body: None (Toggles is_hidden to true)

Backend Behavior: Only hides the comment from the public UI. The data remains intact.

Delete a Comment (Soft Delete)

Route: DELETE /comments/{id}

Auth: Required (Must be the author of the Comment)

Backend Behavior: Updates is_deleted = true. Replaces content string with standard tombstone: "[This comment has been deleted]". Empties the mentions array to prevent orphaned notifications.

3. Client-Side DM Integration (Contextual Reply)

To facilitate sending a Direct Message contextually from a comment without violating domain boundaries, the Flutter client will construct the context directly within the message body.

Trigger: User taps "Reply via DM" on a comment.

Client Action: Flutter auto-fills the DM composer with quoted text.

API Call: POST /messages (Standard messaging endpoint, entirely decoupled from the comments table).

Payload:

{
  "recipient_id": "u9x8y7z6...",
  "message": "> \"This is a profound insight on grace...\"\n\nI wanted to ask you a private question about this..."
}
