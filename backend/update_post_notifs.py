import re

path = r'C:\Users\joshu\OneDrive\Documents\300level folder\other stuff\projects\Scribes\Scribes-version-2.0\backend\internal\post\service.go'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# For Create
create_notif_logic = """
	if post.QuotedPostID != nil && s.notif != nil {
		quotedPost, err := s.Get(ctx, *post.QuotedPostID)
		if err == nil {
			s.notif.Enqueue(notification.Event{
				Type:        notification.NotifTypeQuote,
				RecipientID: quotedPost.AuthorID,
				RefID:       post.ID,
				ActorID:     authorID,
			})
		}
	}
"""

content = content.replace(
    "	return post, nil\n}",
    create_notif_logic + "\treturn post, nil\n}"
)

# For CreateCorrection
correction_tx_logic = """
	post, err := s.repo.CreateCorrectionPostTx(ctx, CreateCorrectionPostTxParams{
		AuthorID:       authorID,
		Content:        input.Content,
		Caption:        input.Caption,
		Visibility:     visibility,
		SermonSource:   input.SermonSource,
		CorrectsPostID: correctsPostID,
		CoverImageUrl:  input.CoverImageUrl,
		PostType:       postType,
		QuotedPostID:   input.QuotedPostID,
		Tags:           input.Tags,
		ScriptureRefs:  refsParams,
	})
	if err != nil {
		return Post{}, err
	}

	if post.QuotedPostID != nil && s.notif != nil {
		quotedPost, err := s.Get(ctx, *post.QuotedPostID)
		if err == nil {
			s.notif.Enqueue(notification.Event{
				Type:        notification.NotifTypeQuote,
				RecipientID: quotedPost.AuthorID,
				RefID:       post.ID,
				ActorID:     authorID,
			})
		}
	}

	return post, nil
"""

content = re.sub(
    r"\s*return s\.repo\.CreateCorrectionPostTx\([^}]+}\)\s*}",
    correction_tx_logic + "\n}",
    content
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
