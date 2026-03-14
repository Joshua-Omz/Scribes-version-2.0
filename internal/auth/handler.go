package auth

import (
	"database/sql"
	"encoding/json"
	"errors"
	"net/http"
	"strings"

	"github.com/lib/pq"
	"golang.org/x/crypto/bcrypt"
)

// Handler handles authentication endpoints.
type Handler struct {
	db             *sql.DB
	jwtSecret      string
	jwtExpiryHours int
}

// NewHandler creates an auth handler.
func NewHandler(db *sql.DB, jwtSecret string, jwtExpiryHours int) *Handler {
	return &Handler{db: db, jwtSecret: jwtSecret, jwtExpiryHours: jwtExpiryHours}
}

// Signup handles POST /auth/signup.
func (h *Handler) Signup(w http.ResponseWriter, r *http.Request) {
	var req SignupRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	req.Email = strings.TrimSpace(strings.ToLower(req.Email))
	req.Username = strings.TrimSpace(req.Username)

	if req.Email == "" || req.Username == "" || req.Password == "" {
		writeError(w, http.StatusBadRequest, "email, username, and password are required")
		return
	}
	if len(req.Password) < 8 {
		writeError(w, http.StatusBadRequest, "password must be at least 8 characters")
		return
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to hash password")
		return
	}

	var userID, email, username string
	err = h.db.QueryRowContext(r.Context(),
		`INSERT INTO users (email, username, password_hash)
		 VALUES ($1, $2, $3)
		 RETURNING id, email, username`,
		req.Email, req.Username, string(hash),
	).Scan(&userID, &email, &username)
	if err != nil {
		var pgErr *pq.Error
		if ok := errors.As(err, &pgErr); ok && pgErr.Code == "23505" {
			writeError(w, http.StatusConflict, "email or username already in use")
			return
		}
		writeError(w, http.StatusInternalServerError, "failed to create user")
		return
	}

	token, err := GenerateToken(userID, email, username, h.jwtSecret, h.jwtExpiryHours)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to generate token")
		return
	}

	writeJSON(w, http.StatusCreated, map[string]interface{}{"data": AuthResponse{Token: token}})
}

// Login handles POST /auth/login.
func (h *Handler) Login(w http.ResponseWriter, r *http.Request) {
	var req LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	req.Email = strings.TrimSpace(strings.ToLower(req.Email))

	if req.Email == "" || req.Password == "" {
		writeError(w, http.StatusBadRequest, "email and password are required")
		return
	}

	var userID, email, username, hash string
	err := h.db.QueryRowContext(r.Context(),
		`SELECT id, email, username, password_hash FROM users WHERE email = $1 AND deleted_at IS NULL`,
		req.Email,
	).Scan(&userID, &email, &username, &hash)
	if err == sql.ErrNoRows {
		writeError(w, http.StatusUnauthorized, "invalid credentials")
		return
	}
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to fetch user")
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(req.Password)); err != nil {
		writeError(w, http.StatusUnauthorized, "invalid credentials")
		return
	}

	token, err := GenerateToken(userID, email, username, h.jwtSecret, h.jwtExpiryHours)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to generate token")
		return
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{"data": AuthResponse{Token: token}})
}

func writeJSON(w http.ResponseWriter, status int, v interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v) //nolint:errcheck
}

func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]string{"error": msg})
}
