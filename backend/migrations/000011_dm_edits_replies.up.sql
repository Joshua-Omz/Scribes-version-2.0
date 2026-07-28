-- ═══════════════════════════════════════════════
-- SPRINT 7b: DM Edits and Replies
-- ═══════════════════════════════════════════════

ALTER TABLE messages 
ADD COLUMN reply_to_id UUID REFERENCES messages(id) ON DELETE SET NULL,
ADD COLUMN edited_at TIMESTAMPTZ;
