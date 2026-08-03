package quill

import (
	"testing"
)

func TestToMarkdown(t *testing.T) {
	deltaJSON := []byte(`{
		"ops": [
			{ "insert": "Hello " },
			{ "insert": "World", "attributes": { "bold": true } },
			{ "insert": "\n" },
			{ "insert": "This is a heading" },
			{ "insert": "\n", "attributes": { "header": 1 } },
			{ "insert": "List item" },
			{ "insert": "\n", "attributes": { "list": "bullet" } }
		]
	}`)

	expected := "Hello **World**\n# This is a heading\n* List item"
	result, err := ToMarkdown(deltaJSON)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if result != expected {
		t.Errorf("expected %q, got %q", expected, result)
	}
}

func TestToPlainText(t *testing.T) {
	deltaJSON := []byte(`{
		"ops": [
			{ "insert": "Hello " },
			{ "insert": "World", "attributes": { "bold": true } },
			{ "insert": "\n" }
		]
	}`)

	expected := "Hello World"
	result, err := ToPlainText(deltaJSON)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if result != expected {
		t.Errorf("expected %q, got %q", expected, result)
	}
}
