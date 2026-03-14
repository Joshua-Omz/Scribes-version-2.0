package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/Joshua-Omz/scribes/internal/auth"
)

type contextKey string

// UserIDKey is the context key used to store the authenticated user's ID.
const UserIDKey contextKey = "user_id"

// RequireAuth validates the Bearer JWT token and injects the user_id into the request context.
// Returns 401 if the token is missing or invalid.
func RequireAuth(jwtSecret string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			header := r.Header.Get("Authorization")
			if header == "" || !strings.HasPrefix(header, "Bearer ") {
				http.Error(w, `{"error":"missing or invalid authorization header"}`, http.StatusUnauthorized)
				return
			}
			token := strings.TrimPrefix(header, "Bearer ")
			claims, err := auth.ParseToken(token, jwtSecret)
			if err != nil {
				http.Error(w, `{"error":"invalid or expired token"}`, http.StatusUnauthorized)
				return
			}
			ctx := context.WithValue(r.Context(), UserIDKey, claims.UserID)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

// UserIDFromContext retrieves the authenticated user ID from the context.
func UserIDFromContext(ctx context.Context) (string, bool) {
	id, ok := ctx.Value(UserIDKey).(string)
	return id, ok
}
