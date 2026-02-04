FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ARG TERRAFORM_VERSION=1.14.4

USER root

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    ca-certificates \
    apt-transport-https \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (required for Claude Code CLI)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Install Terraform
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform.zip \
    && chmod +x /usr/local/bin/terraform

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Verify installations
RUN terraform --version \
    && az --version \
    && claude --version

# Set up non-root user
RUN mkdir -p /home/vscode && chown -R vscode:vscode /home/vscode
USER vscode
WORKDIR /workspaces