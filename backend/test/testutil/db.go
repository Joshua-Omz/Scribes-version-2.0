package testutil

import (
	"database/sql"
	"log"

	"scribes-api/internal/config"
	"scribes-api/internal/db/generated"

	_ "github.com/lib/pq"
)

type TestDB struct {
	DB      *sql.DB
	Queries *generated.Queries
}

func SetupDB() *TestDB {
	// For testing, just load the default config
	cfg := config.Load()

	db, err := sql.Open("postgres", cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("failed to open test db: %v", err)
	}

	if err := db.Ping(); err != nil {
		log.Fatalf("failed to ping test db: %v", err)
	}

	queries := generated.New(db)
	return &TestDB{
		DB:      db,
		Queries: queries,
	}
}

func (tdb *TestDB) Teardown() {
	_, _ = tdb.DB.Exec("TRUNCATE TABLE users CASCADE")
	tdb.DB.Close()
}
