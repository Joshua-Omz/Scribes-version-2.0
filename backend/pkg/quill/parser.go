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
	var delta Delta
	if err := json.Unmarshal(rawJSON, &delta); err != nil {
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

	for _, op := range delta.Ops {
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
	var delta Delta
	if err := json.Unmarshal(rawJSON, &delta); err != nil {
		return "", err
	}

	var sb strings.Builder

	for _, op := range delta.Ops {
		if text, ok := op.Insert.(string); ok {
			sb.WriteString(text)
		}
	}

	return strings.TrimSpace(sb.String()), nil
}
