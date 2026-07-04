package sync

import (
	"context"
	"encoding/json"
	"time"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

type SyncEvent struct {
	Type           string          `json:"type"`
	ID             uuid.UUID       `json:"id"`
	Content        json.RawMessage `json:"content"`
	TitleOrCaption *string         `json:"title_or_caption,omitempty"`
	ParentID       *uuid.UUID      `json:"parent_id,omitempty"`
	ServerSequence int64           `json:"server_sequence"`
	Timestamp      time.Time       `json:"ts"`
}

type Repository struct {
	q *generated.Queries
}

func NewRepository(q *generated.Queries) *Repository {
	return &Repository{q: q}
}

func (r *Repository) PullSyncEvents(ctx context.Context, authorID uuid.UUID, lastSeq int64) ([]SyncEvent, error) {
	dbEvents, err := r.q.PullSyncEvents(ctx, generated.PullSyncEventsParams{
		AuthorID:       authorID,
		ServerSequence: lastSeq,
	})
	if err != nil {
		return nil, err
	}

	events := make([]SyncEvent, len(dbEvents))
	for i, dbEvt := range dbEvents {
		var parentID *uuid.UUID
		if dbEvt.ParentID.Valid {
			p := dbEvt.ParentID.UUID
			parentID = &p
		}

		var titleOrCaption *string
		if dbEvt.TitleOrCaption.Valid && dbEvt.TitleOrCaption.String != "" {
			s := dbEvt.TitleOrCaption.String
			titleOrCaption = &s
		}

		events[i] = SyncEvent{
			Type:           dbEvt.Type,
			ID:             dbEvt.ID,
			Content:        dbEvt.Content,
			TitleOrCaption: titleOrCaption,
			ParentID:       parentID,
			ServerSequence: dbEvt.ServerSequence,
			Timestamp:      dbEvt.Ts,
		}
	}
	return events, nil
}
