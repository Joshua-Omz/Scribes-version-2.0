package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"time"

	"scribes-api/internal/config"
	"scribes-api/internal/storage"
)

func main() {
	loadEnvFile(".env")
	loadEnvFile("../.env")
	loadEnvFile("backend/.env")

	endpoint := os.Getenv("R2_ENDPOINT")
	accessKey := os.Getenv("R2_ACCESS_KEY_ID")
	secretKey := os.Getenv("R2_SECRET_ACCESS_KEY")
	bucket := os.Getenv("R2_BUCKET")
	cdnDomain := os.Getenv("R2_PUBLIC_URL")

	if endpoint == "" || accessKey == "" || secretKey == "" || bucket == "" {
		log.Fatalf("Missing Cloudflare R2 credentials in environment (R2_ENDPOINT, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY, R2_BUCKET)")
	}

	cfg := config.Config{
		R2Endpoint:        endpoint,
		R2AccessKeyID:     accessKey,
		R2SecretAccessKey: secretKey,
		R2BucketName:      bucket,
		CDNDomain:         cdnDomain,
	}

	storageProvider, err := storage.NewR2Provider(cfg)
	if err != nil {
		log.Fatalf("Failed to initialize Cloudflare R2 provider: %v", err)
	}

	// Locate dist/bible directory
	distDir := findDistBibleDir()
	if distDir == "" {
		log.Fatalf("Could not locate dist/bible directory. Please run scripts/package_bible_translation.py first.")
	}

	log.Printf("Publishing Bible artifacts from: %s", distDir)
	log.Printf("Target Cloudflare R2 bucket: %s (Prefix: bible/)", cfg.R2BucketName)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()

	// 1. Upload all compressed SQLite archives
	files, err := os.ReadDir(distDir)
	if err != nil {
		log.Fatalf("Failed to read dist directory: %v", err)
	}

	var uploadedFiles []string

	for _, entry := range files {
		if entry.IsDir() {
			continue
		}

		name := entry.Name()
		filePath := filepath.Join(distDir, name)

		var contentType string
		var r2Key string

		if strings.HasSuffix(name, ".sqlite3.gz") {
			contentType = "application/gzip"
			r2Key = "bible/" + name
		} else if name == "manifest.json" {
			contentType = "application/json"
			r2Key = "bible/" + name
		} else {
			continue
		}

		log.Printf("Uploading %s -> %s (Content-Type: %s)...", name, r2Key, contentType)
		if err := storageProvider.UploadFile(ctx, r2Key, filePath, contentType); err != nil {
			log.Fatalf("Failed to upload %s: %v", name, err)
		}

		publicURL := storageProvider.GetPublicURL(r2Key)
		log.Printf("SUCCESS: %s is live at %s", name, publicURL)
		uploadedFiles = append(uploadedFiles, publicURL)
	}

	fmt.Println("\nAll Bible artifacts have been successfully published to Cloudflare R2!")
	for _, url := range uploadedFiles {
		fmt.Printf(" • %s\n", url)
	}
}

func findDistBibleDir() string {
	candidates := []string{
		"dist/bible",
		"../dist/bible",
		"../../dist/bible",
	}

	for _, dir := range candidates {
		if info, err := os.Stat(dir); err == nil && info.IsDir() {
			return dir
		}
	}

	return ""
}

func loadEnvFile(path string) {
	data, err := os.ReadFile(path)
	if err != nil {
		return
	}
	lines := strings.Split(string(data), "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		parts := strings.SplitN(line, "=", 2)
		if len(parts) == 2 {
			k := strings.TrimSpace(parts[0])
			v := strings.TrimSpace(parts[1])
			v = strings.Trim(v, `"'`)
			if os.Getenv(k) == "" {
				os.Setenv(k, v)
			}
		}
	}
}
