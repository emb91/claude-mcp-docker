FROM node:20-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3 \
    python3-pip \
    build-essential \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code globally
# Note: May not be publicly available yet
RUN npm install -g @anthropic-ai/claude-code || \
    npm install -g claude-code || \
    echo "⚠️  Claude Code not found - will need manual installation"

# Create directories
RUN mkdir -p /workspace /root/.config/claude-code

WORKDIR /workspace

CMD ["tail", "-f", "/dev/null"]
