#!/bin/bash

# Index Lifecycle Management Script
# Sets up ILM policies for log retention and management

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ES_URL="${ES_URL:-http://localhost:9200}"
ES_USER="${ELASTICSEARCH_USERNAME:-elastic}"
ES_PASSWORD="${ELASTICSEARCH_PASSWORD:-changeme}"

echo "Setting up Index Lifecycle Management..."

curl -s -X PUT "$ES_URL/_ilm/policy/logs-policy" \
  -u "$ES_USER:$ES_PASSWORD" \
  -H 'Content-Type: application/json' \
  -d '{"policy":{"phases":{"hot":{"min_age":"0ms","actions":{"rollover":{"max_size":"50gb","max_age":"30d"},"set_priority":{"priority":100}}},"warm":{"min_age":"30d","actions":{"forcemerge":{"max_num_segments":1},"allocate":{"number_of_replicas":1},"set_priority":{"priority":50}}},"cold":{"min_age":"60d","actions":{"freeze":{},"set_priority":{"priority":0}}},"delete":{"min_age":"90d","actions":{"delete":{}}}}}}'

echo "ILM setup completed!"
