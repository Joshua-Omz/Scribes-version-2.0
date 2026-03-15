// Package database provides a pgx connection pool and migration runner.
package database

import (
	"context"
	"fmt"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/pgx/v5"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Connect opens a pgxpool connection pool and verifies connectivity.
func Connect(ctx context.Context, databaseURL string) (*pgxpool.Pool, error) {
	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		return nil, fmt.Errorf("open pool: %w", err)
	}
	if err = pool.Ping(ctx); err != nil {
		pool.Close()
		return nil, fmt.Errorf("ping database: %w", err)
	}
	return pool, nil
}

// Migrate runs all pending up-migrations from migrationsPath against
// databaseURL.  It treats "no change" as a success.
func Migrate(databaseURL, migrationsPath string) error {
	// golang-migrate's pgx/v5 driver expects the scheme "pgx5://…"
	dsn := "pgx5://" + stripScheme(databaseURL)

	m, err := migrate.New(migrationsPath, dsn)
	if err != nil {
		return fmt.Errorf("create migrator: %w", err)
	}
	defer m.Close()

	if err = m.Up(); err != nil && err != migrate.ErrNoChange {
		return fmt.Errorf("run migrations: %w", err)
	}
	return nil
}

// stripScheme removes any existing scheme prefix (e.g. "postgres://") so we
// can prepend the scheme required by the migrate driver ("pgx5://").
func stripScheme(url string) string {
	if len(url) < 3 {
		return url
	}
	for i := 0; i < len(url)-2; i++ {
		if url[i] == ':' && url[i+1] == '/' && url[i+2] == '/' {
			return url[i+3:]
		}
	}
	return url
}
