package bible

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strings"

	"github.com/google/uuid"
)

var (
	ErrNotFound = errors.New("not found")
)

type Repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) GetTranslations(ctx context.Context) ([]Translation, error) {
	query := `
		SELECT id, code, name, language, attribution_text, source, is_active, is_default
		FROM bible_translations
		WHERE is_active = true
		ORDER BY is_default DESC, name ASC
	`
	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var translations []Translation
	for rows.Next() {
		var t Translation
		if err := rows.Scan(&t.ID, &t.Code, &t.Name, &t.Language, &t.AttributionText, &t.Source, &t.IsActive, &t.IsDefault); err != nil {
			return nil, err
		}
		translations = append(translations, t)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return translations, nil
}

func (r *Repository) GetBooks(ctx context.Context, translationCode string) ([]Book, error) {
	if translationCode == "" {
		translationCode = "BSB"
	}

	query := `
		SELECT b.id, b.name, b.short_name, b.testament, b.book_order, b.chapter_count
		FROM bible_books b
		JOIN bible_translations t ON b.translation_id = t.id
		WHERE t.code = $1 AND t.is_active = true
		ORDER BY b.book_order ASC
	`
	rows, err := r.db.QueryContext(ctx, query, strings.ToUpper(translationCode))
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var books []Book
	for rows.Next() {
		var b Book
		if err := rows.Scan(&b.ID, &b.Name, &b.ShortName, &b.Testament, &b.BookOrder, &b.ChapterCount); err != nil {
			return nil, err
		}
		books = append(books, b)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return books, nil
}

func (r *Repository) GetChapter(ctx context.Context, translationCode, bookName string, chapter int) (*Chapter, error) {
	if translationCode == "" {
		translationCode = "BSB"
	}

	query := `
		SELECT b.name, v.chapter, v.verse, v.text
		FROM bible_verses v
		JOIN bible_books b ON v.book_id = b.id
		JOIN bible_translations t ON b.translation_id = t.id
		WHERE t.code = $1 AND (LOWER(b.name) = LOWER($2) OR LOWER(b.short_name) = LOWER($2)) AND v.chapter = $3
		ORDER BY v.verse ASC
	`
	rows, err := r.db.QueryContext(ctx, query, strings.ToUpper(translationCode), bookName, chapter)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var verses []Verse
	var resolvedBookName string

	for rows.Next() {
		var v Verse
		if err := rows.Scan(&resolvedBookName, &v.Chapter, &v.Verse, &v.Text); err != nil {
			return nil, err
		}
		verses = append(verses, v)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	if len(verses) == 0 {
		return nil, ErrNotFound
	}

	return &Chapter{
		Translation: strings.ToUpper(translationCode),
		Book:        resolvedBookName,
		Chapter:     chapter,
		Verses:      verses,
	}, nil
}

func (r *Repository) GetVerseRange(ctx context.Context, translationCode, bookName string, chapter, startVerse int, endVerse *int) (*VerseRangeResult, error) {
	if translationCode == "" {
		translationCode = "BSB"
	}

	end := startVerse
	if endVerse != nil && *endVerse >= startVerse {
		end = *endVerse
	}

	query := `
		SELECT b.name, v.chapter, v.verse, v.text
		FROM bible_verses v
		JOIN bible_books b ON v.book_id = b.id
		JOIN bible_translations t ON b.translation_id = t.id
		WHERE t.code = $1 
		  AND (LOWER(b.name) = LOWER($2) OR LOWER(b.short_name) = LOWER($2)) 
		  AND v.chapter = $3 
		  AND v.verse >= $4 
		  AND v.verse <= $5
		ORDER BY v.verse ASC
	`
	rows, err := r.db.QueryContext(ctx, query, strings.ToUpper(translationCode), bookName, chapter, startVerse, end)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var verses []Verse
	var resolvedBookName string

	for rows.Next() {
		var v Verse
		if err := rows.Scan(&resolvedBookName, &v.Chapter, &v.Verse, &v.Text); err != nil {
			return nil, err
		}
		verses = append(verses, v)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	if len(verses) == 0 {
		return nil, ErrNotFound
	}

	refStr := fmt.Sprintf("%s %d:%d", resolvedBookName, chapter, startVerse)
	if endVerse != nil && *endVerse > startVerse {
		refStr = fmt.Sprintf("%s %d:%d-%d", resolvedBookName, chapter, startVerse, *endVerse)
	}

	return &VerseRangeResult{
		Translation: strings.ToUpper(translationCode),
		Reference:   refStr,
		Verses:      verses,
	}, nil
}

func (r *Repository) Search(ctx context.Context, translationCode, searchQuery string, limit int) ([]SearchResultItem, error) {
	if translationCode == "" {
		translationCode = "BSB"
	}
	if limit <= 0 || limit > 100 {
		limit = 20
	}

	// Full-text search with fallback to ILIKE if plainquery yields 0 or formatting
	query := `
		SELECT b.name, v.chapter, v.verse, v.text
		FROM bible_verses v
		JOIN bible_books b ON v.book_id = b.id
		JOIN bible_translations t ON b.translation_id = t.id
		WHERE t.code = $1 
		  AND (
		    to_tsvector('english', v.text) @@ plainto_tsquery('english', $2)
		    OR v.text ILIKE '%' || $2 || '%'
		  )
		ORDER BY b.book_order ASC, v.chapter ASC, v.verse ASC
		LIMIT $3
	`
	rows, err := r.db.QueryContext(ctx, query, strings.ToUpper(translationCode), searchQuery, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []SearchResultItem
	for rows.Next() {
		var item SearchResultItem
		if err := rows.Scan(&item.Book, &item.Chapter, &item.Verse, &item.Text); err != nil {
			return nil, err
		}
		results = append(results, item)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return results, nil
}

func (r *Repository) SaveReadingPosition(ctx context.Context, userID uuid.UUID, translationCode, bookName string, chapter int) error {
	if translationCode == "" {
		translationCode = "BSB"
	}

	query := `
		INSERT INTO bible_reading_position (user_id, book_id, chapter, updated_at)
		SELECT $1, b.id, $4, now()
		FROM bible_books b
		JOIN bible_translations t ON b.translation_id = t.id
		WHERE t.code = $2 AND (LOWER(b.name) = LOWER($3) OR LOWER(b.short_name) = LOWER($3))
		ON CONFLICT (user_id) DO UPDATE
		SET book_id = EXCLUDED.book_id,
		    chapter = EXCLUDED.chapter,
		    updated_at = now()
	`
	res, err := r.db.ExecContext(ctx, query, userID, strings.ToUpper(translationCode), bookName, chapter)
	if err != nil {
		return err
	}
	rowsAffected, _ := res.RowsAffected()
	if rowsAffected == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *Repository) GetReadingPosition(ctx context.Context, userID uuid.UUID) (*ReadingPosition, error) {
	query := `
		SELECT b.name, p.chapter, p.updated_at
		FROM bible_reading_position p
		JOIN bible_books b ON p.book_id = b.id
		WHERE p.user_id = $1
	`
	var pos ReadingPosition
	err := r.db.QueryRowContext(ctx, query, userID).Scan(&pos.Book, &pos.Chapter, &pos.UpdatedAt)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	return &pos, nil
}
