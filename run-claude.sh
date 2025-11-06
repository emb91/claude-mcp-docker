#!/bin/bash
# Script to run Claude Code in Docker and connect to n8n-mcp network

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting Claude Code in Docker...${NC}"

# Check if .env file exists and load it
if [ -f .env ]; then
    echo -e "${YELLOW}📝 Loading environment variables from .env file...${NC}"
    export $(cat .env | grep -v '^#' | grep ANTHROPIC_API_KEY | xargs)
fi

# Check if ANTHROPIC_API_KEY is set
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo -e "${RED}❌ ERROR: ANTHROPIC_API_KEY is not set${NC}"
    echo "Please set it in your .env file or export it:"
    echo "  export ANTHROPIC_API_KEY=your-key-here"
    exit 1
fi

# Check if docker-compose network exists
NETWORK_NAME="claude-n8n_claude-n8n-network"
if ! docker network inspect "$NETWORK_NAME" > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Network '$NETWORK_NAME' not found.${NC}"
    echo -e "${YELLOW}   Starting docker-compose services first...${NC}"
    docker-compose up -d
    sleep 3
fi

# Create workspace directory if it doesn't exist
mkdir -p workspace

# Create claude-code-config directory if it doesn't exist
mkdir -p claude-code-config

# Check if claude-code image exists
if ! docker images | grep -q "^claude-code"; then
    echo -e "${YELLOW}⚠️  Claude Code Docker image not found.${NC}"
    echo -e "${YELLOW}   Building it first...${NC}"
    cd claude-code-docker
    docker build -t claude-code .
    cd ..
fi

echo -e "${GREEN}✅ Starting Claude Code container...${NC}"
echo ""

# Run Claude Code in Docker
docker run -it \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  -v "$(pwd)/workspace:/workspace" \
  -v "$(pwd)/claude-code-config:/root/.config/claude-code" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --network "$NETWORK_NAME" \
  claude-code \
  claude  # ← Just "claude", not "claude-code"

