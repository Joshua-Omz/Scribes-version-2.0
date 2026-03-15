// Command server is the Scribes API entry point.
package main

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/go-chi/chi/v5"
	chiMiddleware "github.com/go-chi/chi/v5/middleware"

	"github.com/Joshua-Omz/scribes/internal/auth"
	"github.com/Joshua-Omz/scribes/internal/drafts"
	"github.com/Joshua-Omz/scribes/internal/notes"
	"github.com/Joshua-Omz/scribes/internal/posts"
	syncPkg "github.com/Joshua-Omz/scribes/internal/sync"
	"github.com/Joshua-Omz/scribes/internal/users"
	"github.com/Joshua-Omz/scribes/pkg/config"
	"github.com/Joshua-Omz/scribes/pkg/database"
	mw "github.com/Joshua-Omz/scribes/pkg/middleware"
)

func main() {
	// ── Structured JSON logging ───────────────────────────────────────────────
	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	})))

	// ── Configuration ─────────────────────────────────────────────────────────
	cfg, err := config.Load()
	if err != nil {
		slog.Error("config error", "err", err)
		os.Exit(1)
	}

	// ── Database ──────────────────────────────────────────────────────────────
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	db, err := database.Connect(ctx, cfg.DatabaseURL)
	if err != nil {
		slog.Error("database connection failed", "err", err)
		os.Exit(1)
	}
	defer db.Close()
	slog.Info("database connected")

	// ── Migrations ────────────────────────────────────────────────────────────
	if err = database.Migrate(cfg.DatabaseURL, cfg.MigrationsPath); err != nil {
		slog.Error("migration failed", "err", err)
		os.Exit(1)
	}
	slog.Info("migrations applied")

	// ── Repositories ──────────────────────────────────────────────────────────
	userRepo := users.NewRepository(db)
	noteRepo := notes.NewRepository(db)
	draftRepo := drafts.NewRepository(db)
	postRepo := posts.NewRepository(db)

	// ── Handlers ──────────────────────────────────────────────────────────────
	authHandler := auth.NewHandler(userRepo, cfg.JWTSecret)
	noteHandler := notes.NewHandler(noteRepo)
	draftHandler := drafts.NewHandler(draftRepo)
	postHandler := posts.NewHandler(postRepo)
	syncHandler := syncPkg.NewHandler(noteRepo, draftRepo, postRepo)

	// ── Router ────────────────────────────────────────────────────────────────
	r := chi.NewRouter()
	r.Use(chiMiddleware.Recoverer)
	r.Use(mw.Logger)

	// Public routes
	r.Post("/api/auth/register", authHandler.Register)
	r.Post("/api/auth/login", authHandler.Login)

	// Public feed (read-only)
	r.Get("/api/posts", postHandler.Feed)
	r.Get("/api/posts/{id}", postHandler.Get)

	// Protected routes
	r.Group(func(r chi.Router) {
		r.Use(mw.Authenticate(cfg.JWTSecret))

		// Auth
		r.Get("/api/auth/me", authHandler.Me)

		// Notes
		r.Get("/api/notes", noteHandler.List)
		r.Post("/api/notes", noteHandler.Create)
		r.Get("/api/notes/{id}", noteHandler.Get)
		r.Put("/api/notes/{id}", noteHandler.Update)
		r.Delete("/api/notes/{id}", noteHandler.Delete)

		// Drafts
		r.Get("/api/drafts", draftHandler.List)
		r.Post("/api/drafts", draftHandler.Create)
		r.Get("/api/drafts/{id}", draftHandler.Get)
		r.Put("/api/drafts/{id}", draftHandler.Update)
		r.Delete("/api/drafts/{id}", draftHandler.Delete)

		// Posts (write)
		r.Post("/api/posts", postHandler.Create)
		r.Put("/api/posts/{id}", postHandler.Update)
		r.Delete("/api/posts/{id}", postHandler.Delete)

		// Sync engine
		r.Get("/api/sync/pull", syncHandler.Pull)
		r.Post("/api/sync/push", syncHandler.Push)
	})

	// Health-check
	r.Get("/health", func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"status":"ok"}`))
	})

	// ── Server ────────────────────────────────────────────────────────────────
	srv := &http.Server{
		Addr:         fmt.Sprintf(":%d", cfg.ServerPort),
		Handler:      r,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		slog.Info("server starting", "port", cfg.ServerPort)
		if err = srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			slog.Error("server error", "err", err)
			os.Exit(1)
		}
	}()

	<-quit
	slog.Info("shutting down…")
	shutCtx, shutCancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer shutCancel()
	if err = srv.Shutdown(shutCtx); err != nil {
		slog.Error("graceful shutdown failed", "err", err)
	}
	slog.Info("server stopped")
}
