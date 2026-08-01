package search

import (
	"context"
	"fmt"
	"log"
	"strings"

	"github.com/google/uuid"
)

type EmbeddingWorker struct {
	provider EmbeddingProvider
	repo     Repository
	jobs     chan EmbeddingJob
}

type EmbeddingJob struct {
	PostID  uuid.UUID
	Content string
}

func NewEmbeddingWorker(provider EmbeddingProvider, repo Repository) *EmbeddingWorker {
	return &EmbeddingWorker{
		provider: provider,
		repo:     repo,
		jobs:     make(chan EmbeddingJob, 1000), // Buffer up to 1000 jobs
	}
}

func (w *EmbeddingWorker) Start(ctx context.Context) {
	log.Println("EmbeddingWorker started")
	for {
		select {
		case <-ctx.Done():
			log.Println("EmbeddingWorker shutting down")
			return
		case job := <-w.jobs:
			w.processJob(ctx, job)
		}
	}
}

func (w *EmbeddingWorker) Enqueue(postID uuid.UUID, content string) {
	select {
	case w.jobs <- EmbeddingJob{PostID: postID, Content: content}:
		// enqueued
	default:
		log.Printf("EmbeddingWorker queue full, dropped job for post %s", postID)
	}
}

func (w *EmbeddingWorker) processJob(ctx context.Context, job EmbeddingJob) {
	// 1. Generate embedding using provider
	vector, err := w.provider.GenerateEmbedding(ctx, job.Content)
	if err != nil {
		log.Printf("Failed to generate embedding for post %s: %v", job.PostID, err)
		return
	}

	// 3. Update the database
	// Convert pgvector.Vector to string format "[x, y, z]" for sqlc if necessary,
	// or let the driver handle it if pgvector is registered.
	// Since sqlc generated `interface{}`, we can just pass the string representation.
	vecString := formatVectorString(vector)

	if err := w.repo.UpdatePostEmbedding(ctx, job.PostID, vecString); err != nil {
		log.Printf("Failed to save embedding for post %s: %v", job.PostID, err)
	} else {
		log.Printf("Successfully generated and saved embedding for post %s", job.PostID)
	}
}

func formatVectorString(vec []float32) string {
	strs := make([]string, len(vec))
	for i, v := range vec {
		strs[i] = fmt.Sprintf("%f", v)
	}
	return "[" + strings.Join(strs, ",") + "]"
}
