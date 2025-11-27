FROM debian:bookworm

# Install Nginx and OpenSSL
RUN apt-get update && apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Create SSL directory
RUN mkdir -p /etc/nginx/ssl

# Copy configuration and tools
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf
COPY tools/ssl.sh /usr/local/bin/ssl.sh

# Make the SSL script executable and run it
RUN chmod +x /usr/local/bin/ssl.sh && \
    /usr/local/bin/ssl.sh

# Nginx on Debian runs in the foreground with this command
CMD ["nginx", "-g", "daemon off;"]