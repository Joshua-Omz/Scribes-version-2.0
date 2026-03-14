package config

import (
	"os"
	"strconv"
)

// Config holds all application configuration loaded from environment variables.
type Config struct {
	DatabaseURL    string
	JWTSecret      string
	Port           string
	JWTExpiryHours int
	DBMaxOpenConns int
	DBMaxIdleConns int
}

// Load reads configuration from environment variables, applying defaults where needed.
func Load() *Config {
	jwtExpiry := 24
	if v := os.Getenv("JWT_EXPIRY_HOURS"); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			jwtExpiry = n
		}
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	dbMaxOpen := 25
	if v := os.Getenv("DB_MAX_OPEN_CONNS"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n > 0 {
			dbMaxOpen = n
		}
	}

	dbMaxIdle := 10
	if v := os.Getenv("DB_MAX_IDLE_CONNS"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n > 0 {
			dbMaxIdle = n
		}
	}

	return &Config{
		DatabaseURL:    os.Getenv("DATABASE_URL"),
		JWTSecret:      os.Getenv("JWT_SECRET"),
		Port:           port,
		JWTExpiryHours: jwtExpiry,
		DBMaxOpenConns: dbMaxOpen,
		DBMaxIdleConns: dbMaxIdle,
	}
}
