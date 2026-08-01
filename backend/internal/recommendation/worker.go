package recommendation

import (
	"context"
	"log"
	"time"
)

// Use a consistent lock ID for the engagement refresh across all instances
const engagementRefreshLockID = 1001

type EngagementWorker struct {
	repo     Repository
	interval time.Duration
}

func NewEngagementWorker(repo Repository, intervalStr string) *EngagementWorker {
	interval, err := time.ParseDuration(intervalStr)
	if err != nil {
		log.Printf("Invalid engagement refresh interval '%s', defaulting to 1h", intervalStr)
		interval = time.Hour
	}
	return &EngagementWorker{
		repo:     repo,
		interval: interval,
	}
}

func (w *EngagementWorker) Start(ctx context.Context) {
	log.Printf("EngagementWorker started with interval %s", w.interval)

	// Initial run
	w.refreshScores(ctx)

	ticker := time.NewTicker(w.interval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			log.Println("EngagementWorker shutting down")
			return
		case <-ticker.C:
			w.refreshScores(ctx)
		}
	}
}

func (w *EngagementWorker) refreshScores(ctx context.Context) {
	// 1. Try to acquire advisory lock
	// This ensures that if multiple instances of the backend are running in production,
	// only one instance attempts to refresh the materialized view at a time.
	acquired, err := w.repo.TryAdvisoryLock(ctx, engagementRefreshLockID)
	if err != nil {
		log.Printf("EngagementWorker: Failed to check advisory lock: %v", err)
		return
	}

	if !acquired {
		// Another instance is already refreshing it. Skip this tick.
		log.Println("EngagementWorker: Another instance holds the lock, skipping refresh.")
		return
	}

	// 2. Ensure lock is released when done
	defer func() {
		if err := w.repo.AdvisoryUnlock(ctx, engagementRefreshLockID); err != nil {
			log.Printf("EngagementWorker: Failed to release advisory lock: %v", err)
		}
	}()

	log.Println("EngagementWorker: Starting concurrent refresh of post_engagement_scores...")

	// 3. Refresh materialized view concurrently
	if err := w.repo.RefreshEngagementScores(ctx); err != nil {
		log.Printf("EngagementWorker: Failed to refresh engagement scores: %v", err)
		return
	}

	log.Println("EngagementWorker: Successfully refreshed post_engagement_scores")
}
