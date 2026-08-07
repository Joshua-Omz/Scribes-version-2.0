ALTER TABLE conversations
    DROP COLUMN IF EXISTS user_a_last_read_at,
    DROP COLUMN IF EXISTS user_b_last_read_at;
