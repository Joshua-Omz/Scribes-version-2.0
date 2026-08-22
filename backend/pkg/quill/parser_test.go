package quill

import (
	"testing"
)

func TestToMarkdown(t *testing.T) {
	tests := []struct {
		name     string
		input    []byte
		expected string
	}{
		{
			name: "standard quill delta object",
			input: []byte(`{
				"ops": [
					{ "insert": "Hello " },
					{ "insert": "World", "attributes": { "bold": true } },
					{ "insert": "\n" },
					{ "insert": "This is a heading" },
					{ "insert": "\n", "attributes": { "header": 1 } },
					{ "insert": "List item" },
					{ "insert": "\n", "attributes": { "list": "bullet" } }
				]
			}`),
			expected: "Hello **World**\n# This is a heading\n* List item",
		},
		{
			name: "scribes envelope with body array (Flutter Quill format)",
			input: []byte(`{
				"title": "My Note Title",
				"excerpt": "My Note Title",
				"body": [
					{ "insert": "First paragraph with " },
					{ "insert": "bold text", "attributes": { "bold": true } },
					{ "insert": ".\n" },
					{ "insert": "Second paragraph.\n" }
				]
			}`),
			expected: "# My Note Title\nFirst paragraph with **bold text**.\nSecond paragraph.",
		},
		{
			name: "scribes envelope without title",
			input: []byte(`{
				"body": [
					{ "insert": "Just content.\n" }
				]
			}`),
			expected: "Just content.",
		},
		{
			name: "bare array ops",
			input: []byte(`[
				{ "insert": "Bare array line.\n" }
			]`),
			expected: "Bare array line.",
		},
		{
			name: "legacy plain string body in envelope",
			input: []byte(`{
				"title": "Legacy Title",
				"body": "Legacy plain string body."
			}`),
			expected: "# Legacy Title\nLegacy plain string body.",
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			result, err := ToMarkdown(tc.input)
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if result != tc.expected {
				t.Errorf("expected %q, got %q", tc.expected, result)
			}
		})
	}
}

func TestToPlainText(t *testing.T) {
	tests := []struct {
		name     string
		input    []byte
		expected string
	}{
		{
			name: "standard delta object",
			input: []byte(`{
				"ops": [
					{ "insert": "Hello " },
					{ "insert": "World", "attributes": { "bold": true } },
					{ "insert": "\n" }
				]
			}`),
			expected: "Hello World",
		},
		{
			name: "scribes envelope with body array",
			input: []byte(`{
				"title": "Envelope Title",
				"body": [
					{ "insert": "Hello " },
					{ "insert": "World\n" }
				]
			}`),
			expected: "Envelope Title\nHello World",
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			result, err := ToPlainText(tc.input)
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if result != tc.expected {
				t.Errorf("expected %q, got %q", tc.expected, result)
			}
		})
	}
}
