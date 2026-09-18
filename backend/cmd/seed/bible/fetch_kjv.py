import urllib.request
import json
import ssl

# Bypass SSL verification if needed locally
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

url = "https://raw.githubusercontent.com/thiagobodruk/bible/master/json/en_kjv.json"

print("Downloading KJV...")
with urllib.request.urlopen(url, context=ctx) as response:
    raw_data = json.loads(response.read().decode())

print("Parsing KJV...")
books = []
for book in raw_data:
    book_name = book["name"]
    short_name = book["abbrev"].capitalize()
    testament = "old" if len(books) < 39 else "new"
    
    chapters = []
    for c_idx, chapter_verses in enumerate(book["chapters"]):
        verses = []
        for v_idx, verse_text in enumerate(chapter_verses):
            verses.append({
                "verse": v_idx + 1,
                "text": verse_text
            })
        chapters.append({
            "chapter": c_idx + 1,
            "verses": verses
        })
        
    books.append({
        "name": book_name,
        "short_name": short_name,
        "testament": testament,
        "chapters": chapters
    })

output = {
    "translation": {
        "code": "KJV",
        "name": "King James Version",
        "language": "en",
        "attribution_text": "King James Version, Public Domain"
    },
    "books": books
}

print("Saving kjv_seed.json...")
with open("kjv_seed.json", "w", encoding="utf-8") as f:
    json.dump(output, f, ensure_ascii=False)

print("Done! You can now run the Go seeder script to insert this file.")
