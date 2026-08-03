package search

import (
	"context"

	"scribes-api/internal/db/generated"
)

type Service interface {
	SearchPosts(ctx context.Context, query string, limit, offset int32) ([]generated.SearchPostsHybridRow, error)
	SearchAuthors(ctx context.Context, query string, limit, offset int32) ([]generated.SearchAuthorsRow, error)
}

type service struct {
	repo     Repository
	provider EmbeddingProvider
}

func NewService(repo Repository, provider EmbeddingProvider) Service {
	return &service{
		repo:     repo,
		provider: provider,
	}
}

func (s *service) SearchPosts(ctx context.Context, query string, limit, offset int32) ([]generated.SearchPostsHybridRow, error) {
	// For semantic search, generate embedding for the search query
	// If query is empty, it shouldn't hit this, but just in case
	var vecString interface{} = nil
	if query != "" {
		vec, err := s.provider.GenerateEmbedding(ctx, query)
		if err == nil && len(vec) > 0 {
			vecString = formatVectorString(vec)
		}
	}

	return s.repo.SearchPostsHybrid(ctx, query, vecString, limit, offset)
}

func (s *service) SearchAuthors(ctx context.Context, query string, limit, offset int32) ([]generated.SearchAuthorsRow, error) {
	return s.repo.SearchAuthors(ctx, query, limit, offset)
}
