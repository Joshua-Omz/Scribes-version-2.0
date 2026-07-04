package social

import (
	"context"
	"encoding/json"
	"errors"

	"scribes-api/internal/db/generated"
	"scribes-api/internal/post"

	"github.com/google/uuid"
)

type Service struct {
	repo     *Repository
	postRepo *post.Repository
}

func NewService(repo *Repository, postRepo *post.Repository) *Service {
	return &Service{
		repo:     repo,
		postRepo: postRepo,
	}
}

// Follows
func (s *Service) Follow(ctx context.Context, followerID, followeeID uuid.UUID) error {
	if followerID == followeeID {
		return errors.New("cannot follow yourself")
	}
	return s.repo.FollowUser(ctx, followerID, followeeID)
}

func (s *Service) Unfollow(ctx context.Context, followerID, followeeID uuid.UUID) error {
	return s.repo.UnfollowUser(ctx, followerID, followeeID)
}

// Reactions
func (s *Service) React(ctx context.Context, postID, userID uuid.UUID, reactionType string) error {
	return s.repo.UpsertReaction(ctx, postID, userID, generated.ReactionType(reactionType))
}

func (s *Service) Unreact(ctx context.Context, postID, userID uuid.UUID) error {
	return s.repo.DeleteReaction(ctx, postID, userID)
}

// Comments
func (s *Service) AddComment(ctx context.Context, postID, authorID uuid.UUID, body string, mentions []uuid.UUID) (generated.Comment, error) {
	return s.repo.CreateComment(ctx, postID, authorID, body, mentions)
}

func (s *Service) DeleteComment(ctx context.Context, commentID, authorID uuid.UUID) error {
	// The repository naturally checks authorID matching in the WHERE clause
	return s.repo.DeleteComment(ctx, commentID, authorID)
}

func (s *Service) HideComment(ctx context.Context, commentID, userID uuid.UUID) error {
	// Only the POST author can hide a comment on their post.
	comment, err := s.repo.GetCommentByID(ctx, commentID)
	if err != nil {
		return err
	}

	p, err := s.postRepo.GetPostByID(ctx, comment.PostID)
	if err != nil {
		return err
	}

	if p.AuthorID != userID {
		return errors.New("only the post author can hide comments")
	}

	return s.repo.HideComment(ctx, commentID)
}

func (s *Service) GetComments(ctx context.Context, postID uuid.UUID) ([]generated.Comment, error) {
	comments, err := s.repo.GetCommentsByPost(ctx, postID)
	if err != nil {
		return nil, err
	}

	// Apply view masking as defined by architecture
	for i, c := range comments {
		if c.IsHidden {
			comments[i].Body = "[Response hidden by author]"
			comments[i].Mentions = nil
		}
		if c.IsDeleted {
			comments[i].Body = "[Response removed]"
			comments[i].Mentions = nil
		}
	}
	return comments, nil
}

// Saved
func (s *Service) SavePost(ctx context.Context, userID, postID uuid.UUID, savedType string) error {
	var snapshot json.RawMessage
	if savedType == string(generated.SavedTypeImport) {
		postData, err := s.postRepo.GetPostByID(ctx, postID)
		if err != nil {
			return err
		}
		snapshot = postData.Content
	}
	return s.repo.SavePost(ctx, userID, postID, generated.SavedType(savedType), snapshot)
}

func (s *Service) UnsavePost(ctx context.Context, userID, postID uuid.UUID, savedType string) error {
	return s.repo.UnsavePost(ctx, userID, postID, generated.SavedType(savedType))
}
