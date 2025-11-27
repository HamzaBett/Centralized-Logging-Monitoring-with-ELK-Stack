# Filebeat Dockerfile
FROM docker.elastic.co/beats/filebeat:${FILEBEAT_VERSION}

# Set working directory
WORKDIR /usr/share/filebeat

# Copy configuration files
COPY config/filebeat.yml /usr/share/filebeat/filebeat.yml

# Create directory for certificates
RUN mkdir -p /usr/share/filebeat/config/certs

# Set permissions
RUN chown -R root:root /usr/share/filebeat/filebeat.yml
RUN chmod go-w /usr/share/filebeat/filebeat.yml
RUN chown -R root:root /usr/share/filebeat/config
RUN chmod -R 755 /usr/share/filebeat/config

# Expose port for health check
EXPOSE 5066

# Run as root (required for accessing Docker socket)
USER root

# Start Filebeat
CMD ["filebeat", "-e", "-strict.perms=false"]
