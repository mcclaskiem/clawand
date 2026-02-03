# OpenClaw container for Apple Containers
# Run with: container run -t -i --memory 4g --cpus 8 --name clawand clawand:latest

FROM ubuntu:resolute-20260106.1

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create clawand user with home directory
RUN useradd -m -s /bin/bash clawand

# Create .openclaw directory for volume mount
RUN mkdir -p /home/clawand/.openclaw \
    && chown -R clawand:clawand /home/clawand

# Switch to clawand user
USER clawand
WORKDIR /home/clawand

# Install nvm
ENV NVM_DIR=/home/clawand/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Install Node.js 24 using nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install 24 && nvm use 24 && nvm alias default 24

# Add nvm to shell profile for interactive use
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc

# Install OpenClaw using the official installer
RUN . "$NVM_DIR/nvm.sh" && curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard

# Expose the OpenClaw gateway port
EXPOSE 18789

# Default command: open an interactive bash shell
CMD ["/bin/bash"]
