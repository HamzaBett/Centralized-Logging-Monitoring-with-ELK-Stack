# Kibana Dashboard Exports

This directory contains exported Kibana dashboard configurations in JSON format. These exports can be imported into Kibana to quickly set up monitoring dashboards for the ELK stack.

## Available Dashboards

### 1. Application Performance Monitoring Dashboard
- **File**: `app-performance-dashboard.json`
- **Purpose**: Monitors application response times, throughput, and error rates
- **Key Metrics**:
  - Average response time by service
  - Requests per minute
  - Error rate over time
  - Top slowest endpoints

### 2. Error Tracking Dashboard
- **File**: `error-tracking-dashboard.json`
- **Purpose**: Tracks and analyzes application errors by severity and type
- **Key Metrics**:
  - Error count by level (ERROR, WARN, CRITICAL)
  - Top error messages
  - Error distribution by service
  - Error trends over time

### 3. System Health Dashboard
- **File**: `system-health-dashboard.json`
- **Purpose**: Monitors system-level metrics for all services
- **Key Metrics**:
  - CPU usage by container
  - Memory consumption
  - Disk I/O operations
  - Network traffic

### 4. Real-time Log Stream Dashboard
- **File**: `realtime-log-stream-dashboard.json`
- **Purpose**: Provides a real-time view of incoming logs
- **Key Features**:
  - Live tail of log entries
  - Filterable by log level, service, and environment
  - Search functionality with saved searches
  - Correlation ID tracking for distributed tracing

### 5. Security Monitoring Dashboard
- **File**: `security-monitoring-dashboard.json`
- **Purpose**: Monitors security-related events and potential threats
- **Key Metrics**:
  - Failed login attempts
  - Suspicious IP addresses
  - GeoIP location of requests
  - Authentication success/failure rates

## Import Instructions

To import these dashboards into Kibana:

1. Navigate to **Stack Management** > **Saved Objects**
2. Click **Import**
3. Select the JSON file you want to import
4. Check **Overwrite all objects** if you want to replace existing dashboards
5. Click **Import**

## Customization

After importing, you can customize the dashboards to fit your specific needs:

- Update index patterns to match your naming convention
- Modify time ranges for different analysis periods
- Add or remove visualizations based on your monitoring requirements
- Adjust alert thresholds for different services

## Best Practices

- Regularly review and update dashboards as your application evolves
- Create separate dashboards for different teams (e.g., development, operations, security)
- Use dashboard links to create navigation between related dashboards
- Set up scheduled reports for regular monitoring
