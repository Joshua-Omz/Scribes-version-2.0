import os
import json
import asyncio
import httpx
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent

SCRIBES_API_URL = os.environ.get("SCRIBES_API_URL")
SCRIBES_API_TOKEN = os.environ.get("SCRIBES_API_TOKEN")

if not SCRIBES_API_URL or not SCRIBES_API_TOKEN:
    print("Missing required environment variables: SCRIBES_API_URL and SCRIBES_API_TOKEN", flush=True)
    exit(1)

app = Server("scribes-mcp-server")

@app.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="create_scribes_post",
            description="Creates a new post on the Scribes platform.",
            inputSchema={
                "type": "object",
                "properties": {
                    "title": {
                        "type": "string",
                        "description": "The title of the post."
                    },
                    "excerpt": {
                        "type": "string",
                        "description": "A short plain text excerpt summarizing the post for the feed."
                    },
                    "body": {
                        "type": "string",
                        "description": "The JSON string representation of the rich text body (e.g. Quill operations array). If plain text, it will be wrapped automatically."
                    },
                    "caption": {
                        "type": "string",
                        "description": "Optional caption for the post."
                    },
                    "visibility": {
                        "type": "string",
                        "enum": ["public", "private", "unlisted"],
                        "description": "Visibility setting for the post. Defaults to public."
                    },
                    "sermon_source": {
                        "type": "string",
                        "description": "Optional origin or sermon source for this post."
                    }
                },
                "required": ["title", "excerpt", "body"]
            }
        )
    ]

@app.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    if name != "create_scribes_post":
        raise ValueError(f"Tool not found: {name}")

    title = arguments.get("title", "")
    excerpt = arguments.get("excerpt", "")
    body_str = arguments.get("body", "[]")
    
    caption = arguments.get("caption")
    visibility = arguments.get("visibility")
    sermon_source = arguments.get("sermon_source")

    try:
        body = json.loads(body_str)
        if not isinstance(body, list):
            body = [{"insert": body_str + "\n"}]
    except (json.JSONDecodeError, TypeError):
        body = [{"insert": body_str + "\n"}]

    parsed_content = {
        "title": title,
        "excerpt": excerpt,
        "body": body
    }

    payload = {"content": parsed_content}
    if caption:
        payload["caption"] = caption
    if visibility:
        payload["visibility"] = visibility
    if sermon_source:
        payload["sermon_source"] = sermon_source

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {SCRIBES_API_TOKEN}"
    }

    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{SCRIBES_API_URL}/posts",
                json=payload,
                headers=headers
            )
            response.raise_for_status()
            data = response.json()
            return [TextContent(type="text", text=f"Successfully created Scribes post! Post ID: {data.get('id')}")]
    except httpx.HTTPStatusError as e:
        return [TextContent(type="text", text=f"Failed to create Scribes post: API Error ({e.response.status_code}): {e.response.text}")]
    except Exception as e:
        return [TextContent(type="text", text=f"Failed to create Scribes post: {str(e)}")]

async def main():
    async with stdio_server() as (read_stream, write_stream):
        await app.run(read_stream, write_stream, app.create_initialization_options())

if __name__ == "__main__":
    asyncio.run(main())
