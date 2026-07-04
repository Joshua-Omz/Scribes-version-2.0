-- ═══════════════════════════════════════════════
-- SPRINT 8: Notifications
-- ═══════════════════════════════════════════════

CREATE TYPE notif_type AS ENUM (
    'mention',       -- real-time
    'reaction',      -- batched digest
    'comment',       -- batched digest
    'follow',        -- batched digest
    'admin_alert'    -- real-time
);

-- ── Notifications ──────────────────────────────
-- Two delivery paths:
-- is_realtime = true  → mention, admin_alert → immediate push
-- is_realtime = false → reaction, comment, follow → batched digest
-- ref_id is polymorphic — points to comment/post/user
-- depending on type. Resolved at the service layer.
CREATE TABLE notifications (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_id UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type         notif_type  NOT NULL,
    ref_id       UUID        NOT NULL,
    is_realtime  BOOLEAN     NOT NULL,
    is_read      BOOLEAN     NOT NULL DEFAULT false,
    sent_at      TIMESTAMPTZ,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_notifications_recipient
    ON notifications (recipient_id, created_at DESC)
    WHERE is_read = false;
CREATE INDEX idx_notifications_unsent
    ON notifications (is_realtime, sent_at)
    WHERE sent_at IS NULL;

-- ── Content reports ────────────────────────────
-- Standard user reporting. Content stays active
-- until a SUPER_ADMIN reviews and actions it.
CREATE TYPE report_status AS ENUM (
    'pending',
    'reviewed',
    'actioned',
    'dismissed'
);

CREATE TABLE reports (
    id            UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id   UUID          NOT NULL REFERENCES users(id),
    content_type  TEXT          NOT NULL,   -- 'post' | 'comment' | 'message'
    content_id    UUID          NOT NULL,
    reason        TEXT          NOT NULL,
    status        report_status NOT NULL DEFAULT 'pending',
    reviewed_by   UUID          REFERENCES users(id),
    reviewed_at   TIMESTAMPTZ,
    created_at    TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX idx_reports_status ON reports (status, created_at ASC)
    WHERE status = 'pending';
