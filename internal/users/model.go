package users

import "time"

// User represents a platform user.
type User struct {
	ID          string     `json:"id"`
	Email       string     `json:"email"`
	Username    string     `json:"username"`
	DisplayName *string    `json:"display_name"`
	Bio         *string    `json:"bio"`
	CreatedAt   time.Time  `json:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at"`
	DeletedAt   *time.Time `json:"deleted_at,omitempty"`
}
