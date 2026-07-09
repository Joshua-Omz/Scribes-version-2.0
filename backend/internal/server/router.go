package server

import (
	"net/http"

	"scribes-api/internal/admin"
	"scribes-api/internal/auth"
	"scribes-api/internal/draft"
	"scribes-api/internal/feed"
	"scribes-api/internal/message"
	"scribes-api/internal/middleware"
	"scribes-api/internal/note"
	"scribes-api/internal/notification"
	"scribes-api/internal/post"
	"scribes-api/internal/social"
	"scribes-api/internal/sync"
	"scribes-api/pkg/respond"

	"github.com/gin-gonic/gin"
)

func NewRouter(authHandler *auth.Handler, noteHandler *note.Handler, draftHandler *draft.Handler, postHandler *post.Handler, syncHandler *sync.Handler, socialHandler *social.Handler, feedHandler *feed.Handler, messageHandler *message.Handler, notificationHandler *notification.Handler, adminHandler *admin.Handler, jwtSecret string) *gin.Engine {
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
	
	// Public social endpoints for posts
	r.GET("/posts/:id/reactions", socialHandler.GetReactions)
	r.GET("/posts/:id/comments", socialHandler.GetComments)

	// Feed & Explore
	r.GET("/explore", feedHandler.GetExplore)
	r.GET("/categories", feedHandler.GetCategories)

	// Protected routes
	protected := r.Group("/")
	protected.Use(middleware.ValidateJWT(jwtSecret))
	{
		protected.GET("/me", authHandler.GetMe)

		// Authenticated feed
		protected.GET("/feed", feedHandler.GetFeed)

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

		// Sync endpoint
		protected.GET("/sync", syncHandler.Pull)

		// Social endpoints
		protected.POST("/users/:id/follow", socialHandler.Follow)
		protected.DELETE("/users/:id/follow", socialHandler.Unfollow)

		protected.POST("/posts/:id/reactions", socialHandler.React)
		protected.DELETE("/posts/:id/reactions", socialHandler.Unreact)

		protected.POST("/posts/:id/comments", socialHandler.AddComment)
		protected.PATCH("/comments/:id", socialHandler.PatchComment)

		protected.POST("/posts/:id/save", socialHandler.SavePost)
		protected.DELETE("/posts/:id/save", socialHandler.UnsavePost)


		// Direct Messaging endpoints
		protected.POST("/message-requests", messageHandler.SendRequest)
		protected.GET("/message-requests", messageHandler.GetPendingRequests)
		protected.POST("/message-requests/:id/approve", messageHandler.ApproveRequest)
		protected.POST("/message-requests/:id/reject", messageHandler.RejectRequest)

		protected.GET("/conversations", messageHandler.GetConversations)
		protected.GET("/conversations/:id/messages", messageHandler.GetMessages)
		protected.GET("/conversations/:id/stream", messageHandler.StreamMessages)
		protected.POST("/conversations/:id/messages", messageHandler.SendMessage)
		protected.POST("/conversations/:id/block", messageHandler.BlockConversation)
		protected.DELETE("/messages/:id", messageHandler.SoftDeleteMessage)

		// Notification endpoints
		protected.GET("/notifications", notificationHandler.GetUnreadNotifications)
		protected.POST("/notifications/:id/read", notificationHandler.MarkAsRead)

		// Admin & Reporting endpoints
		protected.POST("/reports", adminHandler.SubmitReport)
		// For a full implementation, these next two would be wrapped in a super_admin check middleware
		protected.GET("/admin/reports", adminHandler.GetPendingReports)
		protected.POST("/admin/reports/:id/status", adminHandler.UpdateReportStatus)
	}

	return r
}
