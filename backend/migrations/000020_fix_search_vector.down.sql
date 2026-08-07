CREATE OR REPLACE FUNCTION update_post_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', COALESCE(NEW.caption, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.content->>'text', '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.sermon_source, '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

UPDATE posts SET id = id;
