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

# Switch to ubuntu user to install Claude
USER ubuntu
WORKDIR /home/ubuntu

# Set up .bashrc with PATH before installing Claude
RUN echo 'export PATH="$HOME/.local/bin:$HOME/.claude/bin:$PATH"' >> ~/.bashrc && \
    echo 'export PATH="$HOME/.local/bin:$HOME/.claude/bin:$PATH"' >> ~/.profile

# Install Claude using the native installer (with PATH already configured)
# Then run claude install to fix the configuration
RUN . ~/.profile && curl -fsSL https://claude.ai/install.sh | bash 

# Add entrypoint script
USER root
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set final user and working directory
USER ubuntu
WORKDIR /git

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash", "--login"]
