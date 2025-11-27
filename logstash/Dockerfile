# Logstash Dockerfile
FROM docker.elastic.co/logstash/logstash:${LOGSTASH_VERSION}

# Set working directory
WORKDIR /usr/share/logstash

# Copy configuration files
COPY config/logstash.yml /usr/share/logstash/config/logstash.yml
COPY pipeline/logstash.conf /usr/share/logstash/pipeline/logstash.conf

# Create directory for certificates
RUN mkdir -p /usr/share/logstash/config/certs

# Install GeoIP database
RUN logstash-plugin install logstash-filter-geoip && \
    mkdir -p /usr/share/logstash/vendor/geoip && \
    cd /usr/share/logstash/vendor/geoip && \
    curl -O https://github.com/PrecisionPlugin/GeoLite2-City.mmdb/raw/master/GeoLite2-City.mmdb

# Set permissions
RUN chown -R logstash:logstash /usr/share/logstash/config
RUN chmod -R 755 /usr/share/logstash/config

# Expose ports
EXPOSE 5044 9600

# Run as logstash user
USER logstash

# Start Logstash
CMD ["bin/logstash", "-f", "/usr/share/logstash/pipeline/logstash.conf"]
