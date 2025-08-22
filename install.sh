#!/bin/bash
#
# Whisper Dictation Installer
# Installs all dependencies for local speech recognition on macOS
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════╗"
echo "║     🎤 Whisper Dictation Installer       ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# Check macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}Error: This script only works on macOS.${NC}"
    exit 1
fi

# Check Homebrew
echo -e "${YELLOW}[1/5] Checking Homebrew...${NC}"
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Homebrew not found. Install it first:${NC}"
    echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi
echo -e "${GREEN}✓ Homebrew found${NC}"

# Install dependencies
echo -e "${YELLOW}[2/5] Installing whisper.cpp and sox...${NC}"
brew install whisper-cpp sox

# Install Hammerspoon
echo -e "${YELLOW}[3/5] Installing Hammerspoon...${NC}"
if ! brew list --cask hammerspoon &> /dev/null; then
    brew install --cask hammerspoon
else
    echo -e "${GREEN}✓ Hammerspoon already installed${NC}"
fi

# Create directories
echo -e "${YELLOW}[4/5] Creating configuration...${NC}"
mkdir -p ~/.whisper/models
mkdir -p ~/.hammerspoon

# Copy configuration files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/config.lua" ~/.hammerspoon/config.lua
cp "$SCRIPT_DIR/init.lua" ~/.hammerspoon/init.lua

echo -e "${GREEN}✓ Configuration copied to ~/.hammerspoon/${NC}"

# Model selection
echo -e "${YELLOW}[5/5] Download Whisper model...${NC}"
echo ""
echo "Available models:"
echo "  1) tiny   (~75 MB)  - Fastest, lowest quality"
echo "  2) base   (~142 MB) - Fast, good quality"
echo "  3) small  (~466 MB) - Balanced"
echo "  4) medium (~1.5 GB) - High quality"
echo "  5) large  (~1.5 GB) - Best quality (large-v3-turbo)"
echo ""
read -p "Which model? [1-5, default: 5]: " model_choice

case "${model_choice:-5}" in
    1) MODEL="ggml-tiny.bin"; URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin" ;;
    2) MODEL="ggml-base.bin"; URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin" ;;
    3) MODEL="ggml-small.bin"; URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin" ;;
    4) MODEL="ggml-medium.bin"; URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.bin" ;;
    5) MODEL="ggml-large.bin"; URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin" ;;
    *) MODEL="ggml-large.bin"; URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin" ;;
esac

# Update config with selected model
sed -i '' "s/model = \".*\"/model = \"$MODEL\"/" ~/.hammerspoon/config.lua

if [[ -f ~/.whisper/models/$MODEL ]]; then
    echo -e "${GREEN}✓ Model $MODEL already exists${NC}"
else
    echo "Downloading $MODEL..."
    curl -L -o ~/.whisper/models/$MODEL "$URL"
    echo -e "${GREEN}✓ Model downloaded${NC}"
fi

# Finish
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✓ Installation complete!             ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Next steps (manual):${NC}"
echo ""
echo "1. Open Hammerspoon:"
echo "   open -a Hammerspoon"
echo ""
echo "2. Grant permissions in System Settings:"
echo "   • Privacy & Security → Accessibility → Hammerspoon ✓"
echo "   • Privacy & Security → Microphone → Hammerspoon ✓"
echo ""
echo "3. Click the Hammerspoon icon (🔨) → Reload Config"
echo ""
echo "4. Press the ^-key (caret) to start dictating!"
echo ""
echo -e "${BLUE}Tip: Edit ~/.hammerspoon/config.lua to change language or hotkey.${NC}"
