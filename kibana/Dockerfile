# Kibana Dockerfile
FROM docker.elastic.co/kibana/kibana:${KIBANA_VERSION}

# Set working directory
WORKDIR /usr/share/kibana

# Copy configuration files
COPY config/kibana.yml /usr/share/kibana/config/kibana.yml

# Create directory for certificates
RUN mkdir -p /usr/share/kibana/config/certs

# Set permissions
RUN chown -R kibana:kibana /usr/share/kibana/config
RUN chmod -R 755 /usr/share/kibana/config

# Expose port
EXPOSE ${KIBANA_SERVER_PORT}

# Run as kibana user
USER kibana

# Start Kibana
CMD ["bin/kibana"]
