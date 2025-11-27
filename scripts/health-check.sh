#!/bin/bash

# Health Check Script
# Checks the health status of all ELK components

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ES_URL="${ES_URL:-http://localhost:9200}"
KIBANA_URL="${KIBANA_URL:-http://localhost:5601}"
LOGSTASH_URL="${LOGSTASH_URL:-http://localhost:9600}"
ES_USER="${ELASTICSEARCH_USERNAME:-elastic}"
ES_PASSWORD="${ELASTICSEARCH_PASSWORD:-changeme}"

check_service() {
  local name=$1
  local url=$2
  local auth=${3:-}
  echo "🔍 Checking $name..."
  if [ -n "$auth" ]; then
    response=$(curl -s -o /dev/null -w "%{http_code}" -u "$auth" "$url" || echo "000")
  else
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "000")
  fi
  if [ "$response" = "200" ] || [ "$response" = "302" ]; then
    echo "✅ $name is healthy (HTTP $response)"
    return 0
  else
    echo "❌ $name is unhealthy (HTTP $response)"
    return 1
  fi
}

echo "🏥 Starting health check..."
check_service "Elasticsearch" "$ES_URL" "$ES_USER:$ES_PASSWORD"
check_service "Kibana" "$KIBANA_URL"
check_service "Logstash" "$LOGSTASH_URL"

cluster_health=$(curl -s -u "$ES_USER:$ES_PASSWORD" "$ES_URL/_cluster/health" | jq -r '.status' || echo "unknown")
echo "Elasticsearch cluster health: $cluster_health"
node_count=$(curl -s -u "$ES_USER:$ES_PASSWORD" "$ES_URL/_cat/nodes?h=name" | wc -l || echo 0)
echo "Number of Elasticsearch nodes: $node_count"
index_count=$(curl -s -u "$ES_USER:$ES_PASSWORD" "$ES_URL/_cat/indices?h=index" | wc -l || echo 0)
echo "Number of indices: $index_count"

echo "Health check completed!"
