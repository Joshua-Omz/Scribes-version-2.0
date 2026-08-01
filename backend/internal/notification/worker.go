package notification

import (
	"context"
	"log/slog"
	"time"

	"scribes-api/internal/db/generated"
)

type Worker struct {
	channel    chan Event
	repo       *Repository
	ticker     *time.Ticker
	OnRealtime func(generated.Notification)
}

func NewWorker(repo *Repository) *Worker {
	return &Worker{
		channel: make(chan Event, 256),
		repo:    repo,
		ticker:  time.NewTicker(15 * time.Minute),
	}
}

func (w *Worker) Start(ctx context.Context) {
	slog.Info("Starting notification worker")
	
	// Ensure the ticker is stopped when worker exits
	defer w.ticker.Stop()

	for {
		select {
		case event := <-w.channel:
			if event.IsRealtime {
				w.sendRealtime(ctx, event)
			} else {
				w.persistBatch(ctx, event)
			}
		case <-w.ticker.C:
			w.flushBatch(ctx)
		case <-ctx.Done():
			slog.Info("Shutting down notification worker, draining remaining batch")
			w.flushBatch(context.Background()) // use background context to finish write
			return
		}
	}
}

func (w *Worker) Enqueue(event Event) {
	select {
	case w.channel <- event:
		// Enqueued successfully
	default:
		slog.Warn("Notification worker channel full, dropping event", "event", event)
	}
}

func (w *Worker) sendRealtime(ctx context.Context, event Event) {
	n, err := w.repo.Insert(ctx, event)
	if err != nil {
		slog.Error("Failed to insert realtime notification", "error", err, "event", event)
		return
	}
	if w.OnRealtime != nil {
		w.OnRealtime(n)
	}
}

func (w *Worker) persistBatch(ctx context.Context, event Event) {
	_, err := w.repo.Insert(ctx, event)
	if err != nil {
		slog.Error("Failed to insert batched notification", "error", err, "event", event)
	}
}

func (w *Worker) flushBatch(ctx context.Context) {
	err := w.repo.FlushBatch(ctx)
	if err != nil {
		slog.Error("Failed to flush batched notifications", "error", err)
	}
}
