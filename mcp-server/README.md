# Scribes MCP Server (Python)

This is a Model Context Protocol (MCP) server written in Python. It connects your AI assistant to the Scribes API hosted on Railway, allowing the AI to automatically create posts in your database.

## Prerequisites
- `uv` (recommended) or Python 3.10+
- A running instance of your Scribes API on Railway
- A valid JWT token for an authorized user on your API

## Setup
If using standard python:
1. Open a terminal in this directory (`mcp-server/`).
2. Run `python -m venv .venv`
3. Run `.venv\Scripts\pip install -r requirements.txt` (Windows) or `source .venv/bin/activate && pip install -r requirements.txt` (Mac/Linux)

If using `uv` (faster and simpler), no setup is required as Claude can run it dynamically via `uvx`.

## Connecting to Claude Desktop
To hook this tool up to Claude Desktop, edit your config file:

**Mac:** `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows:** `%APPDATA%\Claude\claude_desktop_config.json`

Add the following to the configuration:

### Using `uv` (Recommended)
```json
{
  "mcpServers": {
    "scribes": {
      "command": "uv",
      "args": [
        "run",
        "--with",
        "mcp",
        "--with",
        "httpx",
        "C:/absolute/path/to/Scribes-version-2.0/mcp-server/main.py"
      ],
      "env": {
        "SCRIBES_API_URL": "https://your-app-url.up.railway.app",
        "SCRIBES_API_TOKEN": "your-jwt-token-here"
      }
    }
  }
}
```

### Using standard Python
```json
{
  "mcpServers": {
    "scribes": {
      "command": "C:/absolute/path/to/Scribes-version-2.0/mcp-server/.venv/Scripts/python.exe",
      "args": [
        "C:/absolute/path/to/Scribes-version-2.0/mcp-server/main.py"
      ],
      "env": {
        "SCRIBES_API_URL": "https://your-app-url.up.railway.app",
        "SCRIBES_API_TOKEN": "your-jwt-token-here"
      }
    }
  }
}
```

*(Make sure to replace the paths, URL, and token with your real values!)*

Restart Claude Desktop, and you'll see a new hammer icon showing the `create_scribes_post` tool is active.
