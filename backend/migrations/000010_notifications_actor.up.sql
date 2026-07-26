ALTER TABLE notifications ADD COLUMN actor_id UUID REFERENCES users(id);
