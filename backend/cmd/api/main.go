package main

import (
	"context"
	"database/sql"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"scribes-api/internal/admin"
	"scribes-api/internal/auth"
	"scribes-api/internal/config"
	"scribes-api/internal/db"
	"scribes-api/internal/db/generated"
	"scribes-api/internal/draft"
	"scribes-api/internal/feed"
	"scribes-api/internal/message"
	"scribes-api/internal/note"
	"scribes-api/internal/notification"
	"scribes-api/internal/post"
	"scribes-api/internal/server"
	"scribes-api/internal/social"
	"scribes-api/internal/sync"

	_ "github.com/lib/pq"
)


func main() {
	cfg := config.Load()

	db, err := sql.Open("postgres", cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("failed to open db connection: %v", err)
	}
	defer db.Close()

	if err := db.Ping(); err != nil {
		log.Fatalf("failed to ping db: %v", err)
	}
	log.Println("connected to postgres")

	queries := generated.New(db)

	authRepo := auth.NewRepository(queries)
	authSvc := auth.NewService(authRepo, auth.Config{
		JWTSecret:      cfg.JWTSecret,
		JWTExpiryHours: cfg.JWTExpiryHours,
		BcryptCost:     cfg.BcryptCost,
		DummyHash:      cfg.DummyHash,
	})
	authHandler := auth.NewHandler(authSvc)

	draftRepo := draft.NewRepository(queries)
	draftSvc := draft.NewService(draftRepo)
	draftHandler := draft.NewHandler(draftSvc)

	noteRepo := note.NewRepository(queries)
	// We pass draftSvc so that the promote endpoint can create drafts.
	noteSvc := note.NewService(noteRepo, draftSvc)
	noteHandler := note.NewHandler(noteSvc)

	postRepo := post.NewRepository(queries, db)
	postSvc := post.NewService(postRepo)
	postHandler := post.NewHandler(postSvc)

	syncRepo := sync.NewRepository(queries)
	syncSvc := sync.NewService(syncRepo)
	syncHandler := sync.NewHandler(syncSvc)

	socialRepo := social.NewRepository(queries, db)
	socialSvc := social.NewService(socialRepo, postRepo)
	socialHandler := social.NewHandler(socialSvc)

	feedRepo := feed.NewRepository(queries, db)
	feedSvc := feed.NewService(feedRepo)
	feedHandler := feed.NewHandler(feedSvc)

	messageRepo := message.NewRepository(queries, db)
	messageSvc := message.NewService(messageRepo)
	messageHandler := message.NewHandler(messageSvc)

	notificationRepo := notification.NewRepository(queries, db)
	notificationSvc := notification.NewService(notificationRepo)
	notificationHandler := notification.NewHandler(notificationSvc)

	adminRepo := admin.NewRepository(queries, db)
	adminSvc := admin.NewService(adminRepo)
	adminHandler := admin.NewHandler(adminSvc)

	router := server.NewRouter(authHandler, noteHandler, draftHandler, postHandler, syncHandler, socialHandler, feedHandler, messageHandler, notificationHandler, adminHandler, cfg.JWTSecret)

	srv := &http.Server{
		Addr:    ":" + cfg.Port,
		Handler: router,
	}

	go func() {
		log.Printf("starting server on port %s", cfg.Port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("listen error: %v", err)
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("shutting down server...")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		log.Fatalf("server shutdown error: %v", err)
	}
	log.Println("server stopped gracefully")
}
