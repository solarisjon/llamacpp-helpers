# llamacpp-helpers

Shell scripts to build, manage, and run [llama.cpp](https://github.com/ggml-org/llama.cpp) on macOS, optimised for Apple Silicon (Metal).

## Scripts

| Script | Description |
|---|---|
| `llama-build` | Build llama.cpp from source and install to `~/.local` |
| `llama-router` | Start/stop llama-server in router mode (dynamic model loading) |
| `llama-model` | Manage local GGUF models and router presets |

## Install

```bash
git clone https://github.com/solarisjon/llamacpp-helpers.git
cd llamacpp-helpers
./install.sh
```

`install.sh` copies the scripts to `~/.local/bin` and seeds config files in `~/.config/llama/` (existing config is never overwritten).

Make sure `~/.local/bin` is on your `PATH`.

## Quick start

### 1. Build llama.cpp

Point the build at your llama.cpp checkout:

```bash
# One-time: set the source path in config
# LLAMA_SRC_DIR defaults to ~/Desktop/src/LLAMA-cpp/llama.cpp
llama-build
```

Flags used: Metal ON, embedded shaders, Accelerate ON, static libs, Release, `-j` = all CPU cores.

```bash
llama-build --clean      # full rebuild
llama-build --update     # git pull then build
llama-build --src /path  # custom source dir
llama-build --prefix /path  # custom install prefix (default: ~/.local)
```

### 2. Add models

Drop GGUF files into `~/.local/share/llama/models/`, or pull from Hugging Face:

```bash
llama-model pull ggml-org/gemma-3-4b-it-GGUF "gemma-3-4b-it-Q4_K_M.gguf"
llama-model list
```

### 3. Start the router

```bash
llama-router start          # daemonised, health-checked
llama-router status         # shows running models
llama-router logs -f        # follow log
llama-router stop
```

The router discovers all GGUF files in your models directory and loads/unloads them on demand, up to `LLAMA_MODELS_MAX` simultaneously (default 2, configurable for your RAM).

### 4. Make requests

The router exposes an OpenAI-compatible API at `http://127.0.0.1:8080/v1`. Route to a specific model via the `model` field:

```bash
curl http://127.0.0.1:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemma-3-4b-it-Q4_K_M",
    "messages": [{"role":"user","content":"Hello"}]
  }'
```

## Configuration

All scripts read `~/.config/llama/llama.conf` (shell-sourced):

```sh
LLAMA_SRC_DIR="$HOME/Desktop/src/LLAMA-cpp/llama.cpp"
LLAMA_HOST=127.0.0.1
LLAMA_PORT=8080
LLAMA_MODELS_DIR="$HOME/.local/share/llama/models"
LLAMA_MODELS_MAX=2       # how many models to hold in memory simultaneously
```

## Model presets

`~/.config/llama/models.ini` lets you give each model custom settings (context size, GPU layers, draft model, etc.). The format is llama.cpp's native INI:

```ini
version = 1

[*]
; global defaults
c = 8192
n-gpu-layers = 999
jinja = true

[coder]
model = /abs/path/to/Qwen2.5-Coder-14B-Q4_K_M.gguf
c = 32768
load-on-startup = true
```

Edit presets with:

```bash
llama-model edit      # opens models.ini in $EDITOR
llama-model presets   # list all preset names
```

## Requirements

- macOS 13+ (Apple Silicon recommended)
- [cmake](https://cmake.org/) (`brew install cmake`)
- Xcode Command Line Tools
- [huggingface-hub](https://github.com/huggingface/huggingface_hub) (`pip install -U huggingface_hub`) — only needed for `llama-model pull`
