package middleware

import (
	"context"
	"net/http"
	"strings"

	"scribes-api/pkg/respond"
	"scribes-api/pkg/token"

	"github.com/gin-gonic/gin"
)

type ctxKey struct{}

func ValidateJWT(secret string) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			respond.Error(c, http.StatusUnauthorized, "missing authorization header")
			c.Abort()
			return
		}

		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			respond.Error(c, http.StatusUnauthorized, "invalid authorization header format")
			c.Abort()
			return
		}

		claims, err := token.Parse(parts[1], secret)
		if err != nil {
			respond.Error(c, http.StatusUnauthorized, "invalid or expired token")
			c.Abort()
			return
		}

		ctx := context.WithValue(c.Request.Context(), ctxKey{}, claims)
		c.Request = c.Request.WithContext(ctx)
		c.Next()
	}
}

func ClaimsFromCtx(ctx context.Context) (*token.Claims, bool) {
	claims, ok := ctx.Value(ctxKey{}).(*token.Claims)
	return claims, ok
}
