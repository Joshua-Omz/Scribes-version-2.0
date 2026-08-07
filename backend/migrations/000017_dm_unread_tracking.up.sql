-- ═══════════════════════════════════════════════
-- Add Read State Tracking to Conversations
-- ═══════════════════════════════════════════════

ALTER TABLE conversations
    ADD COLUMN user_a_last_read_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    ADD COLUMN user_b_last_read_at TIMESTAMPTZ NOT NULL DEFAULT now();
