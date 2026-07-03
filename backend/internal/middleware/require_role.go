package middleware

import (
	"net/http"

	"scribes-api/pkg/respond"

	"github.com/gin-gonic/gin"
)

func RequireRole(role string) gin.HandlerFunc {
	return func(c *gin.Context) {
		claims, ok := ClaimsFromCtx(c.Request.Context())
		if !ok {
			respond.Error(c, http.StatusUnauthorized, "unauthorized")
			c.Abort()
			return
		}

		if claims.Role != role {
			respond.Error(c, http.StatusForbidden, "forbidden: insufficient role")
			c.Abort()
			return
		}

		c.Next()
	}
}
