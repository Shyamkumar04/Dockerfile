FROM alpine:latest

# Install required packages (NGINX, curl)
RUN apk add --no-cache nginx curl

# Download and install FileBrowser manually
RUN curl -fsSL https://github.com/filebrowser/filebrowser/releases/latest/download/linux-amd64-filebrowser -o /usr/local/bin/filebrowser \
    && chmod +x /usr/local/bin/filebrowser

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
}' > /etc/nginx/conf.d/default.conf

# Set permissions for FileBrowser
RUN adduser -D -g 'filebrowser' filebrowser && \
    chown -R filebrowser:filebrowser /srv/files

# Expose the required ports
EXPOSE 80

# Copy default index.html (replace with your own)
RUN echo '<!DOCTYPE html>\n<html>\n<head><title>My Website</title></head>\n<body><h1>Welcome to My Website</h1></body>\n</html>' > /srv/website/index.html

# Start NGINX and FileBrowser
CMD nginx && filebrowser --port 8080 --root /srv/files
