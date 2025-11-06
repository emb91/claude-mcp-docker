FROM node:20-alpine

# Install dependencies
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++

# Set working directory
WORKDIR /app

# Clone and build n8n-mcp
RUN git clone https://github.com/czlonkowski/n8n-mcp.git . && \
    npm install && \
    npm run build

# Expose port for HTTP mode (optional)
EXPOSE 3000

# Set environment variables
ENV NODE_ENV=production
ENV MCP_MODE=stdio
ENV LOG_LEVEL=info

# Run n8n-mcp
CMD ["node", "dist/index.js"]

