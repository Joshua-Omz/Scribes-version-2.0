package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/google/uuid"
	_ "github.com/lib/pq"
)

type HelloAOBook struct {
	ID               string `json:"id"`
	TranslationID    string `json:"translationId"`
	Name             string `json:"name"`
	CommonName       string `json:"commonName"`
	Order            int    `json:"order"`
	NumberOfChapters int    `json:"numberOfChapters"`
}

type HelloAOBooksResponse struct {
	Translation struct {
		ID              string `json:"id"`
		Name            string `json:"name"`
		Language        string `json:"language"`
		AttributionText string `json:"attributionText"`
	} `json:"translation"`
	Books []HelloAOBook `json:"books"`
}

type HelloAOChapterResponse struct {
	Chapter struct {
		Number  int `json:"number"`
		Content []struct {
			Type    string `json:"type"`
			Number  int    `json:"number,omitempty"`
			Content []any  `json:"content,omitempty"`
		} `json:"content"`
	} `json:"chapter"`
}

func main() {
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgres://scribes:scribes_secret@localhost:5432/scribes?sslmode=disable"
	}

	db, err := sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatalf("Failed to open DB: %v", err)
	}
	defer db.Close()

	if err := db.Ping(); err != nil {
		log.Fatalf("Failed to ping DB: %v", err)
	}

	log.Println("Connected to PostgreSQL for Bible import...")

	client := &http.Client{Timeout: 30 * time.Second}

	// 1. Fetch books list from HelloAO
	resp, err := client.Get("https://bible.helloao.org/api/BSB/books.json")
	if err != nil {
		log.Fatalf("Failed to fetch books.json: %v", err)
	}
	defer resp.Body.Close()

	bodyBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Fatalf("Failed to read books response: %v", err)
	}

	var booksResp HelloAOBooksResponse
	if err := json.Unmarshal(bodyBytes, &booksResp); err != nil {
		log.Fatalf("Failed to parse books JSON: %v", err)
	}

	log.Printf("Fetched %d books metadata for BSB...", len(booksResp.Books))

	// 2. Insert or get translation
	var translationID uuid.UUID
	err = db.QueryRow(`
		INSERT INTO bible_translations (code, name, language, attribution_text, source, is_active, is_default)
		VALUES ('BSB', 'Berean Standard Bible', 'en', 'Berean Standard Bible, public domain', 'self_hosted', true, true)
		ON CONFLICT (code) DO UPDATE
		SET name = EXCLUDED.name, attribution_text = EXCLUDED.attribution_text
		RETURNING id
	`).Scan(&translationID)
	if err != nil {
		log.Fatalf("Failed to insert translation: %v", err)
	}

	// 3. Process books
	totalVerses := 0

	for _, b := range booksResp.Books {
		testament := "old"
		if b.Order >= 40 {
			testament = "new"
		}

		var bookID uuid.UUID
		err = db.QueryRow(`
			INSERT INTO bible_books (translation_id, name, short_name, testament, book_order, chapter_count)
			VALUES ($1, $2, $3, $4, $5, $6)
			ON CONFLICT (translation_id, name) DO UPDATE
			SET short_name = EXCLUDED.short_name, chapter_count = EXCLUDED.chapter_count
			RETURNING id
		`, translationID, b.Name, b.ID, testament, b.Order, b.NumberOfChapters).Scan(&bookID)
		if err != nil {
			log.Fatalf("Failed to insert book %s: %v", b.Name, err)
		}

		log.Printf("[%d/66] Importing %s (%d chapters)...", b.Order, b.Name, b.NumberOfChapters)

		for ch := 1; ch <= b.NumberOfChapters; ch++ {
			chapterURL := fmt.Sprintf("https://bible.helloao.org/api/BSB/%s/%d.json", b.ID, ch)
			chResp, err := client.Get(chapterURL)
			if err != nil {
				log.Printf("Error fetching %s chapter %d: %v", b.Name, ch, err)
				continue
			}

			chBytes, _ := io.ReadAll(chResp.Body)
			chResp.Body.Close()

			var chData HelloAOChapterResponse
			if err := json.Unmarshal(chBytes, &chData); err != nil {
				log.Printf("Error parsing %s chapter %d: %v", b.Name, ch, err)
				continue
			}

			// Extract verses
			type verseItem struct {
				verseNum int
				text     string
			}
			var versesInChapter []verseItem

			for _, item := range chData.Chapter.Content {
				if item.Type == "verse" && item.Number > 0 {
					var textParts []string
					for _, c := range item.Content {
						if str, ok := c.(string); ok {
							textParts = append(textParts, str)
						} else if m, ok := c.(map[string]any); ok {
							if txt, hasTxt := m["text"].(string); hasTxt {
								textParts = append(textParts, txt)
							}
						}
					}
					verseText := strings.TrimSpace(strings.Join(textParts, " "))
					if verseText != "" {
						versesInChapter = append(versesInChapter, verseItem{
							verseNum: item.Number,
							text:     verseText,
						})
					}
				}
			}

			// Batch insert verses for chapter
			if len(versesInChapter) > 0 {
				tx, err := db.Begin()
				if err != nil {
					log.Fatalf("Failed to begin tx: %v", err)
				}

				stmt, err := tx.Prepare(`
					INSERT INTO bible_verses (book_id, chapter, verse, text)
					VALUES ($1, $2, $3, $4)
					ON CONFLICT (book_id, chapter, verse) DO UPDATE
					SET text = EXCLUDED.text
				`)
				if err != nil {
					tx.Rollback()
					log.Fatalf("Failed to prepare stmt: %v", err)
				}

				for _, v := range versesInChapter {
					_, err = stmt.Exec(bookID, ch, v.verseNum, v.text)
					if err != nil {
						stmt.Close()
						tx.Rollback()
						log.Fatalf("Failed to insert verse %s %d:%d: %v", b.Name, ch, v.verseNum, err)
					}
					totalVerses++
				}

				stmt.Close()
				if err := tx.Commit(); err != nil {
					log.Fatalf("Failed to commit tx: %v", err)
				}
			}

			time.Sleep(20 * time.Millisecond) // Friendly rate limit
		}
	}

	log.Printf("BIBLE IMPORT COMPLETE! Successfully seeded 66 books and %d verses.", totalVerses)
}
