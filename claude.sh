#!/bin/bash
set -e

echo "🚀 Starting Claude Code in Podman Container"
echo "==========================================="

# Validate GIT_ROOT argument
if [ -z "$1" ]; then
    echo "❌ Error: No git repository path provided"
    echo ""
    echo "Usage: $0 <git-repository-path>"
    echo ""
    echo "Example:"
    echo "  $0 /home/user/my-project"
    echo "  $0 ~/code/my-repo"
    exit 1
fi

GIT_ROOT="$(realpath "$1")"

# Validate that the directory exists and is a git repository
if [ ! -d "$GIT_ROOT" ]; then
    echo "❌ Error: Directory '$1' does not exist"
    exit 1
fi

if [ ! -d "$GIT_ROOT/.git" ]; then
    echo "❌ Error: Directory '$GIT_ROOT' is not a git repository"
    echo "   Initialize it with: git init"
    exit 1
fi

echo "Git repository root: $GIT_ROOT"

# Create necessary local directories
PODMAN_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$PODMAN_DIR/mount/.claude"
touch "$PODMAN_DIR/mount/.bash_history"

# Create .claude.json with valid empty JSON if it doesn't exist
if [ ! -f "$PODMAN_DIR/mount/.claude.json" ]; then
    echo '{}' > "$PODMAN_DIR/mount/.claude.json"
fi

echo "Created local directories in $PODMAN_DIR/mount/"

# Check if claude-code image exists
if ! podman images --format "{{.Repository}}:{{.Tag}}" | grep -q "^claude-code:latest$"; then
    echo "Claude Code image not found. Building..."
    cd "$PODMAN_DIR"
    podman build -t claude-code .
    echo "Claude Code image built successfully"
else
    echo "Using existing claude-code image"
fi

# Get timezone
TZ_VALUE=$(cat /etc/timezone 2>/dev/null || echo 'UTC')

# Get git configuration or use defaults
GIT_AUTHOR_NAME="${GIT_AUTHOR_NAME:-$(git config user.name 2>/dev/null || echo 'Your Name')}"
GIT_AUTHOR_EMAIL="${GIT_AUTHOR_EMAIL:-$(git config user.email 2>/dev/null || echo 'you@example.com')}"

echo "Starting Claude Code container..."
echo "  Git repo: $GIT_ROOT"
echo "  Home dir: $PODMAN_DIR/mount"
echo "  User: $GIT_AUTHOR_NAME <$GIT_AUTHOR_EMAIL>"

# Run the container with selective mounting to preserve config
exec podman run --rm -it \
  --userns=keep-id \
  -v "$GIT_ROOT:/git" \
  -v "$GIT_ROOT/../agent-virt:/agent-virt" \
  -v "$PODMAN_DIR/mount/.bash_history:/home/ubuntu/.bash_history" \
  -v "$PODMAN_DIR/mount/.claude:/home/ubuntu/.claude" \
  -v "$PODMAN_DIR/mount/.claude.json:/home/ubuntu/.claude.json" \
  -e "TZ=$TZ_VALUE" \
  -e "GIT_AUTHOR_NAME=$GIT_AUTHOR_NAME" \
  -e "GIT_AUTHOR_EMAIL=$GIT_AUTHOR_EMAIL" \
  -e "GIT_COMMITTER_NAME=$GIT_AUTHOR_NAME" \
  -e "GIT_COMMITTER_EMAIL=$GIT_AUTHOR_EMAIL" \
  claude-code
