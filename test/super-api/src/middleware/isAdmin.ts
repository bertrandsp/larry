import { Request, Response, NextFunction } from 'express';

/**
 * Admin authentication middleware
 * Checks for valid admin token in Authorization header
 */
export function isAdmin(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  
  if (!authHeader) {
    return res.status(401).json({ 
      error: 'Unauthorized - Admin access required',
      message: 'Missing Authorization header'
    });
  }

  // Extract token from "Bearer <token>" format
  const token = authHeader.replace('Bearer ', '');
  const adminSecret = process.env.ADMIN_SECRET || 'admin-secret-key';

  if (token !== adminSecret) {
    return res.status(401).json({ 
      error: 'Unauthorized - Admin access required',
      message: 'Invalid admin token'
    });
  }

  // Add admin info to request for logging
  (req as any).adminUser = {
    id: 'admin',
    role: 'admin',
    timestamp: new Date().toISOString()
  };

  next();
}

/**
 * Optional admin middleware (doesn't fail if no token)
 * Useful for endpoints that work for both admin and regular users
 */
export function optionalAdmin(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  
  if (authHeader) {
    const token = authHeader.replace('Bearer ', '');
    const adminSecret = process.env.ADMIN_SECRET || 'admin-secret-key';
    
    if (token === adminSecret) {
      (req as any).adminUser = {
        id: 'admin',
        role: 'admin',
        timestamp: new Date().toISOString()
      };
    }
  }
  
  next();
}

