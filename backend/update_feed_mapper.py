import re
import os

path = r'C:\Users\joshu\OneDrive\Documents\300level folder\other stuff\projects\Scribes\Scribes-version-2.0\backend\internal\feed\repository.go'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add QuotedPostID mapping logic for each mapper function
block = """
	var quotedPostID *uuid.UUID
	if row.QuotedPostID.Valid {
		quotedPostID = &row.QuotedPostID.UUID
	}
"""

content = content.replace("	return FeedPost{", block + "\treturn FeedPost{")
content = content.replace(
    "		PostType:              row.PostType,\n",
    "		PostType:              row.PostType,\n\t\tQuotedPostID:          quotedPostID,\n"
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
