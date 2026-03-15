// Package config loads application configuration from environment variables
// (with optional .env file support via godotenv).
package config

import (
	"fmt"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

// Config holds all runtime configuration for the Scribes API server.
type Config struct {
	DatabaseURL    string
	JWTSecret      string
	ServerPort     int
	MigrationsPath string
}

// Load reads configuration from the environment. A ".env" file in the working
// directory is loaded first if it exists; explicit environment variables always
// take precedence.
func Load() (*Config, error) {
	// Best-effort – ignore the error when no .env file is present.
	_ = godotenv.Load()

	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		return nil, fmt.Errorf("DATABASE_URL is required")
	}

	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		return nil, fmt.Errorf("JWT_SECRET is required")
	}

	port := 8080
	if raw := os.Getenv("SERVER_PORT"); raw != "" {
		p, err := strconv.Atoi(raw)
		if err != nil {
			return nil, fmt.Errorf("SERVER_PORT must be a valid integer: %w", err)
		}
		port = p
	}

	migrationsPath := os.Getenv("MIGRATIONS_PATH")
	if migrationsPath == "" {
		migrationsPath = "file://migrations"
	}

	return &Config{
		DatabaseURL:    dbURL,
		JWTSecret:      jwtSecret,
		ServerPort:     port,
		MigrationsPath: migrationsPath,
	}, nil
}
