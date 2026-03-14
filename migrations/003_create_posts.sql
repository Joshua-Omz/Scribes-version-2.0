-- 003_create_posts.sql
CREATE TABLE IF NOT EXISTS posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    note_id UUID REFERENCES notes(id),
    title TEXT NOT NULL,
    content JSONB NOT NULL,
    is_archived BOOLEAN DEFAULT FALSE,
    published_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);
