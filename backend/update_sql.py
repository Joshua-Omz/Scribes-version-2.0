import os

files_to_update = [
    'backend/internal/db/generated/feed.sql.go',
    'backend/internal/db/generated/recommendation.sql.go',
    'backend/internal/db/generated/search.sql.go'
]

for file in files_to_update:
    path = os.path.join(r'C:\Users\joshu\OneDrive\Documents\300level folder\other stuff\projects\Scribes\Scribes-version-2.0', file)
    if not os.path.exists(path):
        continue
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    content = content.replace(
        'p.cover_image_url, p.reflection_image_url, p.sound_id, p.post_type,\n',
        'p.cover_image_url, p.reflection_image_url, p.sound_id, p.post_type, p.quoted_post_id,\n'
    )
    
    content = content.replace(
        '\tPostType              PostType        `json:"post_type"`\n\tAuthorHandle',
        '\tPostType              PostType        `json:"post_type"`\n\tQuotedPostID          uuid.NullUUID   `json:"quoted_post_id"`\n\tAuthorHandle'
    )
    
    content = content.replace(
        '\t\t\t&i.PostType,\n\t\t\t&i.AuthorHandle,',
        '\t\t\t&i.PostType,\n\t\t\t&i.QuotedPostID,\n\t\t\t&i.AuthorHandle,'
    )

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
