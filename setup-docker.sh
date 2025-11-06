#!/bin/bash

set -e

echo "🚀 Setting up Claude Code with N8N MCP..."

# Create directories
mkdir -p workspace claude-code-config claude-code-docker

# Build Claude Code image
echo "🔨 Building Claude Code image..."
docker build -t claude-code-custom ./claude-code-docker

# Pull N8N MCP image
echo "📦 Pulling N8N MCP image..."
docker pull ghcr.io/czlonkowski/n8n-mcp:latest

# Start services
echo "🐳 Starting containers..."
docker-compose -f docker-compose-with-claude.yml up -d

echo ""
echo "✅ Setup complete!"
echo ""
echo "Access Claude Code:"
echo "  docker-compose -f docker-compose-with-claude.yml exec claude-code bash"
echo "  Then: claude-code"