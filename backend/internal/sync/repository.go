package sync

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"time"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

// SyncEvent is the domain model returned by Pull.
type SyncEvent struct {
	Type           string          `json:"type"`
	ID             uuid.UUID       `json:"id"`
	Content        json.RawMessage `json:"content"`
	TitleOrCaption *string         `json:"title_or_caption,omitempty"`
	ParentID       *uuid.UUID      `json:"parent_id,omitempty"`
	ServerSequence int64           `json:"server_sequence"`
	Timestamp      time.Time       `json:"ts"`
}

// SyncPushEvent is a single mutation sent by the client during Push.
type SyncPushEvent struct {
	Type           string          `json:"type"` // "note" or "draft"
	ID             uuid.UUID       `json:"id"`
	Content        json.RawMessage `json:"content"`
	TitleOrCaption *string         `json:"title_or_caption,omitempty"`
	ParentID       *uuid.UUID      `json:"parent_id,omitempty"`     // notebook_id for notes
	SourceType     *string         `json:"source_type,omitempty"`   // note-specific
	SourceLabel    *string         `json:"source_label,omitempty"`  // note-specific
	SermonSource   *string         `json:"sermon_source,omitempty"` // draft-specific
}

// SyncPushResult is the response from a successful Push.
type SyncPushResult struct {
	Applied     int   `json:"applied"`
	MaxSequence int64 `json:"max_sequence"`
}

type Repository struct {
	q  *generated.Queries
	db *sql.DB
}

func NewRepository(q *generated.Queries, db *sql.DB) *Repository {
	return &Repository{q: q, db: db}
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

// PushSyncEvents applies a batch of offline mutations inside a single transaction.
func (r *Repository) PushSyncEvents(ctx context.Context, authorID uuid.UUID, events []SyncPushEvent) (*SyncPushResult, error) {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return nil, fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback()

	qtx := r.q.WithTx(tx)

	var maxSeq int64
	applied := 0

	for _, evt := range events {
		switch evt.Type {
		case "note":
			title := sql.NullString{}
			if evt.TitleOrCaption != nil {
				title = sql.NullString{String: *evt.TitleOrCaption, Valid: true}
			}
			notebookID := uuid.NullUUID{}
			if evt.ParentID != nil {
				notebookID = uuid.NullUUID{UUID: *evt.ParentID, Valid: true}
			}
			sourceType := generated.NullNoteSourceType{}
			if evt.SourceType != nil {
				sourceType = generated.NullNoteSourceType{
					NoteSourceType: generated.NoteSourceType(*evt.SourceType),
					Valid:          true,
				}
			}
			sourceLabel := sql.NullString{}
			if evt.SourceLabel != nil {
				sourceLabel = sql.NullString{String: *evt.SourceLabel, Valid: true}
			}

			note, err := qtx.UpsertNote(ctx, generated.UpsertNoteParams{
				ID:          evt.ID,
				AuthorID:    authorID,
				Content:     evt.Content,
				Title:       title,
				NotebookID:  notebookID,
				SourceType:  sourceType,
				SourceLabel: sourceLabel,
			})
			if err != nil {
				return nil, fmt.Errorf("upsert note %s: %w", evt.ID, err)
			}
			if note.ServerSequence > maxSeq {
				maxSeq = note.ServerSequence
			}
			applied++

		case "draft":
			caption := sql.NullString{}
			if evt.TitleOrCaption != nil {
				caption = sql.NullString{String: *evt.TitleOrCaption, Valid: true}
			}
			sermonSource := sql.NullString{}
			if evt.SermonSource != nil {
				sermonSource = sql.NullString{String: *evt.SermonSource, Valid: true}
			}

			draft, err := qtx.UpsertDraft(ctx, generated.UpsertDraftParams{
				ID:           evt.ID,
				AuthorID:     authorID,
				Content:      evt.Content,
				Caption:      caption,
				SermonSource: sermonSource,
			})
			if err != nil {
				return nil, fmt.Errorf("upsert draft %s: %w", evt.ID, err)
			}
			if draft.ServerSequence > maxSeq {
				maxSeq = draft.ServerSequence
			}
			applied++

		default:
			return nil, fmt.Errorf("unknown sync event type: %s", evt.Type)
		}
	}

	if err := tx.Commit(); err != nil {
		return nil, fmt.Errorf("commit tx: %w", err)
	}

	return &SyncPushResult{
		Applied:     applied,
		MaxSequence: maxSeq,
	}, nil
}
