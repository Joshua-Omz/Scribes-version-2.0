package search

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
)

type EmbeddingProvider interface {
	GenerateEmbedding(ctx context.Context, text string) ([]float32, error)
}

type ProviderConfig struct {
	Type   string // "ollama" or "openai"
	URL    string
	APIKey string
	Model  string
}

func NewEmbeddingProvider() EmbeddingProvider {
	providerType := os.Getenv("EMBEDDING_PROVIDER")
	if providerType == "" {
		providerType = "ollama" // default to local ollama for dev
	}

	model := os.Getenv("EMBEDDING_MODEL")

	if providerType == "ollama" {
		url := os.Getenv("OLLAMA_URL")
		if url == "" {
			url = "http://localhost:11434"
		}
		if model == "" {
			model = "nomic-embed-text"
		}
		return &OllamaProvider{URL: url, Model: model}
	} else if providerType == "openai" {
		url := os.Getenv("OPENAI_URL")
		if url == "" {
			url = "https://api.openai.com/v1"
		}
		if model == "" {
			model = "text-embedding-3-small"
		}
		return &OpenAIProvider{URL: url, APIKey: os.Getenv("OPENAI_API_KEY"), Model: model}
	}

	return &NoOpProvider{}
}

// ── NoOp Provider ────────────────────────────────────────────────────────────

type NoOpProvider struct{}

func (n *NoOpProvider) GenerateEmbedding(ctx context.Context, text string) ([]float32, error) {
	// Return a zero vector of size 768 to satisfy db constraints if testing without AI
	return make([]float32, 768), nil
}

// ── Ollama Provider ──────────────────────────────────────────────────────────

type OllamaProvider struct {
	URL   string
	Model string
}

func (o *OllamaProvider) GenerateEmbedding(ctx context.Context, text string) ([]float32, error) {
	reqBody, _ := json.Marshal(map[string]string{
		"model":  o.Model,
		"prompt": text,
	})

	req, err := http.NewRequestWithContext(ctx, "POST", o.URL+"/api/embeddings", bytes.NewBuffer(reqBody))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("ollama error: status %d, body %s", resp.StatusCode, string(body))
	}

	var result struct {
		Embedding []float32 `json:"embedding"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, err
	}
	return result.Embedding, nil
}

// ── OpenAI Provider ──────────────────────────────────────────────────────────

type OpenAIProvider struct {
	URL    string
	APIKey string
	Model  string
}

func (o *OpenAIProvider) GenerateEmbedding(ctx context.Context, text string) ([]float32, error) {
	reqBody, _ := json.Marshal(map[string]any{
		"model": o.Model,
		"input": text,
	})

	req, err := http.NewRequestWithContext(ctx, "POST", o.URL+"/embeddings", bytes.NewBuffer(reqBody))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")
	if o.APIKey != "" {
		req.Header.Set("Authorization", "Bearer "+o.APIKey)
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("openai error: status %d, body %s", resp.StatusCode, string(body))
	}

	var result struct {
		Data []struct {
			Embedding []float32 `json:"embedding"`
		} `json:"data"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, err
	}
	if len(result.Data) == 0 {
		return nil, errors.New("no embedding returned")
	}
	return result.Data[0].Embedding, nil
}
