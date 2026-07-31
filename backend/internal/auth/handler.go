package auth

import (
	"net/http"
	"strconv"

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

type GoogleLoginInput struct {
	IDToken string `json:"id_token"`
}

func (h *Handler) LoginWithGoogle(c *gin.Context) {
	var input GoogleLoginInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid json payload")
		return
	}

	user, token, err := h.svc.LoginWithGoogle(c.Request.Context(), input.IDToken)
	if err != nil {
		respond.Error(c, http.StatusUnauthorized, err.Error())
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

func (h *Handler) GetPublicProfile(c *gin.Context) {
	userID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid user id")
		return
	}

	profile, err := h.svc.GetPublicProfile(c.Request.Context(), userID)
	if err != nil {
		respond.Error(c, http.StatusNotFound, "user not found")
		return
	}

	respond.JSON(c, http.StatusOK, profile)
}

func (h *Handler) SearchUsers(c *gin.Context) {
	query := c.Query("q")
	if query == "" {
		respond.JSON(c, http.StatusOK, []interface{}{})
		return
	}

	results, err := h.svc.SearchUsers(c.Request.Context(), query)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "search failed")
		return
	}

	respond.JSON(c, http.StatusOK, results)
}

func (h *Handler) GetSuggestedUsers(c *gin.Context) {
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

	limitStr := c.Query("limit")
	var limit int32 = 10
	if limitStr != "" {
		if l, err := strconv.ParseInt(limitStr, 10, 32); err == nil {
			limit = int32(l)
		}
	}

	results, err := h.svc.GetSuggestedUsers(c.Request.Context(), userID, limit)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "fetch failed")
		return
	}

	respond.JSON(c, http.StatusOK, results)
}

func (h *Handler) UpdateProfile(c *gin.Context) {
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

	var input UpdateProfileInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid payload")
		return
	}

	user, err := h.svc.UpdateProfile(c.Request.Context(), userID, input)
	if err != nil {
		if err == ErrHandleTaken {
			respond.Error(c, http.StatusConflict, err.Error())
		} else {
			respond.Error(c, http.StatusInternalServerError, err.Error())
		}
		return
	}
	respond.JSON(c, http.StatusOK, user)
}

func (h *Handler) UpdateTags(c *gin.Context) {
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

	var input UpdateTagsInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid payload")
		return
	}

	user, err := h.svc.UpdateTags(c.Request.Context(), userID, input.Tags)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, err.Error())
		return
	}
	respond.JSON(c, http.StatusOK, user)
}

func (h *Handler) UpdateEmail(c *gin.Context) {
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

	var input UpdateEmailInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid payload")
		return
	}

	if err := h.svc.UpdateEmail(c.Request.Context(), userID, input); err != nil {
		if err == ErrInvalidCredentials {
			respond.Error(c, http.StatusForbidden, err.Error())
		} else {
			respond.Error(c, http.StatusBadRequest, err.Error())
		}
		return
	}
	respond.JSON(c, http.StatusOK, map[string]string{"status": "success"})
}

func (h *Handler) UpdatePassword(c *gin.Context) {
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

	var input UpdatePasswordInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid payload")
		return
	}

	if err := h.svc.UpdatePassword(c.Request.Context(), userID, input); err != nil {
		if err == ErrInvalidCredentials {
			respond.Error(c, http.StatusForbidden, err.Error())
		} else {
			respond.Error(c, http.StatusBadRequest, err.Error())
		}
		return
	}
	respond.JSON(c, http.StatusOK, map[string]string{"status": "success"})
}

func (h *Handler) GetNotificationPreferences(c *gin.Context) {
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

	prefs, err := h.svc.GetNotificationPreferences(c.Request.Context(), userID)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, err.Error())
		return
	}
	respond.JSON(c, http.StatusOK, prefs)
}

func (h *Handler) UpdateNotificationPreferences(c *gin.Context) {
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

	var input UpdateNotificationPreferencesInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond.Error(c, http.StatusBadRequest, "invalid payload")
		return
	}

	prefs, err := h.svc.UpdateNotificationPreferences(c.Request.Context(), userID, input)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, err.Error())
		return
	}
	respond.JSON(c, http.StatusOK, prefs)
}
