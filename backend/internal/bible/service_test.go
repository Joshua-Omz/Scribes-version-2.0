package bible

import (
	"context"
	"testing"
)

func TestParseVerseRange(t *testing.T) {
	svc := NewService(nil)

	tests := []struct {
		input     string
		expectedS int
		expectedE *int
		expectErr bool
	}{
		{"1-3", 1, intPtr(3), false},
		{"16", 16, nil, false},
		{"16-16", 16, intPtr(16), false},
		{"28-30", 28, intPtr(30), false},
		{"", 0, nil, true},
		{"invalid", 0, nil, true},
	}

	for _, tt := range tests {
		s, e, err := svc.parseVerseRange(tt.input)
		if tt.expectErr && err == nil {
			t.Errorf("expected error for %q, got nil", tt.input)
		}
		if !tt.expectErr && err != nil {
			t.Errorf("unexpected error for %q: %v", tt.input, err)
		}
		if s != tt.expectedS {
			t.Errorf("expected start %d, got %d for %q", tt.expectedS, s, tt.input)
		}
		if (e == nil && tt.expectedE != nil) || (e != nil && tt.expectedE == nil) || (e != nil && tt.expectedE != nil && *e != *tt.expectedE) {
			t.Errorf("expected end %v, got %v for %q", tt.expectedE, e, tt.input)
		}
	}
}

func TestNormalizeBookName(t *testing.T) {
	svc := NewService(nil)

	tests := []struct {
		input    string
		expected string
	}{
		{"1-corinthians", "1 corinthians"},
		{"song_of_solomon", "song of solomon"},
		{"  Genesis  ", "Genesis"},
	}

	for _, tt := range tests {
		res := svc.normalizeBookName(tt.input)
		if res != tt.expected {
			t.Errorf("expected %q, got %q", tt.expected, res)
		}
	}
}

func TestSearchValidation(t *testing.T) {
	svc := NewService(nil)
	res, err := svc.Search(context.Background(), "BSB", "   ", 20)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(res) != 0 {
		t.Fatalf("expected 0 results for empty query, got %d", len(res))
	}
}

func intPtr(i int) *int {
	return &i
}
