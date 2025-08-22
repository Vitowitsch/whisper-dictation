# 🎤 Whisper Dictation

Lokale Spracherkennung für macOS mit OpenAI Whisper. Kostenlos, offline, keine API-Keys nötig.

**Drücke eine Taste → Sprich → Text erscheint.**

![Demo](https://img.shields.io/badge/macOS-Apple%20Silicon-green) ![License](https://img.shields.io/badge/license-MIT-blue)

## Features

- **Komplett lokal** - Keine Cloud, keine Kosten, keine Limits
- **Offline nutzbar** - Funktioniert ohne Internet
- **Globaler Hotkey** - Funktioniert in jeder App
- **Schnell** - Optimiert für Apple Silicon (M1/M2/M3)
- **Konfigurierbar** - Sprache, Modell, Hotkey anpassbar

## Voraussetzungen

- macOS (Apple Silicon empfohlen)
- [Homebrew](https://brew.sh)

## Installation

```bash
git clone https://github.com/sanvito/whisper-dictation.git
cd whisper-dictation
chmod +x install.sh
./install.sh
```

Das Script installiert automatisch:
- whisper.cpp (lokale Whisper-Engine)
- sox (Audio-Aufnahme)
- Hammerspoon (Hotkey-Automation)

### Berechtigungen erteilen (manuell)

Nach der Installation musst du Hammerspoon Berechtigungen geben:

1. **Hammerspoon öffnen:** `open -a Hammerspoon`

2. **Bedienungshilfen:**
   - Systemeinstellungen → Datenschutz & Sicherheit → Bedienungshilfen
   - Hammerspoon aktivieren ✓

3. **Mikrofon:**
   - Systemeinstellungen → Datenschutz & Sicherheit → Mikrofon
   - Hammerspoon aktivieren ✓

4. **Config laden:** Klicke auf 🔨 in der Menüleiste → "Reload Config"

## Nutzung

| Aktion | Standard-Taste |
|--------|----------------|
| Aufnahme starten | `^` (Dach-Taste) |
| Aufnahme stoppen & transkribieren | `^` nochmal |

Der transkribierte Text wird automatisch in die aktive App eingefügt.

## Konfiguration

Bearbeite `~/.hammerspoon/config.lua`:

```lua
return {
    -- Sprache: "de", "en", "auto"
    language = "de",

    -- Modell: "ggml-tiny.bin", "ggml-base.bin", "ggml-small.bin",
    --         "ggml-medium.bin", "ggml-large.bin"
    model = "ggml-large.bin",

    -- Hotkey (Keycode der Taste)
    hotkey = {
        keycode = 10,    -- 10 = ^ auf deutscher Tastatur
        modifiers = {},  -- z.B. {"cmd"}, {"alt", "shift"}
    },

    -- Nach Transkription automatisch einfügen
    autoPaste = true,
}
```

### Keycode herausfinden

1. Öffne Hammerspoon Console (🔨 → Console)
2. Drücke die gewünschte Taste
3. Der Keycode erscheint in der Console

### Weiteres Modell herunterladen

```bash
# Beispiel: small-Modell
curl -L -o ~/.whisper/models/ggml-small.bin \
  "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin"
```

## Modelle

| Modell | Größe | RAM | Qualität | Geschwindigkeit |
|--------|-------|-----|----------|-----------------|
| tiny | 75 MB | ~400 MB | ⭐⭐ | Sehr schnell |
| base | 142 MB | ~500 MB | ⭐⭐⭐ | Schnell |
| small | 466 MB | ~1 GB | ⭐⭐⭐⭐ | Mittel |
| medium | 1.5 GB | ~2.6 GB | ⭐⭐⭐⭐⭐ | Langsamer |
| large | 1.5 GB | ~3 GB | ⭐⭐⭐⭐⭐ | Langsam* |

*large-v3-turbo ist optimiert und deutlich schneller als das original large-Modell.

## Troubleshooting

### "Keine Sprache erkannt"
- Sprich lauter oder näher am Mikrofon
- Prüfe ob das richtige Mikrofon ausgewählt ist (Systemeinstellungen → Ton)

### Hotkey funktioniert nicht
- Prüfe Bedienungshilfen-Berechtigung für Hammerspoon
- Öffne Hammerspoon Console und prüfe auf Fehlermeldungen
- Lade Config neu (🔨 → Reload Config)

### Transkription dauert lange
- Wechsle zu einem kleineren Modell (base oder small)
- Stelle sicher, dass keine anderen Whisper-Prozesse laufen

### Falsche Sprache erkannt
- Ändere `language` in der config.lua
- Nutze `"auto"` für automatische Erkennung

## Deinstallation

```bash
# Hammerspoon Config entfernen
rm ~/.hammerspoon/init.lua ~/.hammerspoon/config.lua

# Modelle entfernen (optional, spart Speicherplatz)
rm -rf ~/.whisper

# Homebrew-Pakete entfernen (optional)
brew uninstall whisper-cpp sox
brew uninstall --cask hammerspoon
```

## Warum lokal statt Cloud?

| | Lokal (dieses Projekt) | Cloud (API) |
|--|------------------------|-------------|
| Kosten | **Kostenlos** | ~$0.006/min |
| Privatsphäre | **Lokal** | Daten werden übertragen |
| Offline | **Ja** | Nein |
| Latenz | Gering | Netzwerk-abhängig |
| Limits | **Keine** | Rate limits |

## Credits

- [whisper.cpp](https://github.com/ggerganov/whisper.cpp) - Schnelle C++ Implementierung von Whisper
- [OpenAI Whisper](https://github.com/openai/whisper) - Das originale Modell
- [Hammerspoon](https://www.hammerspoon.org/) - macOS Automation

## Lizenz

MIT
