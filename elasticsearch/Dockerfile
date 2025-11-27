# Elasticsearch Dockerfile
FROM docker.elastic.co/elasticsearch/elasticsearch:${ELASTICSEARCH_VERSION}

# Set environment variables
ENV PATH=/usr/share/elasticsearch/bin:$PATH

# Create directory for certificates
RUN mkdir -p /usr/share/elasticsearch/config/certs

# Copy configuration files
COPY config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

# Set correct permissions
RUN chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/config

# Expose ports
EXPOSE 9200 9300

# Run as elasticsearch user
USER elasticsearch

# Start Elasticsearch
CMD ["elasticsearch"]
