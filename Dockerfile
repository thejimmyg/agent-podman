# Ubuntu 24.04 LTS (Noble Numbat)
FROM docker.io/ubuntu:24.04@sha256:985be7c735afdf6f18aaa122c23f87d989c30bba4e9aa24c8278912aac339a8d

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=linux

# Install essential tools only
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    ca-certificates \
    curl \
    git \
    jq \
    golang \
    python3 \
    python3-pip \
    python3-venv \
    vim-nox \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Add GitHub CLI repository and install (no gnupg needed)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Switch to ubuntu user to install Claude
USER ubuntu
WORKDIR /home/ubuntu

# Install Claude using the native installer
RUN curl -fsSL https://claude.ai/install.sh | bash

# Add entrypoint script
USER root
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set final user and working directory
USER ubuntu
WORKDIR /git

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash", "--login"]
