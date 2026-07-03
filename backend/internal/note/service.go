package note

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"

	"github.com/google/uuid"
)

var (
	ErrNotFound     = errors.New("note not found")
	ErrUnauthorized = errors.New("unauthorized")
)

type CreateInput struct {
	Content     json.RawMessage `json:"content" binding:"required"`
	Title       *string         `json:"title,omitempty"`
	NotebookID  *uuid.UUID      `json:"notebook_id,omitempty"`
	SourceType  *string         `json:"source_type,omitempty"`
	SourceLabel *string         `json:"source_label,omitempty"`
}

type DraftCreator interface {
	CreateDraftFromNote(ctx context.Context, authorID uuid.UUID, n Note) (uuid.UUID, error)
}

type Service struct {
	repo         *Repository
	draftCreator DraftCreator
}

func NewService(repo *Repository, draftCreator DraftCreator) *Service {
	return &Service{
		repo:         repo,
		draftCreator: draftCreator,
	}
}

func (s *Service) List(ctx context.Context, authorID uuid.UUID) ([]Note, error) {
	return s.repo.ListNotesByAuthor(ctx, authorID)
}

func (s *Service) Create(ctx context.Context, authorID uuid.UUID, input CreateInput) (Note, error) {
	return s.repo.CreateNote(ctx, authorID, input.Content, input.Title, input.NotebookID, input.SourceType, input.SourceLabel)
}

func (s *Service) Update(ctx context.Context, authorID, noteID uuid.UUID, input CreateInput) (Note, error) {
	note, err := s.repo.GetNoteByID(ctx, noteID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return Note{}, ErrNotFound
		}
		return Note{}, err
	}
	if note.AuthorID != authorID {
		return Note{}, ErrUnauthorized
	}

	return s.repo.UpdateNote(ctx, noteID, authorID, input.Content, input.Title, input.NotebookID, input.SourceType, input.SourceLabel)
}

func (s *Service) Delete(ctx context.Context, authorID, noteID uuid.UUID) error {
	note, err := s.repo.GetNoteByID(ctx, noteID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return ErrNotFound
		}
		return err
	}
	if note.AuthorID != authorID {
		return ErrUnauthorized
	}

	return s.repo.DeleteNote(ctx, noteID, authorID)
}

func (s *Service) Promote(ctx context.Context, authorID, noteID uuid.UUID) (uuid.UUID, error) {
	if s.draftCreator == nil {
		return uuid.Nil, errors.New("draft creation is not configured")
	}

	note, err := s.repo.GetNoteByID(ctx, noteID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return uuid.Nil, ErrNotFound
		}
		return uuid.Nil, err
	}
	if note.AuthorID != authorID {
		return uuid.Nil, ErrUnauthorized
	}

	return s.draftCreator.CreateDraftFromNote(ctx, authorID, note)
}
