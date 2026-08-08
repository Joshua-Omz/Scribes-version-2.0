package notification

import (
	"context"
	"fmt"
	"sync"
	"time"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

type Service struct {
	repo       *Repository
	worker     *Worker
	clients    map[uuid.UUID]map[chan Notification]bool
	clientsMux sync.RWMutex
}

func NewService(repo *Repository, worker *Worker) *Service {
	s := &Service{
		repo:    repo,
		worker:  worker,
		clients: make(map[uuid.UUID]map[chan Notification]bool),
	}
	s.worker.OnRealtime = func(n generated.Notification) {
		// Map generated.Notification to domain Notification
		domainNotif := Notification{
			ID:         n.ID,
			Type:       FromDBNotifType(n.Type),
			IsRealtime: n.IsRealtime,
			IsRead:     n.IsRead,
			RefID:      n.RefID,
			CreatedAt:  n.CreatedAt,
			// Body, ActorHandle, ActorAvatar would need to be enriched if needed,
			// but for realtime direct_message we might just need the basic info or generate it.
		}

		// In a real app we would call generateBody(ctx, &domainNotif, event.ActorID).
		// For now we just broadcast what we have.
		s.Broadcast(n.RecipientID, domainNotif)
	}
	return s
}

// ── Real-time Pub/Sub (SSE) ────────────────────

func (s *Service) Subscribe(userID uuid.UUID) chan Notification {
	s.clientsMux.Lock()
	defer s.clientsMux.Unlock()

	ch := make(chan Notification, 20)
	if s.clients[userID] == nil {
		s.clients[userID] = make(map[chan Notification]bool)
	}
	s.clients[userID][ch] = true
	return ch
}

func (s *Service) Unsubscribe(userID uuid.UUID, ch chan Notification) {
	s.clientsMux.Lock()
	defer s.clientsMux.Unlock()

	if subs, ok := s.clients[userID]; ok {
		delete(subs, ch)
		// Do NOT close(ch) here. Closing a channel that a concurrent Broadcast
		// might still reference causes a "send on closed channel" panic. The GC
		// will reclaim the channel once no goroutine holds a reference to it.
		if len(subs) == 0 {
			delete(s.clients, userID)
		}
	}
}

func (s *Service) Broadcast(userID uuid.UUID, notif Notification) {
	s.clientsMux.RLock()
	defer s.clientsMux.RUnlock()

	if subs, ok := s.clients[userID]; ok {
		for ch := range subs {
			select {
			case ch <- notif:
			default:
				// Client cannot keep up, drop. They can fetch via REST.
			}
		}
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
	// Fast path for empty rows
	if len(rows) == 0 {
		return []NotificationGroup{}
	}

	// Internal helper struct that carries the actor handle separately
	// so we never hijack the Body field of the final domain model.
	type notificationGroupTemp struct {
		group       NotificationGroup
		actorHandle string
	}

	// We process rows which are ordered by created_at DESC from the DB.
	// For each row, check if it fits into an existing group of the same
	// type+ref_id within a 24h window.
	var temps []notificationGroupTemp

	for _, row := range rows {
		ntype := FromDBNotifType(row.Type)

		// Find if there's a matching group within 24h
		foundGroup := false
		for i := range temps {
			t := &temps[i]
			if t.group.Type == ntype && t.group.RefID == row.RefID {
				// Check 24h window
				diff := t.group.CreatedAt.Sub(row.CreatedAt)
				if diff < 0 {
					diff = -diff
				}
				if diff <= 24*time.Hour {
					t.group.Count++
					t.group.IDs = append(t.group.IDs, row.ID)
					// Don't change actor since the group has the most recent one (DESC order)
					foundGroup = true
					break
				}
			}
		}

		if !foundGroup {
			handle := row.ActorHandle.String
			if handle == "" {
				handle = "Someone"
			}
			temps = append(temps, notificationGroupTemp{
				actorHandle: handle,
				group: NotificationGroup{
					ID:         row.ID,
					IDs:        []uuid.UUID{row.ID},
					Type:       ntype,
					IsRealtime: row.IsRealtime,
					IsRead:     row.IsRead,
					RefID:      row.RefID,
					Count:      1,
					CreatedAt:  row.CreatedAt,
				},
			})
		}
	}

	// Generate final bodies from the temp struct, keeping the domain model clean
	groups := make([]NotificationGroup, len(temps))
	for i, t := range temps {
		g := t.group
		g.Body = s.generateBody(g.Type, t.actorHandle, g.Count)
		groups[i] = g
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
	case NotifTypeDirectMessage:
		return fmt.Sprintf("%s sent you a message", actor)
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
