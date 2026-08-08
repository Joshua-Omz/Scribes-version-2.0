package search

import (
	"context"
	"database/sql"

	"github.com/google/uuid"
	"scribes-api/internal/db/generated"
)

type Repository interface {
	SearchPostsHybrid(ctx context.Context, keywordQuery string, semanticVector interface{}, limit, offset int32, scriptureBook *string, scriptureChapter *int32) ([]generated.SearchPostsHybridRow, error)
	SearchAuthors(ctx context.Context, query string, limit, offset int32) ([]generated.SearchAuthorsRow, error)
	UpdatePostEmbedding(ctx context.Context, postID uuid.UUID, embedding interface{}) error
}

type repository struct {
	db  *generated.Queries
	raw *sql.DB
}

func NewRepository(db *generated.Queries, raw *sql.DB) Repository {
	return &repository{db: db, raw: raw}
}

func (r *repository) SearchPostsHybrid(ctx context.Context, keywordQuery string, semanticVector interface{}, limit, offset int32, scriptureBook *string, scriptureChapter *int32) ([]generated.SearchPostsHybridRow, error) {
	var book sql.NullString
	if scriptureBook != nil && *scriptureBook != "" {
		book = sql.NullString{String: *scriptureBook, Valid: true}
	}
	
	var chapter sql.NullInt32
	if scriptureChapter != nil && *scriptureChapter > 0 {
		chapter = sql.NullInt32{Int32: *scriptureChapter, Valid: true}
	}

	return r.db.SearchPostsHybrid(ctx, generated.SearchPostsHybridParams{
		WebsearchToTsquery: keywordQuery,
		Column2:            semanticVector,
		Limit:              limit,
		Offset:             offset,
		ScriptureBook:      book,
		ScriptureChapter:   chapter,
	})
}

func (r *repository) SearchAuthors(ctx context.Context, query string, limit, offset int32) ([]generated.SearchAuthorsRow, error) {
	return r.db.SearchAuthors(ctx, generated.SearchAuthorsParams{
		Column1: sql.NullString{String: query, Valid: true},
		Limit:   limit,
		Offset:  offset,
	})
}

func (r *repository) UpdatePostEmbedding(ctx context.Context, postID uuid.UUID, embedding interface{}) error {
	return r.db.UpdatePostEmbedding(ctx, generated.UpdatePostEmbeddingParams{
		Embedding: embedding,
		ID:        postID,
	})
}
