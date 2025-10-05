import express from 'express';
import { WebSocketServer } from 'ws';
import { createServer } from 'http';
import { PrismaClient } from '@prisma/client';

const router = express.Router();
const prisma = new PrismaClient();

// Store active connections
const activeConnections = new Map<string, WebSocket>();

// WebSocket message types
interface WebSocketMessage {
  type: string;
  data: Record<string, any>;
  timestamp: string;
}

interface WebSocketResponse {
  type: string;
  data: Record<string, any>;
  timestamp: string;
}

/**
 * WebSocket endpoint for real-time updates
 * Handles new word notifications and other real-time events
 */
export function setupWebSocketServer(server: any) {
  const wss = new WebSocketServer({ server, path: '/ws' });

  wss.on('connection', (ws, req) => {
    console.log('🔌 New WebSocket connection established');
    
    let userId: string | null = null;
    
    ws.on('message', async (data) => {
      try {
        const message: WebSocketMessage = JSON.parse(data.toString());
        console.log(`📨 WebSocket message received: ${message.type}`);
        
        switch (message.type) {
          case 'subscribe':
            userId = message.data.userId;
            if (userId) {
              activeConnections.set(userId, ws);
              console.log(`👤 User ${userId} subscribed to real-time updates`);
              
              // Send connection confirmation
              sendMessage(ws, {
                type: 'connection_established',
                data: { userId, message: 'Connected to real-time updates' },
                timestamp: new Date().toISOString()
              });
            }
            break;
            
          case 'unsubscribe':
            if (userId) {
              activeConnections.delete(userId);
              console.log(`👤 User ${userId} unsubscribed from real-time updates`);
            }
            break;
            
          case 'heartbeat':
            // Respond to heartbeat
            sendMessage(ws, {
              type: 'heartbeat',
              data: { status: 'alive' },
              timestamp: new Date().toISOString()
            });
            break;
            
          default:
            console.log(`❓ Unknown message type: ${message.type}`);
        }
      } catch (error) {
        console.error('❌ Error processing WebSocket message:', error);
        sendMessage(ws, {
          type: 'error',
          data: { error: 'Invalid message format' },
          timestamp: new Date().toISOString()
        });
      }
    });
    
    ws.on('close', () => {
      console.log('🔌 WebSocket connection closed');
      if (userId) {
        activeConnections.delete(userId);
        console.log(`👤 User ${userId} disconnected`);
      }
    });
    
    ws.on('error', (error) => {
      console.error('❌ WebSocket error:', error);
      if (userId) {
        activeConnections.delete(userId);
      }
    });
    
    // Send initial connection message
    sendMessage(ws, {
      type: 'connection_established',
      data: { message: 'Welcome to Larry real-time updates' },
      timestamp: new Date().toISOString()
    });
  });

  console.log('🔌 WebSocket server setup complete');
  return wss;
}

/**
 * Notify a specific user that new words are available
 */
export async function notifyUserNewWords(userId: string) {
  const ws = activeConnections.get(userId);
  
  if (ws && ws.readyState === ws.OPEN) {
    console.log(`📢 Notifying user ${userId} of new words`);
    
    sendMessage(ws, {
      type: 'new_words_available',
      data: { 
        message: 'New vocabulary words are ready!',
        timestamp: new Date().toISOString()
      },
      timestamp: new Date().toISOString()
    });
  } else {
    console.log(`⚠️ User ${userId} not connected or connection closed`);
  }
}

/**
 * Notify all connected users of system updates
 */
export function notifyAllUsers(type: string, data: Record<string, any>) {
  const message: WebSocketResponse = {
    type,
    data,
    timestamp: new Date().toISOString()
  };
  
  console.log(`📢 Broadcasting to ${activeConnections.size} connected users: ${type}`);
  
  activeConnections.forEach((ws, userId) => {
    if (ws.readyState === ws.OPEN) {
      sendMessage(ws, message);
    } else {
      // Clean up closed connections
      activeConnections.delete(userId);
    }
  });
}

/**
 * Send a message to a WebSocket connection
 */
function sendMessage(ws: WebSocket, message: WebSocketResponse) {
  try {
    ws.send(JSON.stringify(message));
  } catch (error) {
    console.error('❌ Error sending WebSocket message:', error);
  }
}

/**
 * Get connection statistics
 */
export function getConnectionStats() {
  return {
    activeConnections: activeConnections.size,
    connectedUsers: Array.from(activeConnections.keys())
  };
}

/**
 * Health check endpoint for WebSocket service
 */
router.get('/ws/health', (req, res) => {
  const stats = getConnectionStats();
  res.json({
    status: 'ok',
    websocket: {
      active: true,
      connections: stats.activeConnections,
      users: stats.connectedUsers
    }
  });
});

export default router;
