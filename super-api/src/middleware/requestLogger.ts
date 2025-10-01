import { Request, Response, NextFunction } from "express";
import logger from "../utils/logger";
import {
  incrementDatabaseOperation,
  recordDatabaseDuration,
  incrementOpenAiRequest,
} from "../metrics/metrics";
import { ServerResponse } from "http";

/**
 * Request logging middleware
 */
export function requestLogger(
  req: Request,
  res: Response,
  next: NextFunction,
) {
  const startTime = Date.now();
  const { method, url, ip, headers } = req;

  // Log the incoming request
  logger.info("Incoming request", {
    method,
    url,
    ip,
    userAgent: headers["user-agent"],
    timestamp: new Date().toISOString(),
  });

  // Override res.end to log the response
  const originalEnd = res.end.bind(res) as ServerResponse["end"];
  res.end = function (...args: Parameters<ServerResponse["end"]>) {
    const responseTime = Date.now() - startTime;
    logger.info("HTTP Request Completed", {
      status: res.statusCode,
      responseTime,
    });
    return originalEnd(...args);
  } as any;

  next();
}

/**
 * Database operation logging wrapper
 */
export function withDatabaseLogging<T extends any[], R>(
  operation: string,
  table: string,
  fn: (...args: T) => Promise<R>,
) {
  return async (...args: T): Promise<R> => {
    const startTime = Date.now();

    try {
      const result = await fn(...args);
      const duration = Date.now() - startTime;

      // Log successful operation
      logger.info("Database operation completed", {
        operation,
        table,
        duration: `${duration}ms`,
        status: "success",
      });

      // Record metrics
      incrementDatabaseOperation(operation, table, "success");
      recordDatabaseDuration(operation, table, duration / 1000);

      return result;
    } catch (error: any) {
      const duration = Date.now() - startTime;

      // Log failed operation
      logger.error("Database operation failed", {
        operation,
        table,
        duration: `${duration}ms`,
        status: "failure",
        error: error.message,
      });

      // Record metrics
      incrementDatabaseOperation(operation, table, "failure");
      recordDatabaseDuration(operation, table, duration / 1000);

      throw error;
    }
  };
}

/**
 * OpenAI request logging wrapper
 */
export function withOpenAiLogging<T extends any[], R>(
  promptType: string,
  model: string,
  fn: (...args: T) => Promise<R>,
) {
  return async (...args: T): Promise<R> => {
    const startTime = Date.now();

    try {
      // Log request start
      logger.info("OpenAI request started", {
        promptType,
        model,
        timestamp: new Date().toISOString(),
      });

      incrementOpenAiRequest(promptType, model, "success");

      const result = await fn(...args);
      const duration = Date.now() - startTime;

      // Log successful response
      logger.info("OpenAI request completed", {
        promptType,
        model,
        duration: `${duration}ms`,
        status: "success",
      });

      return result;
    } catch (error: any) {
      const duration = Date.now() - startTime;

      // Log failed request
      logger.error("OpenAI request failed", {
        promptType,
        model,
        duration: `${duration}ms`,
        status: "failure",
        error: error.message,
      });

      incrementOpenAiRequest(promptType, model, "failure");

      throw error;
    }
  };
}

/**
 * Error logging middleware
 */
export function errorLogger(
  error: Error,
  req: Request,
  res: Response,
  next: NextFunction,
) {
  logger.error("Unhandled error", {
    error: error.message,
    stack: error.stack,
    method: req.method,
    url: req.url,
    ip: req.ip,
    userAgent: req.headers["user-agent"],
    timestamp: new Date().toISOString(),
  });

  // Don't call next() to prevent default error handling
  if (!res.headersSent) {
    res.status(500).json({
      error: "Internal server error",
      message:
        process.env.NODE_ENV === "development"
          ? error.message
          : "Something went wrong",
    });
  }
}

/**
 * Health check logging
 */
export function healthCheckLogger(
  req: Request,
  res: Response,
  next: NextFunction,
) {
  if (req.url === "/health" || req.url === "/healthz") {
    logger.debug("Health check requested", {
      ip: req.ip,
      userAgent: req.headers["user-agent"],
    });
  }
  next();
}
