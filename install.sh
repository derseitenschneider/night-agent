#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="$HOME/.night-agent"
BIN_DIR="$HOME/bin"

# Detect mode
if [[ -f "$INSTALL_DIR/config.json" ]]; then
  MODE="update"
  echo "Updating night-agent..."
else
  MODE="install"
  echo "Installing night-agent..."
fi

# Check dependencies
missing=()
for cmd in claude gh tmux; do
  if ! command -v "$cmd" &>/dev/null; then
    missing+=("$cmd")
  fi
done
if [[ ${#missing[@]} -gt 0 ]]; then
  echo "Error: missing required commands: ${missing[*]}"
  exit 1
fi

# Create dirs
mkdir -p "$INSTALL_DIR/scripts" "$BIN_DIR"

# Copy files (always)
cp "$REPO_DIR/bin/night-agent" "$BIN_DIR/night-agent"
chmod +x "$BIN_DIR/night-agent"

cp "$REPO_DIR/prompt.md" "$INSTALL_DIR/"
cp "$REPO_DIR/session-state.json" "$INSTALL_DIR/"
cp "$REPO_DIR/morning-report.md" "$INSTALL_DIR/"
cp "$REPO_DIR/scripts/restart-preview.sh" "$INSTALL_DIR/scripts/"
chmod +x "$INSTALL_DIR/scripts/restart-preview.sh"
cp "$REPO_DIR/config.example.json" "$INSTALL_DIR/"

# Fresh install only
if [[ "$MODE" == "install" ]]; then
  cp "$INSTALL_DIR/config.example.json" "$INSTALL_DIR/config.json"
  echo ""
  echo "Edit your config before first run:"
  echo "  \$EDITOR ~/.night-agent/config.json"
  echo ""
  if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "Warning: $BIN_DIR is not in your \$PATH."
    echo "Add this to your shell profile:"
    echo "  export PATH=\"\$HOME/bin:\$PATH\""
    echo ""
  fi
  echo "Done. Run 'night-agent' to start."
else
  echo "Updated. Config left untouched."
fi
