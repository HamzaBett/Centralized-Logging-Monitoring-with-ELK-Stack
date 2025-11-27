#!/bin/bash

# ELK Stack Setup Script
# This script initializes the ELK stack environment and performs necessary setup tasks

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🚀 Starting ELK Stack setup..."

# Create required directories
echo "📁 Creating directory structure..."
mkdir -p "$ROOT_DIR/certs"
mkdir -p "$ROOT_DIR/data/elasticsearch"
mkdir -p "$ROOT_DIR/logs"

# Generate SSL certificates for secure communication
echo "🔐 Generating SSL certificates..."
cd "$ROOT_DIR/certs" || exit

# Create CA certificate
openssl req -x509 -nodes -new -sha256 -days 365 \
  -keyout ca.key -out ca.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=ELK-CA" \
  -addext "subjectAltName=DNS:localhost,DNS:elasticsearch,DNS:kibana,DNS:logstash"

# Generate certificates for each service
for SERVICE in elasticsearch kibana logstash filebeat; do
  echo "Generating certificate for $SERVICE..."
  
  # Create private key
  openssl genrsa -out "$SERVICE/$SERVICE.key" 2048
  
  # Create certificate signing request
  openssl req -new -key "$SERVICE/$SERVICE.key" -out "$SERVICE/$SERVICE.csr" \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=$SERVICE"
  
  # Sign certificate with CA
  openssl x509 -req -in "$SERVICE/$SERVICE.csr" -CA ca.crt -CAkey ca.key \
    -CAcreateserial -out "$SERVICE/$SERVICE.crt" -days 365 \
    -extfile <(printf "subjectAltName=DNS:$SERVICE,DNS:localhost")
  
  # Set proper permissions
  chmod 600 "$SERVICE/$SERVICE.key"
done

# Create sample data directory
echo "📊 Creating sample data directory..."
mkdir -p "$ROOT_DIR/sample-data"
cat > elk-logging-project/sample-data/sample-logs.json << 'EOL'
[
  {
    "timestamp": "2025-11-27T10:00:00Z",
    "level": "INFO",
    "message": "Application started successfully",
    "service_name": "app1",
    "environment": "production",
    "version": "1.0.0"
  },
  {
    "timestamp": "2025-11-27T10:01:00Z",
    "level": "WARN",
    "message": "Deprecated endpoint accessed",
    "service_name": "app1",
    "endpoint": "/api/old",
    "recommendation": "Use /api/new instead",
    "environment": "production",
    "version": "1.0.0"
  },
  {
    "timestamp": "2025-11-27T10:02:00Z",
    "level": "ERROR",
    "message": "Database connection failed",
    "service_name": "app2",
    "error_type": "ConnectionError",
    "error_message": "Failed to connect to database",
    "stack_trace": "at Database.connect() ...",
    "environment": "production",
    "version": "1.0.0"
  }
]
EOL

# Set up environment variables
echo "⚙️ Setting up environment variables..."
if [ -f "$ROOT_DIR/.env" ]; then
  echo "Using existing .env file in $ROOT_DIR"
else
  if [ -f "$ROOT_DIR/.env.example" ]; then
    cp "$ROOT_DIR/.env.example" "$ROOT_DIR/.env"
    echo "Created .env from .env.example"
  else
    echo "No .env or .env.example found; please create a .env with required values" >&2
  fi
fi

# Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x "$ROOT_DIR/scripts"/*.sh

# Ensure index lifecycle and health-check scripts are present; set permissions
echo "🔁 Ensuring helper scripts exist and are executable..."
if [ ! -f "$ROOT_DIR/scripts/index-lifecycle-management.sh" ]; then
  echo "index-lifecycle-management.sh is missing; creating a basic script..."
  cat > "$ROOT_DIR/scripts/index-lifecycle-management.sh" << 'EOL'
#!/bin/bash
echo "Index lifecycle script placeholder. Please edit $ROOT_DIR/scripts/index-lifecycle-management.sh to add commands."
EOL
fi
if [ ! -f "$ROOT_DIR/scripts/health-check.sh" ]; then
  echo "health-check.sh is missing; creating a basic script..."
  cat > "$ROOT_DIR/scripts/health-check.sh" << 'EOL'
#!/bin/bash
echo "Health check script placeholder. Please edit $ROOT_DIR/scripts/health-check.sh to add checks."
EOL
fi
chmod +x "$ROOT_DIR/scripts/index-lifecycle-management.sh"
chmod +x "$ROOT_DIR/scripts/health-check.sh"

echo "🏥 Setup script completed!"
echo "Next steps:"
echo "1. Edit $ROOT_DIR/.env to set secure credentials (e.g., ELASTIC_PASSWORD)."
echo "2. Run 'docker-compose up -d' to start the services."
echo "3. Run '$ROOT_DIR/scripts/index-lifecycle-management.sh' to set up ILM policies."
echo "4. Run '$ROOT_DIR/scripts/health-check.sh' to verify services."

echo "✨ ELK Stack setup completed successfully!"
echo "Next steps:"
echo "1. Run 'docker-compose up -d' to start the services"
echo "2. Run './scripts/index-lifecycle-management.sh' to set up ILM policies"
echo "3. Access Kibana at http://localhost:5601"
