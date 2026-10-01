-- MIGRATION 026: Quoted Posts

-- Add nullable foreign key quoted_post_id to posts
ALTER TABLE posts
    ADD COLUMN quoted_post_id UUID REFERENCES posts(id) ON DELETE SET NULL;

-- Constraint: Reflections and Standard posts can quote other posts. Passage posts cannot.
ALTER TABLE posts
    ADD CONSTRAINT valid_quoted_post_type
    CHECK (
        quoted_post_id IS NULL
        OR post_type IN ('reflection', 'standard')
    );

-- Index to optimize querying "who quoted this post?"
CREATE INDEX idx_posts_quoted ON posts (quoted_post_id) WHERE quoted_post_id IS NOT NULL;
