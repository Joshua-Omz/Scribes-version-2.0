package database

import (
	"database/sql"
	"fmt"
	"io/fs"
	"sort"
	"strings"

	_ "github.com/lib/pq"
)

// Connect opens and validates a PostgreSQL connection.
func Connect(databaseURL string) (*sql.DB, error) {
	db, err := sql.Open("postgres", databaseURL)
	if err != nil {
		return nil, fmt.Errorf("open database: %w", err)
	}
	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("ping database: %w", err)
	}
	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(10)
	return db, nil
}

// RunMigrations applies all SQL files from the provided fs.FS in lexicographic order.
// It is idempotent because all migration files use CREATE TABLE IF NOT EXISTS.
func RunMigrations(db *sql.DB, files fs.FS) error {
	entries, err := fs.ReadDir(files, ".")
	if err != nil {
		return fmt.Errorf("read migrations dir: %w", err)
	}

	names := make([]string, 0, len(entries))
	for _, e := range entries {
		if !e.IsDir() && strings.HasSuffix(e.Name(), ".sql") {
			names = append(names, e.Name())
		}
	}
	sort.Strings(names)

	for _, name := range names {
		data, err := fs.ReadFile(files, name)
		if err != nil {
			return fmt.Errorf("read migration %s: %w", name, err)
		}
		if _, err := db.Exec(string(data)); err != nil {
			return fmt.Errorf("apply migration %s: %w", name, err)
		}
	}
	return nil
}
