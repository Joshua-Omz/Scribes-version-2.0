package bible

import (
	"context"
	"fmt"
	"strconv"
	"strings"

	"github.com/google/uuid"
)

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) GetBooks(ctx context.Context, translationCode string) ([]Book, error) {
	return s.repo.GetBooks(ctx, translationCode)
}

func (s *Service) GetChapter(ctx context.Context, translationCode, book string, chapter int) (*Chapter, error) {
	cleanBook := s.normalizeBookName(book)
	return s.repo.GetChapter(ctx, translationCode, cleanBook, chapter)
}

func (s *Service) GetVerseRange(ctx context.Context, translationCode, book string, chapter int, verseRangeStr string) (*VerseRangeResult, error) {
	cleanBook := s.normalizeBookName(book)
	startVerse, endVerse, err := s.parseVerseRange(verseRangeStr)
	if err != nil {
		return nil, err
	}
	return s.repo.GetVerseRange(ctx, translationCode, cleanBook, chapter, startVerse, endVerse)
}

func (s *Service) Search(ctx context.Context, translationCode, query string, limit int) ([]SearchResultItem, error) {
	trimmed := strings.TrimSpace(query)
	if trimmed == "" {
		return []SearchResultItem{}, nil
	}
	return s.repo.Search(ctx, translationCode, trimmed, limit)
}

func (s *Service) SaveReadingPosition(ctx context.Context, userID uuid.UUID, translationCode, book string, chapter int) error {
	cleanBook := s.normalizeBookName(book)
	return s.repo.SaveReadingPosition(ctx, userID, translationCode, cleanBook, chapter)
}

func (s *Service) GetReadingPosition(ctx context.Context, userID uuid.UUID) (*ReadingPosition, error) {
	return s.repo.GetReadingPosition(ctx, userID)
}

func (s *Service) normalizeBookName(input string) string {
	cleaned := strings.TrimSpace(input)
	cleaned = strings.ReplaceAll(cleaned, "-", " ")
	cleaned = strings.ReplaceAll(cleaned, "_", " ")
	return cleaned
}

func (s *Service) parseVerseRange(input string) (int, *int, error) {
	trimmed := strings.TrimSpace(input)
	if trimmed == "" {
		return 0, nil, fmt.Errorf("empty verse range")
	}

	parts := strings.Split(trimmed, "-")
	start, err := strconv.Atoi(parts[0])
	if err != nil || start <= 0 {
		return 0, nil, fmt.Errorf("invalid start verse: %s", parts[0])
	}

	if len(parts) > 1 {
		end, err := strconv.Atoi(parts[1])
		if err != nil || end < start {
			return start, nil, nil
		}
		return start, &end, nil
	}

	return start, nil, nil
}
