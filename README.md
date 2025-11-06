# n8n MCP + Claude Code Docker Setup

This repository contains a **sandboxed Docker environment** where both the n8n MCP server and an MCP client run together, completely isolated in Docker containers.

## Architecture

- **n8n-mcp**: MCP server that provides n8n workflow management via Model Context Protocol
- **mcp-client**: MCP client that communicates with n8n-mcp over HTTP
- Both services run on the same Docker network and communicate internally

## Setup

### Prerequisites

- Docker and Docker Compose installed
- An n8n instance running (either locally or remote)
- Your `.env` file configured with n8n credentials

### Quick Start

1. **Ensure your `.env` file is configured**:

```bash
N8N_API_URL=https://your-n8n-instance.com/api/v1
N8N_API_KEY=your-api-key-here
ANTHROPIC_API_KEY=your-anthropic-api-key  # Optional, for Claude API integration
LOG_LEVEL=info
DISABLE_CONSOLE_OUTPUT=false
N8N_MCP_TELEMETRY_DISABLED=true
```

2. **Start both services**:

```bash
docker-compose up -d
```

3. **Check status**:

```bash
docker-compose ps
```

4. **View logs**:

```bash
# View all logs
docker-compose logs -f

# View n8n-mcp logs
docker-compose logs -f n8n-mcp

# View mcp-client logs
docker-compose logs -f mcp-client
```

## Services

### n8n-mcp Service

- **Image**: `ghcr.io/czlonkowski/n8n-mcp:latest`
- **Port**: 3000 (exposed to host)
- **Mode**: HTTP (for inter-container communication)
- **Network**: `claude-n8n-network`

### mcp-client Service

- **Image**: `node:20-alpine` (with MCP SDK)
- **Purpose**: MCP client that connects to n8n-mcp
- **Network**: `claude-n8n-network`
- **Depends on**: n8n-mcp service

## Usage

### Running Claude Code in Docker

To run Claude Code in Docker and connect it to the n8n-mcp network:

```bash
docker run -it \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  -v $(pwd)/workspace:/workspace \
  -v $(pwd)/claude-code-config:/root/.config/claude-code \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --network claude-n8n_claude-n8n-network \
  claude-code \
  claude  # ← Just "claude", not "claude-code"
```

### Accessing n8n-mcp HTTP API

The n8n-mcp server is accessible at:
- **From host**: `http://localhost:3001`
- **From other containers**: `http://n8n-mcp:3000`

### Interacting with the Services

You can interact with the services in several ways:

1. **Execute commands in containers**:

```bash
# Execute command in mcp-client
docker-compose exec mcp-client sh

# Execute command in n8n-mcp
docker-compose exec n8n-mcp sh
```

2. **Access HTTP endpoints** (when in HTTP mode):

```bash
# Health check
curl http://localhost:3000/health

# List available tools
curl http://localhost:3000/tools
```

3. **View real-time logs**:

```bash
docker-compose logs -f
```

## Switching to stdio Mode

If you prefer stdio mode instead of HTTP mode:

1. Edit `docker-compose.yml`:
   - Comment out the `ports` section for n8n-mcp
   - Change `MCP_MODE=http` to `MCP_MODE=stdio`
   - Remove `PORT=3000`
   - Uncomment `stdin_open: true` and `tty: true`

2. Update the mcp-client to use stdio transport instead of HTTP

## Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs

# Check container status
docker-compose ps

# Restart services
docker-compose restart
```

### Connection issues

```bash
# Verify network connectivity
docker-compose exec mcp-client ping n8n-mcp

# Check if n8n-mcp is listening
docker-compose exec n8n-mcp netstat -tlnp
```

### Health check failures

```bash
# Check n8n-mcp health
curl http://localhost:3000/health

# View detailed logs
docker-compose logs n8n-mcp
```

## Environment Variables

- `N8N_API_URL`: URL of your n8n instance (required)
- `N8N_API_KEY`: API key for n8n authentication (required)
- `MCP_MODE`: Either `stdio` or `http` (default: `http` for Docker)
- `PORT`: Port for HTTP mode (default: `3000`)
- `LOG_LEVEL`: Logging level - `debug`, `info`, `warn`, `error` (default: `info`)
- `DISABLE_CONSOLE_OUTPUT`: Disable console output (default: `false`)
- `N8N_MCP_TELEMETRY_DISABLED`: Disable telemetry (default: `false`)
- `ANTHROPIC_API_KEY`: Anthropic API key (optional, for Claude integration)

## Network

Both services run on a custom Docker network (`claude-n8n-network`) for secure internal communication.

## Stopping Services

```bash
# Stop services
docker-compose stop

# Stop and remove containers
docker-compose down

# Stop, remove containers, and remove volumes
docker-compose down -v
```
