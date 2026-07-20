package post

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

var (
	ErrNotFound     = errors.New("post not found")
	ErrUnauthorized = errors.New("unauthorized to access this post")
)

type ScriptureRefPayload struct {
	Book       string `json:"book" binding:"required"`
	Chapter    int32  `json:"chapter" binding:"required"`
	VerseStart int32  `json:"verse_start" binding:"required"`
	VerseEnd   *int32 `json:"verse_end,omitempty"`
}

type CreateInput struct {
	Content       json.RawMessage       `json:"content" binding:"required"`
	Caption       *string               `json:"caption,omitempty"`
	Visibility    *string               `json:"visibility,omitempty"`
	SermonSource  *string               `json:"sermon_source,omitempty"`
	CategoryIDs   []uuid.UUID           `json:"category_ids,omitempty"`
	ScriptureRefs []ScriptureRefPayload `json:"scripture_refs,omitempty"`
}

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) Create(ctx context.Context, authorID uuid.UUID, input CreateInput) (Post, error) {
	// Default visibility to "public" if not specified by the client
	visibility := "public"
	if input.Visibility != nil {
		visibility = *input.Visibility
	}

	p, err := s.repo.CreatePost(ctx, authorID, input.Content, input.Caption, visibility, input.SermonSource)
	if err != nil {
		return Post{}, err
	}

	if len(input.CategoryIDs) > 0 {
		err = s.repo.SetPostCategories(ctx, p.ID, input.CategoryIDs)
		if err != nil {
			return Post{}, err
		}
	}

	if len(input.ScriptureRefs) > 0 {
		if len(input.ScriptureRefs) > 3 || len(input.ScriptureRefs) < 2 {
			return Post{}, errors.New("must provide between 2 and 3 scripture tags")
		}
		var refsParams []generated.AddScriptureRefParams
		for _, ref := range input.ScriptureRefs {
			var ve sql.NullInt32
			if ref.VerseEnd != nil {
				ve = sql.NullInt32{Int32: *ref.VerseEnd, Valid: true}
			}
			refsParams = append(refsParams, generated.AddScriptureRefParams{
				Book:       ref.Book,
				Chapter:    ref.Chapter,
				VerseStart: ref.VerseStart,
				VerseEnd:   ve,
			})
		}
		err = s.repo.SetScriptureRefs(ctx, p.ID, refsParams)
		if err != nil {
			return Post{}, err
		}
		p.ScriptureRefs, _ = s.repo.GetScriptureRefs(ctx, p.ID)
	} else {
		// Enforce validation if required
		return Post{}, errors.New("must provide between 2 and 3 scripture tags")
	}

	return p, nil
}

func (s *Service) Get(ctx context.Context, id uuid.UUID) (Post, error) {
	post, err := s.repo.GetPostByID(ctx, id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return Post{}, ErrNotFound
		}
		return Post{}, err
	}
	return post, nil
}

// GetAuthorOnly fetches a post and verifies ownership. Used for mutations.
func (s *Service) GetAuthorOnly(ctx context.Context, authorID, id uuid.UUID) (Post, error) {
	post, err := s.Get(ctx, id)
	if err != nil {
		return Post{}, err
	}
	if post.AuthorID != authorID {
		return Post{}, ErrUnauthorized
	}
	return post, nil
}

func (s *Service) List(ctx context.Context, authorID uuid.UUID) ([]Post, error) {
	return s.repo.ListPostsByAuthor(ctx, authorID)
}

func (s *Service) Update(ctx context.Context, authorID, id uuid.UUID, input CreateInput) (Post, error) {
	existing, err := s.GetAuthorOnly(ctx, authorID, id)
	if err != nil {
		return Post{}, err
	}

	// Default to existing visibility if not provided
	visibility := existing.Visibility
	if input.Visibility != nil {
		visibility = *input.Visibility
	}

	updatedPost, err := s.repo.UpdatePost(ctx, id, authorID, input.Content, input.Caption, visibility, input.SermonSource, existing.CurrentVersion)
	if err != nil {
		return Post{}, err
	}

	if len(input.ScriptureRefs) > 0 {
		if len(input.ScriptureRefs) > 3 || len(input.ScriptureRefs) < 2 {
			return Post{}, errors.New("must provide between 2 and 3 scripture tags")
		}
		var refsParams []generated.AddScriptureRefParams
		for _, ref := range input.ScriptureRefs {
			var ve sql.NullInt32
			if ref.VerseEnd != nil {
				ve = sql.NullInt32{Int32: *ref.VerseEnd, Valid: true}
			}
			refsParams = append(refsParams, generated.AddScriptureRefParams{
				Book:       ref.Book,
				Chapter:    ref.Chapter,
				VerseStart: ref.VerseStart,
				VerseEnd:   ve,
			})
		}
		err = s.repo.SetScriptureRefs(ctx, updatedPost.ID, refsParams)
		if err != nil {
			return Post{}, err
		}
		updatedPost.ScriptureRefs, _ = s.repo.GetScriptureRefs(ctx, updatedPost.ID)
	} else {
		return Post{}, errors.New("must provide between 2 and 3 scripture tags")
	}

	return updatedPost, nil
}

func (s *Service) Delete(ctx context.Context, authorID, id uuid.UUID) error {
	_, err := s.GetAuthorOnly(ctx, authorID, id)
	if err != nil {
		return err
	}
	return s.repo.DeletePost(ctx, id, authorID)
}

type ReviseInput struct {
	Content       json.RawMessage       `json:"content" binding:"required"`
	Caption       *string               `json:"caption,omitempty"`
}

func (s *Service) Revise(ctx context.Context, authorID, id uuid.UUID, input ReviseInput) (Post, error) {
	existing, err := s.GetAuthorOnly(ctx, authorID, id)
	if err != nil {
		return Post{}, err
	}

	return s.repo.RevisePost(ctx, id, authorID, existing.Content, existing.CurrentVersion, input.Content, input.Caption)
}

func (s *Service) CreateCorrection(ctx context.Context, authorID, correctsPostID uuid.UUID, input CreateInput) (Post, error) {
	// Verify the original post exists
	_, err := s.Get(ctx, correctsPostID)
	if err != nil {
		return Post{}, err
	}

	visibility := "public"
	if input.Visibility != nil {
		visibility = *input.Visibility
	}

	p, err := s.repo.CreateCorrectionPost(ctx, authorID, input.Content, input.Caption, visibility, input.SermonSource, correctsPostID)
	if err != nil {
		return Post{}, err
	}

	if len(input.ScriptureRefs) > 0 {
		if len(input.ScriptureRefs) > 3 || len(input.ScriptureRefs) < 2 {
			return Post{}, errors.New("must provide between 2 and 3 scripture tags")
		}
		var refsParams []generated.AddScriptureRefParams
		for _, ref := range input.ScriptureRefs {
			var ve sql.NullInt32
			if ref.VerseEnd != nil {
				ve = sql.NullInt32{Int32: *ref.VerseEnd, Valid: true}
			}
			refsParams = append(refsParams, generated.AddScriptureRefParams{
				Book:       ref.Book,
				Chapter:    ref.Chapter,
				VerseStart: ref.VerseStart,
				VerseEnd:   ve,
			})
		}
		err = s.repo.SetScriptureRefs(ctx, p.ID, refsParams)
		if err != nil {
			return Post{}, err
		}
		p.ScriptureRefs, _ = s.repo.GetScriptureRefs(ctx, p.ID)
	} else {
		return Post{}, errors.New("must provide between 2 and 3 scripture tags")
	}

	return p, nil
}

func (s *Service) ListVersions(ctx context.Context, id uuid.UUID) ([]PostVersion, error) {
	// Verify post exists
	_, err := s.Get(ctx, id)
	if err != nil {
		return nil, err
	}
	return s.repo.ListVersionsByPost(ctx, id)
}

func (s *Service) GetVersion(ctx context.Context, id uuid.UUID, version int32) (PostVersion, error) {
	versionInfo, err := s.repo.GetVersionByPostAndNumber(ctx, id, version)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return PostVersion{}, ErrNotFound
		}
		return PostVersion{}, err
	}
	return versionInfo, nil
}