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
                    "content": {
                        "type": "string",
                        "description": "The JSON string representation of the post content (e.g. rich text payload)."
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
                "required": ["content"]
            }
        )
    ]

@app.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    if name != "create_scribes_post":
        raise ValueError(f"Tool not found: {name}")

    content = arguments.get("content")
    caption = arguments.get("caption")
    visibility = arguments.get("visibility")
    sermon_source = arguments.get("sermon_source")

    try:
        parsed_content = json.loads(content)
    except (json.JSONDecodeError, TypeError):
        parsed_content = {"text": content}

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
