FROM alpine:latest

# Install necessary packages
RUN apk add --no-cache filebrowser

# Create a directory for file storage
RUN mkdir -p /srv

# Set up filebrowser user
RUN adduser -D -g 'filebrowser' filebrowser
RUN chown -R filebrowser:filebrowser /srv

# Expose the port filebrowser uses
EXPOSE 80

# Set the working directory
WORKDIR /srv

# Run Filebrowser as the filebrowser user
USER filebrowser
ENTRYPOINT ["filebrowser", "--port", "80", "--root", "/srv"]
