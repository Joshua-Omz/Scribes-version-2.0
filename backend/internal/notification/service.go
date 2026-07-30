package notification

import (
	"context"
	"fmt"
	"time"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

type Service struct {
	repo   *Repository
	worker *Worker
}

func NewService(repo *Repository, worker *Worker) *Service {
	return &Service{
		repo:   repo,
		worker: worker,
	}
}

func (s *Service) Enqueue(event Event) {
	s.worker.Enqueue(event)
}

func (s *Service) GetForUser(ctx context.Context, userID uuid.UUID) ([]NotificationGroup, error) {
	rows, err := s.repo.ListAllByUser(ctx, userID)
	if err != nil {
		return nil, err
	}

	return s.groupNotifications(rows), nil
}

func (s *Service) MarkAllRead(ctx context.Context, userID uuid.UUID) error {
	return s.repo.MarkAllRead(ctx, userID)
}

func (s *Service) HasUnread(ctx context.Context, userID uuid.UUID) (bool, error) {
	return s.repo.HasUnread(ctx, userID)
}

// Grouping logic based on contract:
// Grouping rule: Notifications of the same type and ref_id created within a 24-hour window 
// by different actors are collapsed into a single NotificationGroup. 
// The most recent actor is named, the count includes all actors in the window.
func (s *Service) groupNotifications(rows []generated.ListAllByUserRow) []NotificationGroup {
	var groups []NotificationGroup
	
	// Fast path for empty rows
	if len(rows) == 0 {
		return groups
	}

	// We process rows which are ordered by created_at DESC from the DB.
	// For each row, check if it fits into the last created group.
	// A simple approach: track groups by a key (type + ref_id + 24h window).
	
	type groupKey struct {
		Type  NotifType
		RefID uuid.UUID
		// To bucket by 24h, we could use the day the notification was created, 
		// but since they are ordered DESC, we can just collapse adjacent ones 
		// or maintain a list of active groups and check if it's within 24h of the group's CreatedAt.
	}
	
	// A more robust way to group that handles non-adjacent items is a map, 
	// but order must be preserved.
	// Let's use a slice and just scan the recent groups.
	
	for _, row := range rows {
		ntype := FromDBNotifType(row.Type)
		
		// Find if there's a matching group within 24h
		foundGroup := false
		for i := range groups {
			g := &groups[i]
			if g.Type == ntype && g.RefID == row.RefID {
				// Check 24h window
				diff := g.CreatedAt.Sub(row.CreatedAt)
				if diff < 0 {
					diff = -diff
				}
				if diff <= 24*time.Hour {
					// Add to this group
					g.Count++
					g.IDs = append(g.IDs, row.ID)
					// Don't change body/actor since the group has the most recent one (DESC order)
					foundGroup = true
					break
				}
			}
		}
		
		if !foundGroup {
			// Create a new group
			// We compute the body AFTER counting, so we just store the most recent actor handle for now.
			
			groups = append(groups, NotificationGroup{
				ID:         row.ID,
				IDs:        []uuid.UUID{row.ID},
				Type:       ntype,
				IsRealtime: row.IsRealtime,
				IsRead:     row.IsRead,
				RefID:      row.RefID,
				Count:      1,
				CreatedAt:  row.CreatedAt,
				// Storing ActorHandle temporarily in Body to generate later
				Body:       row.ActorHandle.String, 
			})
		}
	}
	
	// Generate final bodies
	for i := range groups {
		g := &groups[i]
		actorHandle := g.Body // We stored it here temporarily
		if actorHandle == "" {
			actorHandle = "Someone"
		}
		g.Body = s.generateBody(g.Type, actorHandle, g.Count)
	}

	return groups
}

func (s *Service) generateBody(ntype NotifType, actor string, count int) string {
	// Post title is not in the DB row directly per our current schema, 
	// the contract shows 'your post'. For v1, we use generic text if title isn't available.
	switch ntype {
	case NotifTypeMention:
		return fmt.Sprintf("%s mentioned you in a response", actor)
	case NotifTypeReaction:
		if count > 1 {
			return fmt.Sprintf("%s and %d others reacted to your post", actor, count-1)
		}
		return fmt.Sprintf("%s reacted to your post", actor)
	case NotifTypeComment:
		if count > 1 {
			return fmt.Sprintf("%s and %d others commented on your post", actor, count-1)
		}
		return fmt.Sprintf("%s commented on your post", actor)
	case NotifTypeFollow:
		return fmt.Sprintf("%s started following you", actor)
	case NotifTypeAdminAlert:
		return "An admin has reviewed content you reported"
	default:
		return "You have a new notification"
	}
}

func (s *Service) ClearAll(ctx context.Context, userID uuid.UUID) error {
	return s.repo.ClearAll(ctx, userID)
}

func (s *Service) DeleteBulk(ctx context.Context, userID uuid.UUID, ids []uuid.UUID) error {
	return s.repo.DeleteBulk(ctx, userID, ids)
}

func (s *Service) MarkBulkRead(ctx context.Context, userID uuid.UUID, ids []uuid.UUID) error {
	return s.repo.MarkBulkRead(ctx, userID, ids)
}
