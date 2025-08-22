#!/bin/bash
#
# Whisper Dictation Installer
# Installiert alle Abhängigkeiten für lokale Spracherkennung auf macOS
#

set -e

# Farben
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

# Prüfe macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}Fehler: Dieses Script funktioniert nur auf macOS.${NC}"
    exit 1
fi

# Prüfe Homebrew
echo -e "${YELLOW}[1/5] Prüfe Homebrew...${NC}"
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Homebrew nicht gefunden. Installiere es zuerst:${NC}"
    echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi
echo -e "${GREEN}✓ Homebrew gefunden${NC}"

# Installiere Abhängigkeiten
echo -e "${YELLOW}[2/5] Installiere whisper.cpp und sox...${NC}"
brew install whisper-cpp sox

# Installiere Hammerspoon
echo -e "${YELLOW}[3/5] Installiere Hammerspoon...${NC}"
if ! brew list --cask hammerspoon &> /dev/null; then
    brew install --cask hammerspoon
else
    echo -e "${GREEN}✓ Hammerspoon bereits installiert${NC}"
fi

# Erstelle Verzeichnisse
echo -e "${YELLOW}[4/5] Erstelle Konfiguration...${NC}"
mkdir -p ~/.whisper/models
mkdir -p ~/.hammerspoon

# Kopiere Konfigurationsdateien
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/config.lua" ~/.hammerspoon/config.lua
cp "$SCRIPT_DIR/init.lua" ~/.hammerspoon/init.lua

echo -e "${GREEN}✓ Konfiguration kopiert nach ~/.hammerspoon/${NC}"

# Modell-Auswahl
echo -e "${YELLOW}[5/5] Whisper-Modell herunterladen...${NC}"
echo ""
echo "Verfügbare Modelle:"
echo "  1) tiny   (~75 MB)  - Schnellste, geringste Qualität"
echo "  2) base   (~142 MB) - Schnell, gute Qualität"
echo "  3) small  (~466 MB) - Ausgewogen"
echo "  4) medium (~1.5 GB) - Hohe Qualität"
echo "  5) large  (~1.5 GB) - Beste Qualität (large-v3-turbo)"
echo ""
read -p "Welches Modell? [1-5, Standard: 5]: " model_choice

case "${model_choice:-5}" in
    1) MODEL="ggml-tiny.bin"; URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin" ;;
    2) MODEL="ggml-base.bin"; URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin" ;;
    3) MODEL="ggml-small.bin"; URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin" ;;
    4) MODEL="ggml-medium.bin"; URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.bin" ;;
    5) MODEL="ggml-large.bin"; URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin" ;;
    *) MODEL="ggml-large.bin"; URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin" ;;
esac

# Aktualisiere Config mit gewähltem Modell
sed -i '' "s/model = \".*\"/model = \"$MODEL\"/" ~/.hammerspoon/config.lua

if [[ -f ~/.whisper/models/$MODEL ]]; then
    echo -e "${GREEN}✓ Modell $MODEL bereits vorhanden${NC}"
else
    echo "Lade $MODEL herunter..."
    curl -L -o ~/.whisper/models/$MODEL "$URL"
    echo -e "${GREEN}✓ Modell heruntergeladen${NC}"
fi

# Abschluss
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✓ Installation abgeschlossen!        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Nächste Schritte (manuell):${NC}"
echo ""
echo "1. Öffne Hammerspoon:"
echo "   open -a Hammerspoon"
echo ""
echo "2. Erteile Berechtigungen in Systemeinstellungen:"
echo "   • Datenschutz & Sicherheit → Bedienungshilfen → Hammerspoon ✓"
echo "   • Datenschutz & Sicherheit → Mikrofon → Hammerspoon ✓"
echo ""
echo "3. Klicke auf das Hammerspoon-Icon (🔨) → Reload Config"
echo ""
echo "4. Drücke die ^-Taste (Dach-Taste) zum Diktieren!"
echo ""
echo -e "${BLUE}Tipp: Bearbeite ~/.hammerspoon/config.lua um Sprache oder Hotkey zu ändern.${NC}"
