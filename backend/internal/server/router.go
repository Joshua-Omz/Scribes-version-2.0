package server

import (
	"net/http"

	"scribes-api/internal/auth"
	"scribes-api/internal/draft"
	"scribes-api/internal/middleware"
	"scribes-api/internal/note"
	"scribes-api/internal/post"
	"scribes-api/pkg/respond"

	"github.com/gin-gonic/gin"
)

func NewRouter(authHandler *auth.Handler, noteHandler *note.Handler, draftHandler *draft.Handler, postHandler *post.Handler, jwtSecret string) http.Handler {
	r := gin.Default()

	r.GET("/health", func(c *gin.Context) {
		respond.JSON(c, http.StatusOK, gin.H{"status": "ok"})
	})

	authGroup := r.Group("/auth")
	{
		authGroup.POST("/register", authHandler.Register)
		authGroup.POST("/login", authHandler.Login)
	}

	// Public post endpoints — no auth required
	r.GET("/posts/:id", postHandler.GetByID)
	r.GET("/posts/:id/versions", postHandler.ListVersions)
	r.GET("/posts/:id/versions/:version", postHandler.GetVersion)

	// Protected routes
	protected := r.Group("/")
	protected.Use(middleware.ValidateJWT(jwtSecret))
	{
		protected.GET("/me", func(c *gin.Context) {
			claims, _ := middleware.ClaimsFromCtx(c.Request.Context())
			respond.JSON(c, http.StatusOK, gin.H{
				"user_id": claims.UserID,
				"role":    claims.Role,
			})
		})

		// Note endpoints
		protected.GET("/notes", noteHandler.List)
		protected.POST("/notes", noteHandler.Create)
		protected.PATCH("/notes/:id", noteHandler.Update)
		protected.DELETE("/notes/:id", noteHandler.Delete)
		protected.POST("/notes/:id/promote", noteHandler.Promote)

		// Draft endpoints
		protected.GET("/drafts", draftHandler.List)
		protected.GET("/drafts/:id", draftHandler.Get)
		protected.POST("/drafts", draftHandler.Create)
		protected.PATCH("/drafts/:id", draftHandler.Update)
		protected.DELETE("/drafts/:id", draftHandler.Delete)

		// Post endpoints (author-only mutations)
		protected.GET("/posts", postHandler.List)
		protected.POST("/posts", postHandler.Create)
		protected.PATCH("/posts/:id", postHandler.Update)
		protected.DELETE("/posts/:id", postHandler.Delete)
		protected.PATCH("/posts/:id/revise", postHandler.Revise)
		protected.POST("/posts/:id/correct", postHandler.CreateCorrection)
	}

	return r
}
