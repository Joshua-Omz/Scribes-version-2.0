package feed

import (
	"context"
	"encoding/base64"
	"fmt"
	"strings"
	"time"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

// Cursor logic
// We encode as Base64( "timestamp_in_rfc3339nano|uuid" )
func encodeCursor(t time.Time, id uuid.UUID) string {
	raw := fmt.Sprintf("%s|%s", t.Format(time.RFC3339Nano), id.String())
	return base64.RawURLEncoding.EncodeToString([]byte(raw))
}

func decodeCursor(cursor string) (time.Time, uuid.UUID, error) {
	if cursor == "" {
		// Return far future to get the very first page
		return time.Now().Add(time.Hour * 24 * 365), uuid.Nil, nil
	}

	decoded, err := base64.RawURLEncoding.DecodeString(cursor)
	if err != nil {
		return time.Time{}, uuid.Nil, fmt.Errorf("invalid cursor format")
	}

	parts := strings.SplitN(string(decoded), "|", 2)
	if len(parts) != 2 {
		return time.Time{}, uuid.Nil, fmt.Errorf("invalid cursor format")
	}

	t, err := time.Parse(time.RFC3339Nano, parts[0])
	if err != nil {
		return time.Time{}, uuid.Nil, fmt.Errorf("invalid cursor time")
	}

	id, err := uuid.Parse(parts[1])
	if err != nil {
		return time.Time{}, uuid.Nil, fmt.Errorf("invalid cursor id")
	}

	return t, id, nil
}

type PaginatedFeedResponse struct {
	Posts      []FeedPost `json:"posts"`
	NextCursor string     `json:"next_cursor,omitempty"`
}

type PaginatedExploreResponse struct {
	Posts      []FeedPost `json:"posts"`
	NextCursor string     `json:"next_cursor,omitempty"`
}

type PaginatedExploreCategoryResponse struct {
	Posts      []FeedPost `json:"posts"`
	NextCursor string     `json:"next_cursor,omitempty"`
}

type ExploreParams struct {
	Cursor          string
	Limit           int32
	CategoryID      *uuid.UUID
	SearchQuery     *string
	ScriptureBook   *string
	ScriptureChapter *int32
}



func (s *Service) GetFeed(ctx context.Context, cursor string, limit int32) (PaginatedFeedResponse, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	
	t, id, err := decodeCursor(cursor)
	if err != nil {
		return PaginatedFeedResponse{}, err
	}

	// Fetch limit + 1 to check if there is a next page
	posts, err := s.repo.GetFeedPosts(ctx, t, id, limit+1)
	if err != nil {
		return PaginatedFeedResponse{}, err
	}
	var nextCursor string
	if len(posts) > int(limit) {
		last := posts[limit-1]
		nextCursor = encodeCursor(last.PublishedAt, last.ID)
		posts = posts[:limit]
	}

	return PaginatedFeedResponse{
		Posts:      posts,
		NextCursor: nextCursor,
	}, nil
}

func (s *Service) GetFollowingFeed(ctx context.Context, cursor string, limit int32, userID uuid.UUID) (PaginatedFeedResponse, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	
	t, id, err := decodeCursor(cursor)
	if err != nil {
		return PaginatedFeedResponse{}, err
	}

	// Fetch limit + 1 to check if there is a next page
	posts, err := s.repo.GetFollowingFeedPosts(ctx, userID, t, id, limit+1)
	if err != nil {
		return PaginatedFeedResponse{}, err
	}
	
	var nextCursor string
	if len(posts) > int(limit) {
		last := posts[limit-1]
		nextCursor = encodeCursor(last.PublishedAt, last.ID)
		posts = posts[:limit]
	}

	return PaginatedFeedResponse{
		Posts:      posts,
		NextCursor: nextCursor,
	}, nil
}

func (s *Service) GetExplore(ctx context.Context, params ExploreParams) (interface{}, error) {
	limit := params.Limit
	if limit <= 0 || limit > 100 {
		limit = 20
	}

	t, id, err := decodeCursor(params.Cursor)
	if err != nil {
		return nil, err
	}

	var posts []FeedPost
	if params.CategoryID != nil {
		posts, err = s.repo.GetExplorePostsByCategory(ctx, *params.CategoryID, t, id, limit+1)
	} else if params.SearchQuery != nil && *params.SearchQuery != "" {
		posts, err = s.repo.SearchExplorePosts(ctx, *params.SearchQuery, t, id, limit+1)
	} else if params.ScriptureBook != nil && *params.ScriptureBook != "" {
		var chapter int32 = 0
		if params.ScriptureChapter != nil {
			chapter = *params.ScriptureChapter
		}
		posts, err = s.repo.GetExplorePostsByScripture(ctx, *params.ScriptureBook, chapter, t, id, limit+1)
	} else {
		posts, err = s.repo.GetExplorePosts(ctx, t, id, limit+1)
	}

	if err != nil {
		return nil, err
	}

	var nextCursor string
	if len(posts) > int(limit) {
		last := posts[limit-1]
		nextCursor = encodeCursor(last.PublishedAt, last.ID)
		posts = posts[:limit]
	}
	
	if params.CategoryID != nil {
		return PaginatedExploreCategoryResponse{
			Posts:      posts,
			NextCursor: nextCursor,
		}, nil
	}

	return PaginatedExploreResponse{
		Posts:      posts,
		NextCursor: nextCursor,
	}, nil
}

func (s *Service) ListCategories(ctx context.Context) ([]generated.Category, error) {
	return s.repo.ListCategories(ctx)
}
