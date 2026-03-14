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

	return &Config{
		DatabaseURL:    os.Getenv("DATABASE_URL"),
		JWTSecret:      os.Getenv("JWT_SECRET"),
		Port:           port,
		JWTExpiryHours: jwtExpiry,
	}
}
