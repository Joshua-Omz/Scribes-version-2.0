package auth

// SignupRequest is the payload for POST /auth/signup.
type SignupRequest struct {
	Email    string `json:"email"`
	Username string `json:"username"`
	Password string `json:"password"`
}

// LoginRequest is the payload for POST /auth/login.
type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

// AuthResponse is returned on successful signup or login.
type AuthResponse struct {
	Token string `json:"token"`
}
