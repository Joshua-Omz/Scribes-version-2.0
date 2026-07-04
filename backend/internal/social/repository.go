package social

import (
	"context"
	"database/sql"
	"encoding/json"
	"time"

	"scribes-api/internal/db/generated"

	"github.com/google/uuid"
)

type Repository struct {
	q *generated.Queries
}

func NewRepository(q *generated.Queries, db *sql.DB) *Repository {
	return &Repository{q: q}
}

// ── Follows ────────────────────────────────────

func (r *Repository) FollowUser(ctx context.Context, followerID, followeeID uuid.UUID) error {
	return r.q.FollowUser(ctx, generated.FollowUserParams{
		FollowerID: followerID,
		FolloweeID: followeeID,
	})
}

func (r *Repository) UnfollowUser(ctx context.Context, followerID, followeeID uuid.UUID) error {
	return r.q.UnfollowUser(ctx, generated.UnfollowUserParams{
		FollowerID: followerID,
		FolloweeID: followeeID,
	})
}

// ── Reactions ──────────────────────────────────

func (r *Repository) UpsertReaction(ctx context.Context, postID, userID uuid.UUID, reactionType generated.ReactionType) error {
	return r.q.UpsertReaction(ctx, generated.UpsertReactionParams{
		PostID: postID,
		UserID: userID,
		Type:   reactionType,
	})
}

func (r *Repository) DeleteReaction(ctx context.Context, postID, userID uuid.UUID) error {
	return r.q.DeleteReaction(ctx, generated.DeleteReactionParams{
		PostID: postID,
		UserID: userID,
	})
}

func (r *Repository) GetReactionCounts(ctx context.Context, postID uuid.UUID) ([]generated.GetReactionCountsRow, error) {
	return r.q.GetReactionCounts(ctx, postID)
}

// ── Comments ───────────────────────────────────

func (r *Repository) CreateComment(ctx context.Context, postID, authorID uuid.UUID, body string, mentions []uuid.UUID) (generated.Comment, error) {
	return r.q.CreateComment(ctx, generated.CreateCommentParams{
		PostID:   postID,
		AuthorID: authorID,
		Body:     body,
		Mentions: mentions,
	})
}

func (r *Repository) HideComment(ctx context.Context, commentID uuid.UUID) error {
	return r.q.HideComment(ctx, commentID)
}

func (r *Repository) DeleteComment(ctx context.Context, commentID, authorID uuid.UUID) error {
	return r.q.DeleteComment(ctx, generated.DeleteCommentParams{
		ID:       commentID,
		AuthorID: authorID,
	})
}

func (r *Repository) GetCommentsByPost(ctx context.Context, postID uuid.UUID) ([]generated.Comment, error) {
	return r.q.GetCommentsByPost(ctx, postID)
}

func (r *Repository) GetCommentByID(ctx context.Context, commentID uuid.UUID) (generated.Comment, error) {
	return r.q.GetCommentByID(ctx, commentID)
}

// ── Saved ──────────────────────────────────────

func (r *Repository) SavePost(ctx context.Context, userID, postID uuid.UUID, savedType generated.SavedType, snapshot json.RawMessage) error {
	return r.q.SavePost(ctx, generated.SavePostParams{
		UserID:   userID,
		PostID:   postID,
		Type:     savedType,
		Snapshot: snapshot, // Since sqlc treats JSONB as []byte or json.RawMessage
	})
}

func (r *Repository) UnsavePost(ctx context.Context, userID, postID uuid.UUID, savedType generated.SavedType) error {
	return r.q.UnsavePost(ctx, generated.UnsavePostParams{
		UserID: userID,
		PostID: postID,
		Type:   savedType,
	})
}

type SavedPostWithContent struct {
	Saved   generated.Saved
	Content json.RawMessage
	Caption *string
}

func (r *Repository) ListSavedPosts(ctx context.Context, userID uuid.UUID, savedType generated.SavedType) ([]generated.ListSavedPostsRow, error) {
	return r.q.ListSavedPosts(ctx, generated.ListSavedPostsParams{
		UserID: userID,
		Type:   savedType,
	})
}
