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

Run Claude Code with any git repository:

```bash
# Run with your git repository
./claude.sh /path/to/your/git/repo

# Examples:
./claude.sh ~/code/my-project
./claude.sh /home/user/work/repository
```

The script will automatically:
- Build the container if needed
- Set up persistent configuration directories
- Mount your git repository
- Configure git settings from your host system
- Start Claude Code with proper permissions

Note: When mounting specific config directories, Claude installation in `~/.claude` remains in the container. If you mount the entire home directory, you'll need to reinstall Claude on first run with: `curl -fsSL https://claude.ai/install.sh | bash`

## Building the Container

The script will automatically build the container if it doesn't exist. To manually rebuild the container:

```bash
podman build -t claude-code .
```

To force rebuild (no cache):

```bash
podman build --no-cache -t claude-code .
```

## Advanced Usage

For manual container usage (if you need custom configuration):

```bash
# Create directories for persistent config
mkdir -p mount

# Run with selective mounting to preserve config without interfering with Claude
podman run --rm -it \
  --userns=keep-id \
  -v "/path/to/git/repo:/git" \
  -v "$(pwd)/mount/.bash_history:/home/ubuntu/.bash_history" \
  -v "$(pwd)/mount/.claude:/home/ubuntu/.claude" \
  -v "$(pwd)/mount/.claude.json:/home/ubuntu/.claude.json" \
  -e "TZ=$(cat /etc/timezone 2>/dev/null || echo 'UTC')" \
  -e "GIT_AUTHOR_NAME=$(git config user.name)" \
  -e "GIT_AUTHOR_EMAIL=$(git config user.email)" \
  -e "GIT_COMMITTER_NAME=$(git config user.name)" \
  -e "GIT_COMMITTER_EMAIL=$(git config user.email)" \
  claude-code
```

For server access, you can add port mapping or network options to the above command:
```bash
# Map specific ports
-p 8080:8080

# Use host networking (less secure but convenient)
--network host
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
