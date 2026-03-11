FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ARG TERRAFORM_VERSION=1.14.5

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

# Install Node.js (required for Codex and Gemini CLI)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Codex CLI
RUN npm i -g @openai/codex@latest

# Install Gemini CLI
RUN npm install -g @google/gemini-cli

# Install Claude Code CLI
RUN curl -fsSL https://claude.ai/install.sh | bash \
    && mkdir -p /opt/bin \
    && mkdir -p /opt/share/claude \
    && cp ~/.local/bin/claude /opt/bin/claude \
    && cp -r ~/.local/share/claude /opt/share/claude

# Add Claude Code to $PATH
ENV PATH="/opt/bin:$PATH"

# Install Terraform
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform.zip \
    && chmod +x /usr/local/bin/terraform

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install AWS ClI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

# Install GCloud CLI
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && apt-get update -y \
    && apt-get install google-cloud-cli -y

# Set up non-root user
RUN mkdir -p /home/vscode && chown -R vscode:vscode /home/vscode
USER vscode

# Verify installations
RUN terraform --version \
    && aws --version \
    && az --version \
    && gcloud --version \
    && codex --version \
    && claude --version \
    && gemini --version

# Enter Project Workspace
WORKDIR /workspaces