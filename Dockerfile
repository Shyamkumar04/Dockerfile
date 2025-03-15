FROM ubuntu:latest

# Install required packages
RUN apt update && apt install -y nginx curl wget unzip

# Detect system architecture and download the correct FileBrowser binary
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then FILEBROWSER_ARCH="linux-amd64"; \
    elif [ "$ARCH" = "arm64" ]; then FILEBROWSER_ARCH="linux-arm64"; \
    elif [ "$ARCH" = "armhf" ]; then FILEBROWSER_ARCH="linux-armv6"; \
    else echo "Unsupported architecture: $ARCH" && exit 1; fi && \
    wget -O /tmp/filebrowser.tar.gz $(curl -s https://api.github.com/repos/filebrowser/filebrowser/releases/latest \
    | grep "browser_download_url.*$FILEBROWSER_ARCH.tar.gz" | cut -d '"' -f 4) && \
    tar -xzf /tmp/filebrowser.tar.gz -C /usr/local/bin filebrowser && \
    chmod +x /usr/local/bin/filebrowser

# Create directories for website and file storage
RUN mkdir -p /srv/website /srv/files /var/www/html

# Set up NGINX configuration
RUN echo 'server {\n\
    listen 80;\n\
    root /srv/website;\n\
    index index.html;\n\
    location /files/ {\n\
        proxy_pass http://localhost:8080/;\n\
        proxy_set_header Host $host;\n\
        proxy_set_header X-Real-IP $remote_addr;\n\
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n\
    }\n\
}' > /etc/nginx/sites-available/default

# Expose port 80
EXPOSE 80

# Copy default index.html
RUN echo '<!DOCTYPE html>\n<html>\n<head><title>My Website</title></head>\n<body><h1>Welcome to My Website</h1></body>\n</html>' > /srv/website/index.html

# Start NGINX and FileBrowser
CMD nginx && /usr/local/bin/filebrowser --port 8080 --root /srv/files
