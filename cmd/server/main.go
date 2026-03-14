package main

import (
	"log"
	"net/http"

	"github.com/Joshua-Omz/scribes/internal/auth"
	"github.com/Joshua-Omz/scribes/internal/interactions"
	"github.com/Joshua-Omz/scribes/internal/notes"
	"github.com/Joshua-Omz/scribes/internal/posts"
	syncsvc "github.com/Joshua-Omz/scribes/internal/sync"
	"github.com/Joshua-Omz/scribes/internal/users"
	"github.com/Joshua-Omz/scribes/migrations"
	"github.com/Joshua-Omz/scribes/pkg/config"
	"github.com/Joshua-Omz/scribes/pkg/database"
	"github.com/Joshua-Omz/scribes/pkg/middleware"
)

func main() {
	cfg := config.Load()
	if cfg.DatabaseURL == "" {
		log.Fatal("DATABASE_URL is required")
	}
	if cfg.JWTSecret == "" {
		log.Fatal("JWT_SECRET is required")
	}

	db, err := database.Connect(cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("connect to database: %v", err)
	}
	defer db.Close()

	if err := database.RunMigrations(db, migrations.Files); err != nil {
		log.Fatalf("run migrations: %v", err)
	}

	// Wire up handlers.
	authHandler := auth.NewHandler(db, cfg.JWTSecret, cfg.JWTExpiryHours)
	usersHandler := users.NewHandler(users.NewRepository(db))
	notesHandler := notes.NewHandler(notes.NewRepository(db))
	postsHandler := posts.NewHandler(posts.NewRepository(db))
	interactionsHandler := interactions.NewHandler(interactions.NewRepository(db))
	syncHandler := syncsvc.NewHandler(syncsvc.NewRepository(db))

	authMW := middleware.RequireAuth(cfg.JWTSecret)

	mux := http.NewServeMux()

	// Auth (public).
	mux.HandleFunc("POST /auth/signup", authHandler.Signup)
	mux.HandleFunc("POST /auth/login", authHandler.Login)

	// Users (protected).
	mux.Handle("GET /users/me", authMW(http.HandlerFunc(usersHandler.Me)))

	// Notes (protected).
	mux.Handle("GET /notes", authMW(http.HandlerFunc(notesHandler.List)))
	mux.Handle("POST /notes", authMW(http.HandlerFunc(notesHandler.Create)))
	mux.Handle("GET /notes/{id}", authMW(http.HandlerFunc(notesHandler.Get)))
	mux.Handle("PATCH /notes/{id}", authMW(http.HandlerFunc(notesHandler.Update)))
	mux.Handle("DELETE /notes/{id}", authMW(http.HandlerFunc(notesHandler.Delete)))

	// Posts: publish (protected), read (public), archive (protected).
	mux.Handle("POST /posts/publish", authMW(http.HandlerFunc(postsHandler.Publish)))
	mux.HandleFunc("GET /posts/{id}", postsHandler.Get)
	mux.HandleFunc("GET /posts", postsHandler.List)
	mux.Handle("PATCH /posts/{id}/archive", authMW(http.HandlerFunc(postsHandler.Archive)))

	// Interactions.
	mux.Handle("POST /posts/{id}/comments", authMW(http.HandlerFunc(interactionsHandler.AddComment)))
	mux.HandleFunc("GET /posts/{id}/comments", interactionsHandler.ListComments)
	mux.Handle("POST /posts/{id}/reactions", authMW(http.HandlerFunc(interactionsHandler.ToggleReaction)))
	mux.Handle("POST /posts/{id}/bookmarks", authMW(http.HandlerFunc(interactionsHandler.ToggleBookmark)))
	mux.Handle("POST /posts/{id}/imports", authMW(http.HandlerFunc(interactionsHandler.ImportPost)))

	// Sync (protected).
	mux.Handle("GET /sync", authMW(http.HandlerFunc(syncHandler.Delta)))

	log.Printf("Scribes server listening on :%s", cfg.Port)
	if err := http.ListenAndServe(":"+cfg.Port, mux); err != nil {
		log.Fatalf("server: %v", err)
	}
}
