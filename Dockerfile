FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && apt install -y \
    curl \
    gnupg \
    git \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Add NodeSource repository and install Node.js
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt update \
    && apt install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /etc

# Clone Skyport Panel repository
RUN git clone --branch v0.2.2 https://github.com/skyportlabs/panel skyport

# Set working directory to Skyport
WORKDIR /etc/skyport

# Install dependencies
RUN npm install

# Seed database and create admin user
RUN npm run seed \
    && npm run createUser

# Expose port 3001
EXPOSE 3001

# Start the application
CMD ["node", "."]
