package draft

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"

	"scribes-api/internal/note"
	"scribes-api/internal/post"

	"github.com/google/uuid"
)

var (
	ErrNotFound     = errors.New("draft not found")
	ErrUnauthorized = errors.New("unauthorized")
)

type CreateInput struct {
	Content      json.RawMessage `json:"content" binding:"required"`
	Caption      *string         `json:"caption,omitempty"`
	SermonSource *string         `json:"sermon_source,omitempty"`
	CategoryIDs  []uuid.UUID     `json:"category_ids,omitempty"`
}

type Service struct {
	repo    *Repository
	postSvc *post.Service
}

func NewService(repo *Repository, postSvc *post.Service) *Service {
	return &Service{repo: repo, postSvc: postSvc}
}

func (s *Service) List(ctx context.Context, authorID uuid.UUID) ([]Draft, error) {
	return s.repo.ListDraftsByAuthor(ctx, authorID)
}

func (s *Service) GetByID(ctx context.Context, authorID, draftID uuid.UUID) (Draft, error) {
	draft, err := s.repo.GetDraftByID(ctx, draftID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return Draft{}, ErrNotFound
		}
		return Draft{}, err
	}
	if draft.AuthorID != authorID {
		return Draft{}, ErrUnauthorized
	}
	return draft, nil
}

func (s *Service) Create(ctx context.Context, authorID uuid.UUID, input CreateInput) (Draft, error) {
	d, err := s.repo.CreateDraft(ctx, authorID, input.Content, input.Caption, input.SermonSource)
	if err != nil {
		return Draft{}, err
	}
	if len(input.CategoryIDs) > 0 {
		err = s.repo.SetDraftCategories(ctx, d.ID, input.CategoryIDs)
		if err != nil {
			return Draft{}, err
		}
	}
	return d, nil
}

func (s *Service) Update(ctx context.Context, authorID, draftID uuid.UUID, input CreateInput) (Draft, error) {
	draft, err := s.repo.GetDraftByID(ctx, draftID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return Draft{}, ErrNotFound
		}
		return Draft{}, err
	}
	if draft.AuthorID != authorID {
		return Draft{}, ErrUnauthorized
	}

	d, err := s.repo.UpdateDraft(ctx, draftID, authorID, input.Content, input.Caption, input.SermonSource)
	if err != nil {
		return Draft{}, err
	}

	err = s.repo.SetDraftCategories(ctx, d.ID, input.CategoryIDs)
	if err != nil {
		return Draft{}, err
	}
	
	return d, nil
}

func (s *Service) Delete(ctx context.Context, authorID, draftID uuid.UUID) error {
	draft, err := s.repo.GetDraftByID(ctx, draftID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return ErrNotFound
		}
		return err
	}
	if draft.AuthorID != authorID {
		return ErrUnauthorized
	}

	return s.repo.DeleteDraft(ctx, draftID, authorID)
}

// CreateDraftFromNote satisfies the note.DraftCreator interface
func (s *Service) CreateDraftFromNote(ctx context.Context, authorID uuid.UUID, n note.Note) (uuid.UUID, error) {
	// We map the Note's Title to the Draft's Caption
	// We map the Note's SourceLabel to the Draft's SermonSource
	draft, err := s.repo.CreateDraft(ctx, authorID, n.Content, n.Title, n.SourceLabel)
	if err != nil {
		return uuid.Nil, err
	}
	return draft.ID, nil
}

func (s *Service) Publish(ctx context.Context, authorID, draftID uuid.UUID) (post.Post, error) {
	d, err := s.GetByID(ctx, authorID, draftID)
	if err != nil {
		return post.Post{}, err
	}

	catIDs, err := s.repo.GetDraftCategories(ctx, draftID)
	if err != nil {
		return post.Post{}, err
	}

	p, err := s.postSvc.Create(ctx, authorID, post.CreateInput{
		Content:      d.Content,
		Caption:      d.Caption,
		SermonSource: d.SermonSource,
		CategoryIDs:  catIDs,
	})
	if err != nil {
		return post.Post{}, err
	}

	err = s.repo.DeleteDraft(ctx, draftID, authorID)
	if err != nil {
		return post.Post{}, err
	}

	return p, nil
}
