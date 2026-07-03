package config

import (
	"log"
	"os"
	"strconv"

	"scribes-api/pkg/password"
)

type Config struct {
	DatabaseURL    string
	JWTSecret      string
	JWTExpiryHours int
	Port           string
	BcryptCost     int
	DummyHash      string
}

func Load() Config {
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		log.Fatal("DATABASE_URL is not set")
	}

	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		log.Fatal("JWT_SECRET is not set")
	}

	expiryStr := os.Getenv("JWT_EXPIRY_HOURS")
	expiry := 168
	if expiryStr != "" {
		if parsed, err := strconv.Atoi(expiryStr); err == nil {
			expiry = parsed
		}
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	costStr := os.Getenv("BCRYPT_COST")
	cost := 12
	if costStr != "" {
		if parsed, err := strconv.Atoi(costStr); err == nil {
			cost = parsed
		}
	}

	dummyHash, _ := password.Hash("dummy_password_for_timing_mitigation", cost)

	return Config{
		DatabaseURL:    dbURL,
		JWTSecret:      jwtSecret,
		JWTExpiryHours: expiry,
		Port:           port,
		BcryptCost:     cost,
		DummyHash:      dummyHash,
	}
}
