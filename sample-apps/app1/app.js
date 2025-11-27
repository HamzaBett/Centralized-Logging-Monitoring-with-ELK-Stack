const express = require('express');
const winston = require('winston');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = process.env.PORT || 3000;

// Create logger with JSON formatting
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
});

// Middleware to add correlation ID to requests
app.use((req, res, next) => {
  req.correlationId = uuidv4();
  logger.info('Request received', {
    method: req.method,
    url: req.url,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    correlationId: req.correlationId
  });
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  logger.info('Health check requested', { correlationId: req.correlationId });
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Normal operation endpoint
app.get('/api/data', (req, res) => {
  const startTime = Date.now();
  
  // Simulate some processing
  setTimeout(() => {
    const responseTime = Date.now() - startTime;
    
    logger.info('Data retrieved successfully', {
      correlationId: req.correlationId,
      responseTime: responseTime,
      endpoint: '/api/data'
    });
    
    res.json({
      message: 'Data retrieved successfully',
      timestamp: new Date().toISOString(),
      responseTime: responseTime
    });
  }, Math.random() * 100);
});

// Warning scenario endpoint
app.get('/api/warning', (req, res) => {
  logger.warn('Deprecated endpoint accessed', {
    correlationId: req.correlationId,
    endpoint: '/api/warning',
    recommendation: 'Use /api/data instead'
  });
  
  res.status(200).json({
    message: 'This endpoint is deprecated. Please use /api/data instead.',
    warning: true
  });
});

// Error scenario endpoint
app.get('/api/error', (req, res) => {
  const error = new Error('Simulated internal server error');
  
  logger.error('Internal server error occurred', {
    correlationId: req.correlationId,
    error: error.message,
    stack: error.stack,
    endpoint: '/api/error'
  });
  
  res.status(500).json({
    error: 'Internal Server Error',
    message: 'An unexpected error occurred',
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use((req, res) => {
  logger.warn('Route not found', {
    method: req.method,
    url: req.url,
    ip: req.ip,
    correlationId: req.correlationId
  });
  
  res.status(404).json({
    error: 'Not Found',
    message: `The route ${req.method} ${req.url} does not exist`
  });
});

// Error handling middleware
app.use((error, req, res, next) => {
  logger.error('Unhandled error in application', {
    correlationId: req.correlationId,
    error: error.message,
    stack: error.stack
  });
  
  res.status(500).json({
    error: 'Internal Server Error',
    message: 'An unexpected error occurred'
  });
});

app.listen(PORT, () => {
  logger.info(`Sample App 1 is running on port ${PORT}`, {
    environment: process.env.NODE_ENV || 'development',
    version: '1.0.0'
  });
});

module.exports = app;
