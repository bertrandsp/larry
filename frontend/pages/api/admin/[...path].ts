import { NextApiRequest, NextApiResponse } from 'next';
import axios from 'axios';

// Proxy admin API requests to the backend
export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { path } = req.query;
  
  // Reconstruct the path
  const apiPath = Array.isArray(path) ? path.join('/') : path;
  
  // Get the backend URL
  const backendUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4001';
  const targetUrl = `${backendUrl}/admin/${apiPath}`;
  
  try {
    // Forward the request to the backend
    const response = await axios({
      method: req.method,
      url: targetUrl,
      data: req.body,
      headers: {
        ...req.headers,
        host: undefined, // Remove host header
      },
      params: req.query,
    });
    
    // Forward the response back to the frontend
    res.status(response.status).json(response.data);
  } catch (error: any) {
    console.error('Admin API proxy error:', error);
    
    if (error.response) {
      // Forward the error response from the backend
      res.status(error.response.status).json(error.response.data);
    } else {
      // Handle network or other errors
      res.status(500).json({ 
        error: 'Internal server error',
        message: error.message 
      });
    }
  }
}

