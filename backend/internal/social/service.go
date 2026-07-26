package social

import (
	"context"
	"encoding/json"
	"errors"

	"scribes-api/internal/db/generated"
	"scribes-api/internal/notification"
	"scribes-api/internal/post"

	"github.com/google/uuid"
)

type NotificationEnqueuer interface {
	Enqueue(event notification.Event)
}

type Service struct {
	repo     *Repository
	postRepo *post.Repository
	notif    NotificationEnqueuer
}

func NewService(repo *Repository, postRepo *post.Repository, notif NotificationEnqueuer) *Service {
	return &Service{
		repo:     repo,
		postRepo: postRepo,
		notif:    notif,
	}
}

// Follows
func (s *Service) Follow(ctx context.Context, followerID, followeeID uuid.UUID) error {
	if followerID == followeeID {
		return errors.New("cannot follow yourself")
	}
	err := s.repo.FollowUser(ctx, followerID, followeeID)
	if err == nil && s.notif != nil {
		s.notif.Enqueue(notification.Event{
			Type:        notification.NotifTypeFollow,
			RecipientID: followeeID,
			RefID:       followerID, // The ref for a follow is the follower
			IsRealtime:  true,
			ActorID:     followerID,
		})
	}
	return err
}

func (s *Service) Unfollow(ctx context.Context, followerID, followeeID uuid.UUID) error {
	return s.repo.UnfollowUser(ctx, followerID, followeeID)
}

func (s *Service) IsFollowing(ctx context.Context, followerID, followeeID uuid.UUID) (bool, error) {
	return s.repo.CheckIsFollowing(ctx, followerID, followeeID)
}

func (s *Service) GetFollowers(ctx context.Context, userID uuid.UUID) ([]generated.GetFollowersRow, error) {
	return s.repo.GetFollowers(ctx, userID)
}

func (s *Service) GetFollowing(ctx context.Context, userID uuid.UUID) ([]generated.GetFollowingRow, error) {
	return s.repo.GetFollowing(ctx, userID)
}

// Reactions
func (s *Service) React(ctx context.Context, postID, userID uuid.UUID, reactionType string) error {
	err := s.repo.UpsertReaction(ctx, postID, userID, generated.ReactionType(reactionType))
	if err == nil && s.notif != nil {
		p, errP := s.postRepo.GetPostByID(ctx, postID)
		if errP == nil && p.AuthorID != userID {
			s.notif.Enqueue(notification.Event{
				Type:        notification.NotifTypeReaction,
				RecipientID: p.AuthorID,
				RefID:       postID,
				IsRealtime:  true,
				ActorID:     userID,
			})
		}
	}
	return err
}

func (s *Service) Unreact(ctx context.Context, postID, userID uuid.UUID) error {
	return s.repo.DeleteReaction(ctx, postID, userID)
}

func (s *Service) GetReactionCounts(ctx context.Context, postID uuid.UUID) ([]generated.GetReactionCountsRow, error) {
	return s.repo.GetReactionCounts(ctx, postID)
}

// Comments
func (s *Service) AddComment(ctx context.Context, postID, authorID uuid.UUID, body string, mentions []uuid.UUID) (generated.Comment, error) {
	comment, err := s.repo.CreateComment(ctx, postID, authorID, body, mentions)
	if err == nil && s.notif != nil {
		p, errP := s.postRepo.GetPostByID(ctx, postID)
		if errP == nil && p.AuthorID != authorID {
			s.notif.Enqueue(notification.Event{
				Type:        notification.NotifTypeComment,
				RecipientID: p.AuthorID,
				RefID:       postID,
				IsRealtime:  true,
				ActorID:     authorID,
			})
		}
		
		// Handle mentions
		for _, m := range mentions {
			if m != authorID { // don't notify self
				s.notif.Enqueue(notification.Event{
					Type:        notification.NotifTypeMention,
					RecipientID: m,
					RefID:       postID,
					IsRealtime:  true,
					ActorID:     authorID,
				})
			}
		}
	}
	return comment, err
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

func (s *Service) GetSavedPosts(ctx context.Context, userID uuid.UUID, savedType string) ([]generated.ListSavedPostsRow, error) {
	return s.repo.ListSavedPosts(ctx, userID, generated.SavedType(savedType))
}
