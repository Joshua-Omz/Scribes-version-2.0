import re

path = r'C:\Users\joshu\OneDrive\Documents\300level folder\other stuff\projects\Scribes\Scribes-version-2.0\backend\internal\post\service.go'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove wrong notification logic
wrong_logic_pattern = r"\n\s*if post\.QuotedPostID != nil && s\.notif != nil {[\s\S]*?ActorID:\s*authorID,[\s\S]*?}\n\s*}\n"
content = re.sub(wrong_logic_pattern, "\n", content)

# I should manually add the logic at the end of Create and CreateCorrection.
# For Create:
create_regex = r"(return s\.repo\.CreatePostTx\([\s\S]*?}\))"
create_repl = r"""post, err := \1
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

	return post, nil"""

# Replace in Create function
content = re.sub(r"(return s\.repo\.CreatePostTx\([^}]+}\))", create_repl, content, count=1)


with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
