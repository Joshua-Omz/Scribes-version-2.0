-- ═══════════════════════════════════════════════
-- SPRINT 7: Conversations, Message Requests,
--           Messages
-- ═══════════════════════════════════════════════

CREATE TYPE request_status AS ENUM (
    'pending',
    'approved',
    'rejected'
);

-- ── Conversations ──────────────────────────────
-- A conversation is created when a message request
-- is approved. Not before.
-- blocked = true prevents further messages from
-- either party. Does not reveal who blocked whom.
CREATE TABLE conversations (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_a_id   UUID        NOT NULL REFERENCES users(id),
    user_b_id   UUID        NOT NULL REFERENCES users(id),
    blocked     BOOLEAN     NOT NULL DEFAULT false,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_active TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_a_id, user_b_id),
    CONSTRAINT no_self_conversation CHECK (user_a_id != user_b_id)
);

CREATE INDEX idx_conversations_user_a ON conversations (user_a_id, last_active DESC);
CREATE INDEX idx_conversations_user_b ON conversations (user_b_id, last_active DESC);
CREATE INDEX idx_conversations_active ON conversations (last_active ASC);  -- for retention worker

-- ── Message requests ───────────────────────────
-- A non-mutual sender must request before messaging.
-- first_message is shown in the request preview.
-- No conversation row exists until status = approved.
CREATE TABLE message_requests (
    id            UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    from_user_id  UUID           NOT NULL REFERENCES users(id),
    to_user_id    UUID           NOT NULL REFERENCES users(id),
    status        request_status NOT NULL DEFAULT 'pending',
    first_message TEXT           NOT NULL,
    created_at    TIMESTAMPTZ    NOT NULL DEFAULT now(),
    CONSTRAINT no_self_request CHECK (from_user_id != to_user_id)
);

CREATE INDEX idx_requests_to   ON message_requests (to_user_id, status)
    WHERE status = 'pending';
CREATE INDEX idx_requests_from ON message_requests (from_user_id);

-- ── Messages ───────────────────────────────────
-- Text only. No attachments. No media.
-- Soft-delete: body replaced with '[Message deleted]'
-- at the repository layer — the row is never removed.
-- Retention: background worker purges conversations
-- with last_active older than 12 months.
CREATE TABLE messages (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id  UUID        NOT NULL REFERENCES conversations(id),
    sender_id        UUID        NOT NULL REFERENCES users(id),
    body             TEXT        NOT NULL,
    is_deleted       BOOLEAN     NOT NULL DEFAULT false,
    sent_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT body_not_empty CHECK (length(trim(body)) > 0),
    CONSTRAINT body_max_length CHECK (length(body) <= 4000)
);

CREATE INDEX idx_messages_conversation
    ON messages (conversation_id, sent_at ASC);
CREATE INDEX idx_messages_sender
    ON messages (sender_id);

-- ── Retention policy trigger (update last_active) ──
CREATE OR REPLACE FUNCTION update_conversation_last_active()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE conversations
    SET last_active = now()
    WHERE id = NEW.conversation_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_message_last_active
    AFTER INSERT ON messages
    FOR EACH ROW
    EXECUTE FUNCTION update_conversation_last_active();
