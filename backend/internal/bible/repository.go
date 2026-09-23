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
		SELECT id, code, name, language, attribution_text, source, is_active, is_default, download_url, file_size_bytes, version
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
		if err := rows.Scan(&t.ID, &t.Code, &t.Name, &t.Language, &t.AttributionText, &t.Source, &t.IsActive, &t.IsDefault, &t.DownloadURL, &t.FileSizeBytes, &t.Version); err != nil {
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

func (r *Repository) SaveReadingPosition(ctx context.Context, userID uuid.UUID, translationCode, bookCode string, chapter, verse int) error {
	if translationCode == "" {
		translationCode = "BSB"
	}
	if verse <= 0 {
		verse = 1
	}

	query := `
		INSERT INTO bible_reading_positions (user_id, book_code, chapter, verse, preferred_translation, updated_at)
		VALUES ($1, $2, $3, $4, $5, now())
		ON CONFLICT (user_id) DO UPDATE
		SET book_code = EXCLUDED.book_code,
		    chapter = EXCLUDED.chapter,
		    verse = EXCLUDED.verse,
		    preferred_translation = EXCLUDED.preferred_translation,
		    updated_at = now()
	`
	_, err := r.db.ExecContext(ctx, query, userID, strings.ToUpper(bookCode), chapter, verse, strings.ToUpper(translationCode))
	return err
}

func (r *Repository) IngestTranslation(ctx context.Context, input BibleInput) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("failed to start tx: %w", err)
	}
	defer tx.Rollback()

	// 1. Insert Translation
	var translationID uuid.UUID
	err = tx.QueryRowContext(ctx, `
		INSERT INTO bible_translations (code, name, language, attribution_text, source, is_active, is_default)
		VALUES ($1, $2, $3, $4, 'self_hosted', true, false)
		ON CONFLICT (code) DO UPDATE 
		SET name = EXCLUDED.name, attribution_text = EXCLUDED.attribution_text
		RETURNING id
	`, input.Translation.Code, input.Translation.Name, input.Translation.Language, input.Translation.AttributionText).Scan(&translationID)
	if err != nil {
		return fmt.Errorf("failed to insert translation: %w", err)
	}

	// 2. Insert Books and Verses
	for bIdx, book := range input.Books {
		var bookID uuid.UUID
		chapterCount := len(book.Chapters)
		err = tx.QueryRowContext(ctx, `
			INSERT INTO bible_books (translation_id, name, short_name, testament, book_order, chapter_count)
			VALUES ($1, $2, $3, $4, $5, $6)
			ON CONFLICT (translation_id, name) DO UPDATE
			SET short_name = EXCLUDED.short_name, chapter_count = EXCLUDED.chapter_count
			RETURNING id
		`, translationID, book.Name, book.ShortName, book.Testament, bIdx+1, chapterCount).Scan(&bookID)
		if err != nil {
			return fmt.Errorf("failed to insert book %s: %w", book.Name, err)
		}

		// Delete existing verses for this book to avoid duplicates on re-run
		_, err = tx.ExecContext(ctx, `DELETE FROM bible_verses WHERE book_id = $1`, bookID)
		if err != nil {
			return fmt.Errorf("failed to clear old verses for book %s: %w", book.Name, err)
		}

		// Insert verses in batches
		var valueStrings []string
		var valueArgs []interface{}
		argId := 1

		for _, chapter := range book.Chapters {
			for _, verse := range chapter.Verses {
				valueStrings = append(valueStrings, fmt.Sprintf("($%d, $%d, $%d, $%d)", argId, argId+1, argId+2, argId+3))
				valueArgs = append(valueArgs, bookID, chapter.Chapter, verse.Verse, verse.Text)
				argId += 4

				if len(valueStrings) >= 1000 {
					stmt := fmt.Sprintf("INSERT INTO bible_verses (book_id, chapter, verse, text) VALUES %s", strings.Join(valueStrings, ","))
					_, err := tx.ExecContext(ctx, stmt, valueArgs...)
					if err != nil {
						return fmt.Errorf("failed to insert verses batch: %w", err)
					}
					valueStrings = []string{}
					valueArgs = []interface{}{}
					argId = 1
				}
			}
		}

		// Insert remaining
		if len(valueStrings) > 0 {
			stmt := fmt.Sprintf("INSERT INTO bible_verses (book_id, chapter, verse, text) VALUES %s", strings.Join(valueStrings, ","))
			_, err := tx.ExecContext(ctx, stmt, valueArgs...)
			if err != nil {
				return fmt.Errorf("failed to insert verses batch: %w", err)
			}
		}
	}

	if err := tx.Commit(); err != nil {
		return fmt.Errorf("failed to commit tx: %w", err)
	}

	return nil
}

func (r *Repository) GetReadingPosition(ctx context.Context, userID uuid.UUID) (*ReadingPosition, error) {
	query := `
		SELECT book_code, chapter, verse, preferred_translation, updated_at
		FROM bible_reading_positions
		WHERE user_id = $1
	`
	var pos ReadingPosition
	err := r.db.QueryRowContext(ctx, query, userID).Scan(&pos.BookCode, &pos.Chapter, &pos.Verse, &pos.PreferredTranslation, &pos.UpdatedAt)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	return &pos, nil
}
