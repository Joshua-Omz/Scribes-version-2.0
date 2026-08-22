package bible

import (
	"time"

	"github.com/google/uuid"
)

type Translation struct {
	ID              uuid.UUID `json:"id"`
	Code            string    `json:"code"`
	Name            string    `json:"name"`
	Language        string    `json:"language"`
	AttributionText string    `json:"attribution_text"`
	Source          string    `json:"source"`
	IsActive        bool      `json:"is_active"`
	IsDefault       bool      `json:"is_default"`
}

type Book struct {
	ID           uuid.UUID `json:"id"`
	Name         string    `json:"name"`
	ShortName    string    `json:"short_name"`
	Testament    string    `json:"testament"`
	BookOrder    int       `json:"order"`
	ChapterCount int       `json:"chapter_count"`
}

type Verse struct {
	Book    string `json:"book,omitempty"`
	Chapter int    `json:"chapter"`
	Verse   int    `json:"verse"`
	Text    string `json:"text"`
}

type Chapter struct {
	Translation string  `json:"translation"`
	Book        string  `json:"book"`
	Chapter     int     `json:"chapter"`
	Verses      []Verse `json:"verses"`
}

type VerseRangeResult struct {
	Translation string  `json:"translation"`
	Reference   string  `json:"reference"`
	Verses      []Verse `json:"verses"`
}

type SearchResultItem struct {
	Book    string `json:"book"`
	Chapter int    `json:"chapter"`
	Verse   int    `json:"verse"`
	Text    string `json:"text"`
}

type SearchResponse struct {
	Translation string             `json:"translation"`
	Query       string             `json:"query"`
	Results     []SearchResultItem `json:"results"`
}

type ReadingPosition struct {
	Book      string    `json:"book"`
	Chapter   int       `json:"chapter"`
	UpdatedAt time.Time `json:"updated_at"`
}

type Reference struct {
	Book       string
	Chapter    int
	VerseStart int
	VerseEnd   *int
}
