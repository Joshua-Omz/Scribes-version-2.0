package feed

import (
	"net/http"
	"strconv"
	"time"

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

func (h *Handler) GetFollowingFeed(c *gin.Context) {
	claims, ok := middleware.ClaimsFromCtx(c.Request.Context())
	if !ok {
		respond.Error(c, http.StatusUnauthorized, "unauthorized")
		return
	}
	userID, _ := uuid.Parse(claims.UserID)

	// Keyset pagination parameters
	cursorTsStr := c.Query("cursor_ts")
	cursorIDStr := c.Query("cursor_id")
	limitStr := c.Query("limit")

	limit, _ := strconv.Atoi(limitStr)
	
	// Default to now if no cursor
	var cursorTs time.Time
	if cursorTsStr == "" {
		cursorTs = time.Now()
	} else {
		parsedTs, err := time.Parse(time.RFC3339, cursorTsStr)
		if err == nil {
			cursorTs = parsedTs
		} else {
			cursorTs = time.Now()
		}
	}

	var cursorID uuid.UUID
	if cursorIDStr == "" {
		// Use a max UUID or something to ensure we get results before it,
		// or if we use time mostly, the UUID is just a tiebreaker.
		cursorID = uuid.MustParse("ffffffff-ffff-ffff-ffff-ffffffffffff")
	} else {
		if id, err := uuid.Parse(cursorIDStr); err == nil {
			cursorID = id
		} else {
			cursorID = uuid.MustParse("ffffffff-ffff-ffff-ffff-ffffffffffff")
		}
	}

	posts, err := h.svc.GetFollowingFeed(c.Request.Context(), userID, cursorTs, cursorID, limit)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to fetch following feed")
		return
	}
	respond.JSON(c, http.StatusOK, posts)
}

func (h *Handler) GetExploreFeed(c *gin.Context) {
	claims, ok := middleware.ClaimsFromCtx(c.Request.Context())
	if !ok {
		respond.Error(c, http.StatusUnauthorized, "unauthorized")
		return
	}
	userID, _ := uuid.Parse(claims.UserID)

	limitStr := c.Query("limit")
	limit, _ := strconv.Atoi(limitStr)

	categoriesQuery := c.QueryArray("category_id")
	var categoryIDs []uuid.UUID

	for _, cID := range categoriesQuery {
		if id, err := uuid.Parse(cID); err == nil {
			categoryIDs = append(categoryIDs, id)
		}
	}

	posts, err := h.svc.GetExploreFeed(c.Request.Context(), userID, categoryIDs, limit)
	if err != nil {
		respond.Error(c, http.StatusInternalServerError, "failed to fetch explore feed")
		return
	}
	respond.JSON(c, http.StatusOK, posts)
}
