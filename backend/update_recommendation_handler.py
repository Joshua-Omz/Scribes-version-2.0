import re
import os

path = r'C:\Users\joshu\OneDrive\Documents\300level folder\other stuff\projects\Scribes\Scribes-version-2.0\backend\internal\recommendation\handler.go'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add QuotedPostID to RecommendationResponse
content = content.replace(
    "\tPostType        string      `json:\"post_type\"`\n",
    "\tPostType        string      `json:\"post_type\"`\n\tQuotedPostID    *string     `json:\"quoted_post_id,omitempty\"`\n"
)

# Add mapping logic to GetRecommendations and GetSimilarPosts
mapping_logic = """
		var quotedPostID *string
		if p.QuotedPostID.Valid {
			qpID := p.QuotedPostID.UUID.String()
			quotedPostID = &qpID
		}
"""

content = content.replace(
    "		mapped = append(mapped, RecommendationResponse{",
    mapping_logic + "\t\tmapped = append(mapped, RecommendationResponse{"
)

content = content.replace(
    "			PostType:        string(p.PostType),\n",
    "			PostType:        string(p.PostType),\n\t\t\tQuotedPostID:    quotedPostID,\n"
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
