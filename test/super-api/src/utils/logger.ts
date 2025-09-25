import * as winston from 'winston';

// Create a custom format for structured logging
const logFormat = winston.format.combine(
  winston.format.timestamp({
    format: 'YYYY-MM-DD HH:mm:ss'
  }),
  winston.format.errors({ stack: true }),
  winston.format.json(),
  winston.format.printf(({ timestamp, level, message, ...meta }) => {
    return JSON.stringify({
      timestamp,
      level,
      message,
      ...meta
    });
  })
);

// Create the logger instance
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: logFormat,
  defaultMeta: {
    service: 'larry-backend',
    version: process.env.npm_package_version || '1.0.0'
  },
  transports: [
    // Console transport for development
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    }),
    
    // File transport for production logs
    new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error',
      maxsize: 5242880, // 5MB
      maxFiles: 5
    }),
    
    new winston.transports.File({
      filename: 'logs/combined.log',
      maxsize: 5242880, // 5MB
      maxFiles: 5
    })
  ],
  
  // Handle uncaught exceptions
  exceptionHandlers: [
    new winston.transports.File({ filename: 'logs/exceptions.log' })
  ],
  
  // Handle unhandled promise rejections
  rejectionHandlers: [
    new winston.transports.File({ filename: 'logs/rejections.log' })
  ]
});

// Create specialized loggers for different components
export const openAiLogger = logger.child({ component: 'openai' });
export const pipelineLogger = logger.child({ component: 'pipeline' });
export const termLogger = logger.child({ component: 'terms' });
export const validationLogger = logger.child({ component: 'validation' });
export const metricsLogger = logger.child({ component: 'metrics' });
export const adminLogger = logger.child({ component: 'admin' });

// Helper functions for common logging patterns
export const logOpenAiRequest = (promptType: string, topicId: string, metadata: any = {}) => {
  openAiLogger.info('OpenAI request initiated', {
    promptType,
    topicId,
    ...metadata
  });
};

export const logOpenAiResponse = (promptType: string, topicId: string, success: boolean, metadata: any = {}) => {
  if (success) {
    openAiLogger.info('OpenAI request completed', {
      promptType,
      topicId,
      ...metadata
    });
  } else {
    openAiLogger.error('OpenAI request failed', {
      promptType,
      topicId,
      ...metadata
    });
  }
};

export const logPipelineEvent = (event: string, topicId: string, metadata: any = {}) => {
  pipelineLogger.info(`Pipeline ${event}`, {
    topicId,
    ...metadata
  });
};

export const logTermEvent = (event: string, termId: string, metadata: any = {}) => {
  termLogger.info(`Term ${event}`, {
    termId,
    ...metadata
  });
};

export const logFallbackUsage = (reason: string, term: string, metadata: any = {}) => {
  metricsLogger.warn('GPT fallback used', {
    reason,
    term,
    ...metadata
  });
};

export const logModerationEvent = (action: string, termId: string, metadata: any = {}) => {
  adminLogger.info(`Moderation ${action}`, {
    termId,
    ...metadata
  });
};

export default logger;




