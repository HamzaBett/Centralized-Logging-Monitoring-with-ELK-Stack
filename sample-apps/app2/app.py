from flask import Flask, jsonify, request
import logging
import json
import uuid
import random
import time
from datetime import datetime

app = Flask(__name__)

# Configure logging to output JSON
class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'level': record.levelname,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno
        }
        
        # Add correlation ID if available
        if hasattr(record, 'correlation_id'):
            log_entry['correlation_id'] = record.correlation_id
            
        # Add additional context if available
        if hasattr(record, 'extra_data'):
            log_entry.update(record.extra_data)
            
        return json.dumps(log_entry)

# Set up logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Clear any existing handlers
logger.handlers.clear()

# Create console handler with JSON formatter
handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())
logger.addHandler(handler)

@app.before_request
def before_request():
    # Generate correlation ID for the request
    request.correlation_id = str(uuid.uuid4())
    
    # Log request details
    extra_data = {
        'method': request.method,
        'url': request.url,
        'remote_addr': request.remote_addr,
        'user_agent': request.headers.get('User-Agent'),
        'correlation_id': request.correlation_id
    }
    
    logger.info('Request received', extra={'extra_data': extra_data})

@app.route('/health')
def health():
    """Health check endpoint"""
    logger.info('Health check requested', 
                extra={'extra_data': {'correlation_id': request.correlation_id}})
    return jsonify({
        'status': 'OK',
        'service': 'sample-app2',
        'timestamp': datetime.utcnow().isoformat()
    })

@app.route('/api/data')
def get_data():
    """Normal operation endpoint"""
    start_time = time.time()
    
    # Simulate processing time
    time.sleep(random.uniform(0.01, 0.1))
    
    response_time = int((time.time() - start_time) * 1000)  # Convert to milliseconds
    
    extra_data = {
        'correlation_id': request.correlation_id,
        'response_time_ms': response_time,
        'endpoint': '/api/data'
    }
    
    logger.info('Data retrieved successfully', extra={'extra_data': extra_data})
    
    return jsonify({
        'message': 'Data retrieved successfully',
        'timestamp': datetime.utcnow().isoformat(),
        'response_time_ms': response_time
    })

@app.route('/api/warning')
def warning():
    """Warning scenario endpoint"""
    extra_data = {
        'correlation_id': request.correlation_id,
        'endpoint': '/api/warning',
        'recommendation': 'Use /api/data instead'
    }
    
    logger.warning('Deprecated endpoint accessed', extra={'extra_data': extra_data})
    
    return jsonify({
        'message': 'This endpoint is deprecated. Please use /api/data instead.',
        'warning': True
    }), 200

@app.route('/api/error')
def error():
    """Error scenario endpoint"""
    try:
        # Simulate an error
        raise ValueError('Simulated validation error')
    except Exception as e:
        extra_data = {
            'correlation_id': request.correlation_id,
            'error_type': type(e).__name__,
            'error_message': str(e),
            'endpoint': '/api/error'
        }
        
        logger.error('Validation error occurred', 
                    extra={'extra_data': extra_data, 'exc_info': True})
        
        return jsonify({
            'error': 'Validation Error',
            'message': 'Invalid request parameters',
            'timestamp': datetime.utcnow().isoformat()
        }), 400

@app.route('/api/critical')
def critical_error():
    """Critical error scenario endpoint"""
    try:
        # Simulate a critical error
        raise Exception('Simulated critical system failure')
    except Exception as e:
        extra_data = {
            'correlation_id': request.correlation_id,
            'error_type': type(e).__name__,
            'error_message': str(e),
            'endpoint': '/api/critical'
        }
        
        logger.critical('Critical system failure occurred', 
                       extra={'extra_data': extra_data, 'exc_info': True})
        
        return jsonify({
            'error': 'Critical System Failure',
            'message': 'The system encountered a critical failure',
            'timestamp': datetime.utcnow().isoformat()
        }), 500

@app.errorhandler(404)
def not_found(error):
    """404 error handler"""
    extra_data = {
        'correlation_id': getattr(request, 'correlation_id', None),
        'method': request.method,
        'url': request.url
    }
    
    logger.warning('Route not found', extra={'extra_data': extra_data})
    
    return jsonify({
        'error': 'Not Found',
        'message': f'The route {request.method} {request.url} does not exist'
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """500 error handler"""
    extra_data = {
        'correlation_id': getattr(request, 'correlation_id', None),
        'error_type': type(error).__name__,
        'error_message': str(error)
    }
    
    logger.error('Internal server error', 
                extra={'extra_data': extra_data, 'exc_info': True})
    
    return jsonify({
        'error': 'Internal Server Error',
        'message': 'An unexpected error occurred'
    }), 500

if __name__ == '__main__':
    # Log application startup
    logger.info('Sample App 2 is starting', 
                extra={'extra_data': {
                    'version': '1.0.0',
                    'environment': 'production',
                    'port': 5000
                }})
    
    app.run(host='0.0.0.0', port=5000, debug=False)
