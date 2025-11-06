FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Copy config into container
COPY claude_config.json /root/.claude/claude_desktop_config.json

# Default command: op