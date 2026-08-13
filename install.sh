#!/usr/bin/env bash
# Install the llama helper scripts into ~/.local/bin and seed config
# files in ~/.config/llama (existing config is never overwritten).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/llama"

mkdir -p "$BIN_DIR" "$CONFIG_DIR" "$HOME/.local/share/llama/models" \
         "${XDG_STATE_HOME:-$HOME/.local/state}/llama"

for s in llama-build llama-router llama-model; do
    install -m 0755 "$SCRIPT_DIR/$s" "$BIN_DIR/$s"
    echo "installed $BIN_DIR/$s"
done

for c in llama.conf models.ini; do
    if [ -f "$CONFIG_DIR/$c" ]; then
        echo "kept existing $CONFIG_DIR/$c"
    else
        install -m 0644 "$SCRIPT_DIR/$c" "$CONFIG_DIR/$c"
        echo "installed $CONFIG_DIR/$c"
    fi
done

echo
echo "Next steps:"
echo "  1. llama-build                 # build & install llama.cpp (Metal, Release)"
echo "  2. llama-model pull <hf-repo>  # download a GGUF model"
echo "  3. llama-router start          # start the router on http://127.0.0.1:8080"
