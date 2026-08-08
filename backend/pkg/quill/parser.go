package quill

import (
	"encoding/json"
	"strings"
)

// Delta represents a Quill Delta document.
type Delta struct {
	Ops []Op `json:"ops"`
}

// Op represents a single Quill operation.
type Op struct {
	Insert     interface{}            `json:"insert"`
	Attributes map[string]interface{} `json:"attributes,omitempty"`
}

// lineSegment represents a chunk of text within a line.
type lineSegment struct {
	text   string
	bold   bool
	italic bool
	code   bool
}

// ToMarkdown converts a Quill Delta to a Markdown string.
func ToMarkdown(rawJSON []byte) (string, error) {
	ops, err := parseOps(rawJSON)
	if err != nil {
		return "", err
	}

	var sb strings.Builder
	var currentLine []lineSegment

	flushLine := func(headerLevel int, listType string) {
		if headerLevel > 0 {
			sb.WriteString(strings.Repeat("#", headerLevel) + " ")
		} else if listType == "bullet" {
			sb.WriteString("* ")
		} else if listType == "ordered" {
			sb.WriteString("1. ") // Simplify ordered list
		}

		for _, seg := range currentLine {
			if seg.code {
				sb.WriteString("`" + seg.text + "`")
			} else if seg.bold && seg.italic {
				sb.WriteString("***" + seg.text + "***")
			} else if seg.bold {
				sb.WriteString("**" + seg.text + "**")
			} else if seg.italic {
				sb.WriteString("*" + seg.text + "*")
			} else {
				sb.WriteString(seg.text)
			}
		}
		sb.WriteString("\n")
		currentLine = nil
	}

	for _, op := range ops {
		text, ok := op.Insert.(string)
		if !ok {
			continue // skip embeds
		}

		lines := strings.Split(text, "\n")
		for i, line := range lines {
			if i > 0 {
				// We hit a newline. Check if the newline has block attributes.
				headerLvl := 0
				listType := ""
				if op.Attributes != nil {
					if h, ok := op.Attributes["header"].(float64); ok {
						headerLvl = int(h)
					}
					if l, ok := op.Attributes["list"].(string); ok {
						listType = l
					}
				}
				flushLine(headerLvl, listType)
			}

			if line != "" {
				seg := lineSegment{text: line}
				if op.Attributes != nil {
					if b, ok := op.Attributes["bold"].(bool); ok && b {
						seg.bold = true
					}
					if it, ok := op.Attributes["italic"].(bool); ok && it {
						seg.italic = true
					}
					if c, ok := op.Attributes["code"].(bool); ok && c {
						seg.code = true
					}
				}
				currentLine = append(currentLine, seg)
			}
		}
	}

	if len(currentLine) > 0 {
		flushLine(0, "")
	}

	return strings.TrimSpace(sb.String()), nil
}

// ToPlainText converts a Quill Delta to a Plain Text string.
func ToPlainText(rawJSON []byte) (string, error) {
	ops, err := parseOps(rawJSON)
	if err != nil {
		return "", err
	}

	var sb strings.Builder

	for _, op := range ops {
		if text, ok := op.Insert.(string); ok {
			sb.WriteString(text)
		}
	}

	return strings.TrimSpace(sb.String()), nil
}

func parseOps(rawJSON []byte) ([]Op, error) {
	// 0. Handle double-encoded JSON strings (common when frontend stringifies JSON payload)
	var str string
	if err := json.Unmarshal(rawJSON, &str); err == nil {
		rawJSON = []byte(str)
	}

	// 1. Try array format (Flutter Quill)
	var ops []Op
	if err := json.Unmarshal(rawJSON, &ops); err == nil && len(ops) > 0 {
		return ops, nil
	}

	// 2. Try object format with "ops" (Standard Quill format)
	var delta Delta
	if err := json.Unmarshal(rawJSON, &delta); err == nil && len(delta.Ops) > 0 {
		return delta.Ops, nil
	}

	// 3. Try fallback format (create_post.py test script)
	var dummy struct {
		Title string `json:"title"`
		Body  string `json:"body"`
	}
	if err := json.Unmarshal(rawJSON, &dummy); err == nil && (dummy.Title != "" || dummy.Body != "") {
		var dummyOps []Op
		if dummy.Title != "" {
			dummyOps = append(dummyOps, Op{
				Insert: dummy.Title + "\n",
				Attributes: map[string]interface{}{"header": float64(1)},
			})
		}
		if dummy.Body != "" {
			dummyOps = append(dummyOps, Op{Insert: dummy.Body + "\n"})
		}
		return dummyOps, nil
	}

	// If all fail or it is empty, return empty ops
	return nil, nil
}
