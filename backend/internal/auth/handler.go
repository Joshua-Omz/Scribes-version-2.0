package auth

import (
	"net/http"

	"scribes-api/internal/middleware"
	"scribes-api/pkg/respond"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type Handler struct {
	svc *Service
}

func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

type authResponse struct {
	User  User   `json:"user"`
	Token string `json:"token"`
}

func (h *Handler) Register(c *gin.Context) {
	var input RegisterInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid json payload")
		return
	}

	user, token, err := h.svc.Register(c.Request.Context(), input)
	if err != nil {
		switch err {
		case ErrEmailTaken, ErrHandleTaken:
			respond.Error(c, http.StatusConflict, err.Error())
		default:
			if err.Error() == "password must be at least 8 characters" ||
				err.Error() == "handle must be alphanumeric and underscores only" ||
				err.Error() == "invalid email format" {
				respond.Error(c, http.StatusBadRequest, err.Error())
				return
			}
			respond.Error(c, http.StatusInternalServerError, "internal server error")
		}
		return
	}

	respond.JSON(c, http.StatusCreated, authResponse{User: user, Token: token})
}

func (h *Handler) Login(c *gin.Context) {
	var input LoginInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid json payload")
		return
	}

	user, token, err := h.svc.Login(c.Request.Context(), input)
	if err != nil {
		switch err {
		case ErrInvalidCredentials:
			respond.Error(c, http.StatusUnauthorized, err.Error())
		default:
			respond.Error(c, http.StatusInternalServerError, "internal server error")
		}
		return
	}

	respond.JSON(c, http.StatusOK, authResponse{User: user, Token: token})
}

func (h *Handler) GetMe(c *gin.Context) {
	claims, ok := middleware.ClaimsFromCtx(c.Request.Context())
	if !ok {
		respond.Error(c, http.StatusUnauthorized, "unauthorized")
		return
	}

	userID, err := uuid.Parse(claims.UserID)
	if err != nil {
		respond.Error(c, http.StatusUnauthorized, "invalid user id")
		return
	}

	user, err := h.svc.GetUserByID(c.Request.Context(), userID)
	if err != nil {
		respond.Error(c, http.StatusNotFound, "user not found")
		return
	}

	respond.JSON(c, http.StatusOK, user)
}
