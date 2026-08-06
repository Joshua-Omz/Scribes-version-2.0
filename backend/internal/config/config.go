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
	BcryptCost                int
	DummyHash                 string
	EngagementRefreshInterval string
	R2AccountID               string
	R2AccessKeyID             string
	R2SecretAccessKey         string
	R2BucketName              string
	CDNDomain                 string
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

	refreshStr := os.Getenv("ENGAGEMENT_REFRESH_INTERVAL")
	if refreshStr == "" {
		refreshStr = "1h" // Default to 1 hour
	}

	r2AccountID := os.Getenv("R2_ACCOUNT_ID")
	r2AccessKeyID := os.Getenv("R2_ACCESS_KEY_ID")
	r2SecretAccessKey := os.Getenv("R2_SECRET_ACCESS_KEY")
	r2BucketName := os.Getenv("R2_BUCKET_NAME")
	cdnDomain := os.Getenv("CDN_DOMAIN")

	return Config{
		DatabaseURL:               dbURL,
		JWTSecret:                 jwtSecret,
		JWTExpiryHours:            expiry,
		Port:                      port,
		BcryptCost:                cost,
		DummyHash:                 dummyHash,
		EngagementRefreshInterval: refreshStr,
		R2AccountID:               r2AccountID,
		R2AccessKeyID:             r2AccessKeyID,
		R2SecretAccessKey:         r2SecretAccessKey,
		R2BucketName:              r2BucketName,
		CDNDomain:                 cdnDomain,
	}
}
