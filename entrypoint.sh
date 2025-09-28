#!/bin/bash
set -e


echo "🐧 Starting Claude Code in Podman container"
echo "📁 Working directory: $(pwd)"
echo "👤 Running as: $(id)"
echo

# Ensure Claude is in PATH for this session (handles both possible install locations)
export PATH="$HOME/.local/bin:$HOME/.claude/bin:$PATH"

# Check for Claude and auto-update if available
if command -v claude &> /dev/null; then
    echo "🔄 Checking for Claude updates..."
    claude update || echo "⚠️  Update check skipped"
    echo "📦 Claude version: $(claude --version)"
else
    echo "⚠️  Claude not found in PATH"
fi

# Set up additional .bashrc entries if needed
if [ -f ~/.bashrc ]; then
    # Check if Go path is already in .bashrc
    if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
        echo 'export PATH="/usr/local/go/bin:$PATH"' >> ~/.bashrc
    fi
else
    echo "📝 Creating .bashrc..."
    cat > ~/.bashrc << 'EOF'
# Add paths
export PATH="$HOME/.local/bin:$HOME/.claude/bin:/usr/local/go/bin:$PATH"

# Source global definitions
if [ -f /etc/bash.bashrc ]; then
    . /etc/bash.bashrc
fi
EOF
fi

echo "✅ Container ready!"
echo
echo "💡 Available tools:"
echo "   - claude (Claude Code CLI with auto-update)"
echo "   - go (Go compiler)"
echo "   - git"
echo "   - python3, pip"
echo
echo "🚀 Starting shell..."

exec "$@"
