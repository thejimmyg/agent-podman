#!/bin/bash
set -e

echo "🐧 Starting Claude Code in Podman container"
echo "📁 Working directory: $(pwd)"
echo "👤 Running as: $(id)"
echo

# Check for Claude and auto-update if available
if command -v claude &> /dev/null; then
    echo "🔄 Checking for Claude updates..."
    # Run update check
    claude update 2>/dev/null || echo "⚠️  Update check skipped (may need internet)"
    echo "📦 Claude version: $(claude --version)"
else
    echo "⚠️  Claude not found in PATH"
fi

# Set up .bashrc if it doesn't exist
if [ ! -f ~/.bashrc ]; then
    echo "📝 Creating .bashrc..."
    cat > ~/.bashrc << 'EOF'
# Add Go to PATH if available
export PATH="/usr/local/go/bin:$PATH"

# Add Claude to PATH (native installer location)
export PATH="$HOME/.claude/bin:$PATH"

# GitHub CLI configuration
export GH_CONFIG_DIR=~/.config/gh

# Source global definitions
if [ -f /etc/bash.bashrc ]; then
    . /etc/bash.bashrc
fi
EOF
fi

# Ensure Claude is in PATH for this session
export PATH="$HOME/.claude/bin:$PATH"

echo "✅ Container ready!"
echo
echo "💡 Available tools:"
echo "   - claude (Claude Code CLI with auto-update)"
echo "   - go (Go compiler)"
echo "   - git, gh (Git and GitHub CLI)"
echo "   - python3, pip"
echo
echo "🚀 Starting shell..."

exec "$@"