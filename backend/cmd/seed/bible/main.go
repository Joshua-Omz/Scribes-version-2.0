package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"strings"

	"github.com/google/uuid"
	_ "github.com/lib/pq"
)

type VerseInput struct {
	Verse int    `json:"verse"`
	Text  string `json:"text"`
}

type ChapterInput struct {
	Chapter int          `json:"chapter"`
	Verses  []VerseInput `json:"verses"`
}

type BookInput struct {
	Name      string         `json:"name"`
	ShortName string         `json:"short_name"`
	Testament string         `json:"testament"`
	Chapters  []ChapterInput `json:"chapters"`
}

type TranslationInput struct {
	Code            string `json:"code"`
	Name            string `json:"name"`
	Language        string `json:"language"`
	AttributionText string `json:"attribution_text"`
}

type BibleInput struct {
	Translation TranslationInput `json:"translation"`
	Books       []BookInput      `json:"books"`
}

func main() {
	filePtr := flag.String("file", "", "Path to the bible JSON file")
	flag.Parse()

	if *filePtr == "" {
		log.Fatal("Please provide a path to the JSON file using -file")
	}

	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		log.Fatal("DATABASE_URL is not set")
	}

	db, err := sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatalf("Failed to connect to db: %v", err)
	}
	defer db.Close()

	data, err := ioutil.ReadFile(*filePtr)
	if err != nil {
		log.Fatalf("Failed to read file: %v", err)
	}

	var bible BibleInput
	if err := json.Unmarshal(data, &bible); err != nil {
		log.Fatalf("Failed to parse JSON: %v", err)
	}

	ctx := context.Background()
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		log.Fatalf("Failed to start tx: %v", err)
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
	`, bible.Translation.Code, bible.Translation.Name, bible.Translation.Language, bible.Translation.AttributionText).Scan(&translationID)

	if err != nil {
		log.Fatalf("Failed to insert translation: %v", err)
	}
	log.Printf("Inserted/Updated translation: %s (ID: %s)", bible.Translation.Code, translationID)

	// 2. Insert Books and Verses
	for bIdx, book := range bible.Books {
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
			log.Fatalf("Failed to insert book %s: %v", book.Name, err)
		}

		// Delete existing verses for this book to avoid duplicates on re-run
		_, err = tx.ExecContext(ctx, `DELETE FROM bible_verses WHERE book_id = $1`, bookID)
		if err != nil {
			log.Fatalf("Failed to clear old verses for book %s: %v", book.Name, err)
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
						log.Fatalf("Failed to insert verses batch: %v", err)
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
				log.Fatalf("Failed to insert verses batch: %v", err)
			}
		}

		log.Printf("Inserted book: %s", book.Name)
	}

	if err := tx.Commit(); err != nil {
		log.Fatalf("Failed to commit tx: %v", err)
	}

	log.Println("Bible ingestion complete!")
}
