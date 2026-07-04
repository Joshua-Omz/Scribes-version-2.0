DROP TRIGGER IF EXISTS trg_message_last_active ON messages;
DROP FUNCTION IF EXISTS update_conversation_last_active();
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS message_requests;
DROP TABLE IF EXISTS conversations;
DROP TYPE IF EXISTS request_status;
