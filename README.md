# Using Claude Code with Podman

Use the provided container setup to run Claude Code in a secure, rootless container environment with Podman.

## Why Podman?

Podman provides significant advantages over Docker for development:
- **Rootless by default** - No daemon running as root
- **Better security** - User namespaces and SELinux integration
- **Simpler user mapping** - No complex UID/GID mapping scripts needed
- **systemd integration** - Native support for systemd services

## Quick Start

On Ubuntu/Debian:

```bash
sudo apt update
sudo apt install podman
```

Build:

```bash
# Build the container
podman build -t claude-code .
# Create git directory for your repositories
mkdir -p git
```

Run the container with simplified user mapping

```bash
# Create directories for persistent config
mkdir -p claude-config

# Run with selective mounting to preserve config without interfering with Claude
podman run --rm -it \
  --userns=keep-id \
  -v "$(pwd)/git:/git" \
  -v "$(pwd)/mount/.bash_history:/home/ubuntu/.bash_history" \
  -v "$(pwd)/mount/.claude:/home/ubuntu/.claude" \
  -v "$(pwd)/mount/.claude.json:/home/ubuntu/.claude.json" \
  -e "TZ=$(cat /etc/timezone 2>/dev/null || echo 'UTC')" \
  -e "GIT_AUTHOR_NAME=Your Name" \
  -e "GIT_AUTHOR_EMAIL=you@example.com" \
  -e "GIT_COMMITTER_NAME=Your Name" \
  -e "GIT_COMMITTER_EMAIL=you@example.com" \
  claude-code
```

Note: When mounting specific config directories, Claude installation in `~/.claude` remains in the container. If you mount the entire home directory, you'll need to reinstall Claude on first run with: `curl -fsSL https://claude.ai/install.sh | bash`

To get the latest claude-code version, rebuild the container:

```bash
podman build --no-cache -t claude-code .
```

For server access, you can:
```bash
# Map specific ports
podman run -p 8080:8080 ... claude-code

# Use host networking (less secure but convenient)
podman run --network host ... claude-code
```

## What This Provides

- **Secure isolation**: Container works only within the mounted git directory
- **Perfect file permissions**: Files created in container have correct ownership on host
- **No privilege escalation**: Container user cannot become root on host system

## Available Tools

The container includes:

- `claude-code` - Claude Code CLI
- `go` - Go compiler and tools
- `git`, `gh` - Git and GitHub CLI
- `python3`, `pip`, `pipx` - Python ecosystem
- `npm`, `node` - Node.js ecosystem
- Standard Linux utilities
