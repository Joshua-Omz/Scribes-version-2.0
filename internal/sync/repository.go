package sync

import (
	"context"
	"database/sql"
	"fmt"
	"time"
)

// Repository defines delta sync data access.
type Repository interface {
	Delta(ctx context.Context, userID string, since time.Time) (*DeltaResponse, error)
}

type postgresRepo struct {
	db *sql.DB
}

// NewRepository creates a PostgreSQL-backed sync repository.
func NewRepository(db *sql.DB) Repository {
	return &postgresRepo{db: db}
}

func (r *postgresRepo) Delta(ctx context.Context, userID string, since time.Time) (*DeltaResponse, error) {
	resp := &DeltaResponse{
		Notes:     []NoteSync{},
		Posts:     []PostSync{},
		Bookmarks: []BookmarkSync{},
		SyncedAt:  time.Now().UTC(),
	}

	// Notes updated after since (include deleted for tombstones).
	noteRows, err := r.db.QueryContext(ctx,
		`SELECT id, user_id, title, content, is_published, is_imported, created_at, updated_at, deleted_at
		 FROM notes WHERE user_id = $1 AND updated_at > $2 ORDER BY updated_at ASC`,
		userID, since,
	)
	if err != nil {
		return nil, fmt.Errorf("sync notes: %w", err)
	}
	defer noteRows.Close()
	for noteRows.Next() {
		n := NoteSync{}
		if err := noteRows.Scan(&n.ID, &n.UserID, &n.Title, &n.Content, &n.IsPublished, &n.IsImported, &n.CreatedAt, &n.UpdatedAt, &n.DeletedAt); err != nil {
			return nil, fmt.Errorf("scan note: %w", err)
		}
		resp.Notes = append(resp.Notes, n)
	}
	if err := noteRows.Err(); err != nil {
		return nil, err
	}

	// Posts updated after since (all, including archived/deleted for tombstones).
	postRows, err := r.db.QueryContext(ctx,
		`SELECT id, user_id, note_id, title, content, is_archived, published_at, created_at, updated_at, deleted_at
		 FROM posts WHERE user_id = $1 AND updated_at > $2 ORDER BY updated_at ASC`,
		userID, since,
	)
	if err != nil {
		return nil, fmt.Errorf("sync posts: %w", err)
	}
	defer postRows.Close()
	for postRows.Next() {
		p := PostSync{}
		if err := postRows.Scan(&p.ID, &p.UserID, &p.NoteID, &p.Title, &p.Content, &p.IsArchived, &p.PublishedAt, &p.CreatedAt, &p.UpdatedAt, &p.DeletedAt); err != nil {
			return nil, fmt.Errorf("scan post: %w", err)
		}
		resp.Posts = append(resp.Posts, p)
	}
	if err := postRows.Err(); err != nil {
		return nil, err
	}

	// Bookmarks created after since.
	bmRows, err := r.db.QueryContext(ctx,
		`SELECT id, post_id, user_id, created_at
		 FROM bookmarks WHERE user_id = $1 AND created_at > $2 ORDER BY created_at ASC`,
		userID, since,
	)
	if err != nil {
		return nil, fmt.Errorf("sync bookmarks: %w", err)
	}
	defer bmRows.Close()
	for bmRows.Next() {
		b := BookmarkSync{}
		if err := bmRows.Scan(&b.ID, &b.PostID, &b.UserID, &b.CreatedAt); err != nil {
			return nil, fmt.Errorf("scan bookmark: %w", err)
		}
		resp.Bookmarks = append(resp.Bookmarks, b)
	}
	if err := bmRows.Err(); err != nil {
		return nil, err
	}

	return resp, nil
}
