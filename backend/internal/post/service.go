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
	ErrNotFound      = errors.New("post not found")
	ErrUnauthorized  = errors.New("unauthorized to access this post")
	ErrPostImmutable = errors.New("post is immutable and cannot be updated")
)

type ScriptureRefPayload struct {
	Book       string `json:"book" binding:"required"`
	Chapter    int32  `json:"chapter" binding:"required"`
	VerseStart int32  `json:"verse_start" binding:"required"`
	VerseEnd   *int32 `json:"verse_end,omitempty"`
}

type PassagePanelInput struct {
	PanelType          string          `json:"panel_type" binding:"required"`
	Content            json.RawMessage `json:"content"`
	BackgroundImageURL *string         `json:"background_image_url,omitempty"`
	ScriptureRef       json.RawMessage `json:"scripture_ref,omitempty"`
}

type CreateInput struct {
	Content            json.RawMessage       `json:"content"`
	Caption            *string               `json:"caption,omitempty"`
	Visibility         *string               `json:"visibility,omitempty"`
	SermonSource       *string               `json:"sermon_source,omitempty"`
	Tags               []string              `json:"tags,omitempty"`
	ScriptureRefs      []ScriptureRefPayload `json:"scripture_refs,omitempty"`
	CoverImageUrl      *string               `json:"cover_image_url,omitempty"`
	ReflectionImageUrl *string               `json:"reflection_image_url,omitempty"`
	SoundID            *uuid.UUID            `json:"sound_id,omitempty"`
	Panels             []PassagePanelInput   `json:"panels,omitempty"`
	PostType           string                `json:"post_type,omitempty"`
}

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) ListSounds(ctx context.Context) ([]SoundTrack, error) {
	return s.repo.ListActiveSounds(ctx)
}

func (s *Service) Create(ctx context.Context, authorID uuid.UUID, input CreateInput) (Post, error) {
	// Default visibility to "public" if not specified by the client
	visibility := "public"
	if input.Visibility != nil {
		visibility = *input.Visibility
	}

	postType := "standard"
	if input.PostType != "" {
		postType = strings.ToLower(input.PostType)
	}

	if len(input.Content) == 0 {
		input.Content = json.RawMessage("{}")
	}

	// Post type specific validations per contract
	if postType == "reflection" {
		plainText, _ := quill.ToPlainText(input.Content)
		if len([]rune(strings.TrimSpace(plainText))) > 500 {
			return Post{}, errors.New("reflection body exceeds 500 character limit")
		}
		if input.CoverImageUrl != nil && *input.CoverImageUrl != "" {
			return Post{}, errors.New("cover_image_url is not allowed on reflection posts; use reflection_image_url")
		}
		if len(input.ScriptureRefs) > 1 {
			return Post{}, errors.New("reflection posts may have at most 1 scripture tag")
		}
	} else if postType == "passage" {
		if input.CoverImageUrl != nil && *input.CoverImageUrl != "" {
			return Post{}, errors.New("cover_image_url is not allowed on passage posts; use panel media")
		}
		if input.ReflectionImageUrl != nil && *input.ReflectionImageUrl != "" {
			return Post{}, errors.New("reflection_image_url is not allowed on passage posts")
		}
		if len(input.Panels) < 2 || len(input.Panels) > 12 {
			return Post{}, errors.New("passage posts must contain between 2 and 12 panels")
		}
	} else {
		// Standard post
		if input.ReflectionImageUrl != nil && *input.ReflectionImageUrl != "" {
			return Post{}, errors.New("reflection_image_url is only allowed on reflection posts")
		}
		if len(input.ScriptureRefs) < 2 || len(input.ScriptureRefs) > 3 {
			return Post{}, errors.New("standard posts must provide between 2 and 3 scripture tags")
		}
	}

	// Tag count validation (before any DB work)
	if len(input.Tags) > 8 {
		return Post{}, errors.New("maximum of 8 tags allowed")
	}

	// Build scripture ref params
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

	// Build passage panels
	var panels []PassagePanel
	if postType == "passage" && len(input.Panels) > 0 {
		panels = make([]PassagePanel, len(input.Panels))
		for i, panelInput := range input.Panels {
			panels[i] = PassagePanel{
				PanelOrder:         int32(i),
				PanelType:          panelInput.PanelType,
				Content:            panelInput.Content,
				BackgroundImageURL: panelInput.BackgroundImageURL,
				ScriptureRef:       panelInput.ScriptureRef,
			}
		}
	}

	// Single atomic transaction — all writes succeed or all roll back
	return s.repo.CreatePostTx(ctx, CreatePostTxParams{
		AuthorID:           authorID,
		Content:            input.Content,
		Caption:            input.Caption,
		Visibility:         visibility,
		SermonSource:       input.SermonSource,
		CoverImageUrl:      input.CoverImageUrl,
		ReflectionImageUrl: input.ReflectionImageUrl,
		SoundID:            input.SoundID,
		PostType:           postType,
		Tags:               input.Tags,
		ScriptureRefs:      refsParams,
		Panels:             panels,
	})
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

	if existing.PostType == "passage" || existing.PostType == "reflection" {
		return Post{}, ErrPostImmutable
	}

	// Default to existing visibility if not provided
	visibility := existing.Visibility
	if input.Visibility != nil {
		visibility = *input.Visibility
	}

	// Validate scripture refs (required for standard post updates)
	if len(input.ScriptureRefs) < 2 || len(input.ScriptureRefs) > 3 {
		return Post{}, errors.New("must provide between 2 and 3 scripture tags")
	}
	if len(input.Tags) > 8 {
		return Post{}, errors.New("maximum of 8 tags allowed")
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

	// Normalise nil tags to empty slice so ClearPostTags runs inside the tx
	tags := input.Tags
	if tags == nil {
		tags = []string{}
	}

	// Single atomic transaction
	return s.repo.UpdatePostTx(ctx, UpdatePostTxParams{
		PostID:         id,
		AuthorID:       authorID,
		Content:        input.Content,
		Caption:        input.Caption,
		Visibility:     visibility,
		SermonSource:   input.SermonSource,
		CurrentVersion: existing.CurrentVersion,
		CoverImageUrl:  input.CoverImageUrl,
		Tags:           tags,
		ScriptureRefs:  refsParams,
	})
}

func (s *Service) Delete(ctx context.Context, authorID, id uuid.UUID) error {
	_, err := s.GetAuthorOnly(ctx, authorID, id)
	if err != nil {
		return err
	}
	return s.repo.DeletePost(ctx, id, authorID)
}

type ReviseInput struct {
	Content       json.RawMessage `json:"content" binding:"required"`
	Caption       *string         `json:"caption,omitempty"`
	Tags          []string        `json:"tags,omitempty"`
	CoverImageUrl *string         `json:"cover_image_url,omitempty"`
}

func (s *Service) Revise(ctx context.Context, authorID, id uuid.UUID, input ReviseInput) (Post, error) {
	existing, err := s.GetAuthorOnly(ctx, authorID, id)
	if err != nil {
		return Post{}, err
	}

	if len(input.Tags) > 8 {
		return Post{}, errors.New("maximum of 8 tags allowed")
	}

	// Normalise nil tags to empty slice so ClearPostTags runs inside the tx
	tags := input.Tags
	if tags == nil {
		tags = []string{}
	}

	// Single atomic transaction — snapshot + update + tags
	return s.repo.RevisePostTx(ctx, RevisePostTxParams{
		PostID:         id,
		AuthorID:       authorID,
		CurrentContent: existing.Content,
		CurrentVersion: existing.CurrentVersion,
		NewContent:     input.Content,
		NewCaption:     input.Caption,
		CoverImageUrl:  input.CoverImageUrl,
		Tags:           tags,
	})
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

	// Validate scripture refs (required for corrections)
	if len(input.ScriptureRefs) < 2 || len(input.ScriptureRefs) > 3 {
		return Post{}, errors.New("must provide between 2 and 3 scripture tags")
	}
	if len(input.Tags) > 8 {
		return Post{}, errors.New("maximum of 8 tags allowed")
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

	// Single atomic transaction
	return s.repo.CreateCorrectionPostTx(ctx, CreateCorrectionPostTxParams{
		AuthorID:       authorID,
		Content:        input.Content,
		Caption:        input.Caption,
		Visibility:     visibility,
		SermonSource:   input.SermonSource,
		CorrectsPostID: correctsPostID,
		CoverImageUrl:  input.CoverImageUrl,
		PostType:       postType,
		Tags:           input.Tags,
		ScriptureRefs:  refsParams,
	})
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

	// Add Watermark
	if format == "md" {
		sb.WriteString("\n\n---\n\n")
		sb.WriteString(fmt.Sprintf("![Scribes Logo](data:image/svg+xml;base64,%s)\n", logoBase64))
		sb.WriteString("\n*Exported from Scribes*\n")
	} else {
		sb.WriteString("\n\n--------------------------------------------------\n")
		sb.WriteString("              Exported from Scribes               \n")
		sb.WriteString("--------------------------------------------------\n")
	}

	return []byte(sb.String()), nil
}
