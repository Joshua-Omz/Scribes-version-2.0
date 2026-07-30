package notification

import (
	"time"

	"github.com/google/uuid"
	"scribes-api/internal/db/generated"
)

type NotifType string

const (
	NotifTypeMention    NotifType = "mention"
	NotifTypeReaction   NotifType = "reaction"
	NotifTypeComment    NotifType = "comment"
	NotifTypeFollow     NotifType = "follow"
	NotifTypeAdminAlert NotifType = "admin_alert"
)

// Map from our domain type to DB generated type
func (t NotifType) ToDB() generated.NotifType {
	return generated.NotifType(t)
}

// Map from DB generated type to domain type
func FromDBNotifType(t generated.NotifType) NotifType {
	return NotifType(t)
}

// Event is what handlers enqueue — internal to the worker pipeline
type Event struct {
	Type        NotifType
	RecipientID uuid.UUID
	RefID       uuid.UUID
	IsRealtime  bool
	ActorID     uuid.UUID
}

// Notification is the domain type returned to the client
type Notification struct {
	ID          uuid.UUID `json:"id"`
	Type        NotifType `json:"type"`
	IsRealtime  bool      `json:"is_realtime"`
	IsRead      bool      `json:"is_read"`
	Body        string    `json:"body"`
	RefID       uuid.UUID `json:"ref_id"`
	ActorHandle string    `json:"actor_handle,omitempty"`
	ActorAvatar string    `json:"actor_avatar,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
}

// NotificationGroup represents grouped batched notifications
type NotificationGroup struct {
	ID         uuid.UUID   `json:"id"`
	IDs        []uuid.UUID `json:"ids"`
	Type       NotifType   `json:"type"`
	IsRealtime bool        `json:"is_realtime"`
	IsRead     bool        `json:"is_read"`
	Body       string      `json:"body"`
	RefID      uuid.UUID   `json:"ref_id"`
	Count      int         `json:"count"`
	CreatedAt  time.Time   `json:"created_at"`
}

