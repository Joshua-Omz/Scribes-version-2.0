package post

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"strings"

	"fmt"

	"scribes-api/internal/db/generated"
	"scribes-api/pkg/quill"

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
	Tags          []string              `json:"tags,omitempty"`
	ScriptureRefs []ScriptureRefPayload `json:"scripture_refs,omitempty"`
	CoverImageUrl *string               `json:"cover_image_url,omitempty"`
	PostType      string                `json:"post_type,omitempty"`
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
	
	postType := "standard"
	if input.PostType != "" {
		postType = input.PostType
	}

	p, err := s.repo.CreatePost(ctx, authorID, input.Content, input.Caption, visibility, input.SermonSource, input.CoverImageUrl, postType)
	if err != nil {
		return Post{}, err
	}

	if len(input.Tags) > 0 {
		if len(input.Tags) > 8 {
			return Post{}, errors.New("maximum of 8 tags allowed")
		}
		err = s.repo.SetPostTags(ctx, p.ID, input.Tags)
		if err != nil {
			return Post{}, err
		}
		p.Tags, _ = s.repo.GetPostTags(ctx, p.ID)
	} else {
		p.Tags = []string{}
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

	updatedPost, err := s.repo.UpdatePost(ctx, id, authorID, input.Content, input.Caption, visibility, input.SermonSource, existing.CurrentVersion, input.CoverImageUrl)
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

	if len(input.Tags) > 0 {
		if len(input.Tags) > 8 {
			return Post{}, errors.New("maximum of 8 tags allowed")
		}
		err = s.repo.SetPostTags(ctx, updatedPost.ID, input.Tags)
		if err != nil {
			return Post{}, err
		}
		updatedPost.Tags, _ = s.repo.GetPostTags(ctx, updatedPost.ID)
	} else {
		err = s.repo.SetPostTags(ctx, updatedPost.ID, []string{})
		if err != nil {
			return Post{}, err
		}
		updatedPost.Tags = []string{}
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
	Tags          []string              `json:"tags,omitempty"`
	CoverImageUrl *string               `json:"cover_image_url,omitempty"`
}

func (s *Service) Revise(ctx context.Context, authorID, id uuid.UUID, input ReviseInput) (Post, error) {
	existing, err := s.GetAuthorOnly(ctx, authorID, id)
	if err != nil {
		return Post{}, err
	}

	updatedPost, err := s.repo.RevisePost(ctx, id, authorID, existing.Content, existing.CurrentVersion, input.Content, input.Caption, input.CoverImageUrl)
	if err != nil {
		return Post{}, err
	}
	
	if len(input.Tags) > 0 {
		if len(input.Tags) > 8 {
			return Post{}, errors.New("maximum of 8 tags allowed")
		}
		err = s.repo.SetPostTags(ctx, updatedPost.ID, input.Tags)
		if err != nil {
			return Post{}, err
		}
		updatedPost.Tags, _ = s.repo.GetPostTags(ctx, updatedPost.ID)
	} else {
		err = s.repo.SetPostTags(ctx, updatedPost.ID, []string{})
		if err != nil {
			return Post{}, err
		}
		updatedPost.Tags = []string{}
	}

	return updatedPost, nil
}

func (s *Service) CreateCorrection(ctx context.Context, authorID, correctsPostID uuid.UUID, input CreateInput) (Post, error) {
	// Verify the original post exists
	_, err := s.Get(ctx, correctsPostID)
	if err != nil {
		return Post{}, err
	}
	
	postType := "standard"
	if input.PostType != "" {
		postType = input.PostType
	}

	visibility := "public"
	if input.Visibility != nil {
		visibility = *input.Visibility
	}

	p, err := s.repo.CreateCorrectionPost(ctx, authorID, input.Content, input.Caption, visibility, input.SermonSource, correctsPostID, input.CoverImageUrl, postType)
	if err != nil {
		return Post{}, err
	}

	if len(input.Tags) > 0 {
		if len(input.Tags) > 8 {
			return Post{}, errors.New("maximum of 8 tags allowed")
		}
		err = s.repo.SetPostTags(ctx, p.ID, input.Tags)
		if err != nil {
			return Post{}, err
		}
		p.Tags, _ = s.repo.GetPostTags(ctx, p.ID)
	} else {
		p.Tags = []string{}
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

func (s *Service) Export(ctx context.Context, id uuid.UUID, format string) ([]byte, error) {
	post, err := s.Get(ctx, id)
	if err != nil {
		return nil, err
	}

	var contentStr string
	if format == "md" {
		contentStr, err = quill.ToMarkdown(post.Content)
	} else {
		contentStr, err = quill.ToPlainText(post.Content)
	}
	if err != nil {
		return nil, err
	}

	var sb strings.Builder
	
	// Add Caption if present
	if post.Caption != nil {
		if format == "md" {
			sb.WriteString(fmt.Sprintf("# %s\n\n", *post.Caption))
		} else {
			sb.WriteString(fmt.Sprintf("%s\n\n", *post.Caption))
		}
	}

	// Add Author
	sb.WriteString(fmt.Sprintf("By: %s (@%s)\n", post.AuthorName, post.AuthorHandle))
	sb.WriteString(fmt.Sprintf("Published: %s\n\n", post.PublishedAt.Format("Jan 02, 2006")))

	// Add Scripture Refs
	if len(post.ScriptureRefs) > 0 {
		sb.WriteString("Scripture References:\n")
		for _, ref := range post.ScriptureRefs {
			if ref.VerseEnd.Valid {
				sb.WriteString(fmt.Sprintf("- %s %d:%d-%d\n", ref.Book, ref.Chapter, ref.VerseStart, ref.VerseEnd.Int32))
			} else {
				sb.WriteString(fmt.Sprintf("- %s %d:%d\n", ref.Book, ref.Chapter, ref.VerseStart))
			}
		}
		sb.WriteString("\n")
	}

	sb.WriteString("---\n\n")
	sb.WriteString(contentStr)

	return []byte(sb.String()), nil
}