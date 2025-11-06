#!/usr/bin/env node

/**
 * MCP Client that communicates with n8n-mcp server
 * This client connects to n8n-mcp via HTTP and provides an interface
 * for interacting with n8n workflows through MCP protocol
 */

import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import fetch from 'node-fetch';

const MCP_SERVER_URL = process.env.MCP_SERVER_URL || 'http://n8n-mcp:3000';
const AUTH_TOKEN = process.env.AUTH_TOKEN || '';

console.log('🚀 Starting MCP Client...');
console.log(`📡 Connecting to n8n-mcp at: ${MCP_SERVER_URL}`);

// Health check function
async function checkHealth() {
  try {
    const headers = {};
    if (AUTH_TOKEN) {
      headers['Authorization'] = `Bearer ${AUTH_TOKEN}`;
    }
    const response = await fetch(`${MCP_SERVER_URL}/health`, { headers });
    if (response.ok) {
      console.log('✅ n8n-mcp server is healthy');
      return true;
    }
  } catch (error) {
    console.error('❌ n8n-mcp server health check failed:', error.message);
    return false;
  }
}

// Main function
async function main() {
  // Wait for n8n-mcp to be ready
  console.log('⏳ Waiting for n8n-mcp server...');
  let retries = 30;
  while (retries > 0) {
    if (await checkHealth()) {
      break;
    }
    await new Promise(resolve => setTimeout(resolve, 1000));
    retries--;
  }

  if (retries === 0) {
    console.error('❌ Failed to connect to n8n-mcp server');
    process.exit(1);
  }

  console.log('✅ Connected to n8n-mcp server');
  console.log('📝 MCP Client is ready. Use the MCP protocol to interact with n8n workflows.');
  console.log('💡 This client can be extended to provide a CLI or API interface.');

  // Keep the process alive
  process.stdin.resume();
}

main().catch(console.error);

