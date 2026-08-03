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
	"scribes-api/internal/recommendation"
	"scribes-api/internal/search"
	"scribes-api/internal/social"
	"scribes-api/internal/sync"
	"scribes-api/internal/tag"
	"scribes-api/pkg/respond"

	"github.com/gin-gonic/gin"
)

func NewRouter(authHandler *auth.Handler, noteHandler *note.Handler, draftHandler *draft.Handler, postHandler *post.Handler, syncHandler *sync.Handler, socialHandler *social.Handler, feedHandler *feed.Handler, messageHandler *message.Handler, notificationHandler *notification.Handler, adminHandler *admin.Handler, tagHandler *tag.Handler, searchHandler *search.Handler, recommendationHandler *recommendation.Handler, jwtSecret string) *gin.Engine {
	r := gin.Default()


	r.GET("/health", func(c *gin.Context) {
		respond.JSON(c, http.StatusOK, gin.H{"status": "ok"})
	})

	authGroup := r.Group("/auth")
	{
		authGroup.POST("/register", authHandler.Register)
		authGroup.POST("/login", authHandler.Login)
		authGroup.POST("/google", authHandler.LoginWithGoogle)
	}

	// Public post endpoints — no auth required
	r.GET("/posts/:id", postHandler.GetByID)
	r.GET("/posts/:id/versions", postHandler.ListVersions)
	r.GET("/posts/:id/versions/:version", postHandler.GetVersion)
	r.GET("/posts/:id/export", postHandler.Export)
	
	// Public social endpoints for posts
	r.GET("/posts/:id/reactions", socialHandler.GetReactions)
	r.GET("/posts/:id/comments", socialHandler.GetComments)

	// Public user endpoints
	r.GET("/users/search", authHandler.SearchUsers)
	r.GET("/users/:id", authHandler.GetPublicProfile)
	r.GET("/users/:id/posts", postHandler.ListByAuthor)
	r.GET("/users/:id/followers", socialHandler.GetFollowers)
	r.GET("/users/:id/following", socialHandler.GetFollowing)

	// Feed & Explore
	r.GET("/explore", feedHandler.GetExplore)
	r.GET("/explore/churches", feedHandler.GetExploreChurches)
	r.GET("/tags/suggest", tagHandler.SuggestTags)
	r.GET("/tags/trending", tagHandler.GetTrendingTags)
	r.GET("/tags/:name/posts", feedHandler.GetExploreByTag)
	
	// Search
	r.GET("/search/posts", searchHandler.SearchPosts)
	r.GET("/search/users", searchHandler.SearchAuthors)
	
	// Recommendations
	r.GET("/posts/recommendations", recommendationHandler.GetRecommendations)
	r.GET("/posts/:id/similar", recommendationHandler.GetSimilarPosts)

	// Protected routes
	protected := r.Group("/")
	protected.Use(middleware.ValidateJWT(jwtSecret))
	{
		protected.GET("/me", authHandler.GetMe)
		protected.PATCH("/me", authHandler.UpdateProfile)
		protected.PUT("/me/tags", authHandler.UpdateTags)
		protected.PATCH("/me/email", authHandler.UpdateEmail)
		protected.PATCH("/me/password", authHandler.UpdatePassword)
		protected.GET("/me/notifications", authHandler.GetNotificationPreferences)
		protected.PATCH("/me/notifications", authHandler.UpdateNotificationPreferences)
		// Authenticated feed
		protected.GET("/feed", feedHandler.GetFeed)
		protected.GET("/feed/following", feedHandler.GetFollowingFeed)
		protected.GET("/explore/for-you", feedHandler.GetForYou)
		protected.GET("/users/suggested", authHandler.GetSuggestedUsers)

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
		protected.POST("/drafts/:id/publish", draftHandler.Publish)

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
		protected.GET("/users/:id/is-following", socialHandler.IsFollowing)

		protected.POST("/posts/:id/reactions", socialHandler.React)
		protected.DELETE("/posts/:id/reactions", socialHandler.Unreact)

		protected.POST("/posts/:id/comments", socialHandler.AddComment)
		protected.PATCH("/comments/:id", socialHandler.PatchComment)

		protected.POST("/posts/:id/save", socialHandler.SavePost)
		protected.DELETE("/posts/:id/save", socialHandler.UnsavePost)
		protected.GET("/saved", socialHandler.ListSavedPosts)


		// Direct Messaging endpoints
		protected.POST("/message-requests", messageHandler.SendRequest)
		protected.GET("/message-requests", messageHandler.GetPendingRequests)
		protected.POST("/message-requests/:id/approve", messageHandler.ApproveRequest)
		protected.POST("/message-requests/:id/reject", messageHandler.RejectRequest)

		protected.GET("/contacts/search", messageHandler.SearchContacts)
		protected.GET("/conversations", messageHandler.GetConversations)
		protected.POST("/conversations/direct", messageHandler.DirectConversation)
		protected.GET("/conversations/:id/messages", messageHandler.GetMessages)
		protected.GET("/conversations/:id/stream", messageHandler.StreamMessages)
		protected.POST("/conversations/:id/messages", messageHandler.SendMessage)
		protected.PATCH("/conversations/:id/messages/:msg_id", messageHandler.UpdateMessage)
		protected.POST("/conversations/:id/block", messageHandler.BlockConversation)
		protected.DELETE("/messages/:id", messageHandler.SoftDeleteMessage)

		// Notification endpoints
		protected.GET("/notifications", notificationHandler.GetNotifications)
		protected.GET("/notifications/stream", notificationHandler.StreamNotifications)
		protected.POST("/notifications/read-all", notificationHandler.MarkAllRead)
		protected.DELETE("/notifications/clear-all", notificationHandler.ClearAll)
		protected.POST("/notifications/bulk-delete", notificationHandler.BulkDelete)
		protected.POST("/notifications/bulk-read", notificationHandler.BulkRead)

		// Admin & Reporting endpoints
		protected.POST("/reports", adminHandler.SubmitReport)
		// For a full implementation, these next two would be wrapped in a super_admin check middleware
		protected.GET("/admin/reports", adminHandler.GetPendingReports)
		protected.POST("/admin/reports/:id/status", adminHandler.UpdateReportStatus)
	}

	return r
}
