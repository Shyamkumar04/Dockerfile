FROM ubuntu:latest

# Set noninteractive mode to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download and install EasyPanel
RUN curl -sSL https://get.easypanel.io | sh

# Expose EasyPanel default port (adjust if needed)
EXPOSE 3000

# Start EasyPanel
CMD ["/usr/bin/easypanel"]
