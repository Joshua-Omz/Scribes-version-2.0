-- ═══════════════════════════════════════════════
-- MIGRATION 016: DM Notifications
-- ═══════════════════════════════════════════════

ALTER TYPE notif_type ADD VALUE IF NOT EXISTS 'direct_message';
