# 🎤 Whisper Dictation

Local speech-to-text for macOS using OpenAI Whisper. Free, offline, no API keys required.

**Press a key → Speak → Text appears.**

![Demo](https://img.shields.io/badge/macOS-Apple%20Silicon-green) ![License](https://img.shields.io/badge/license-MIT-blue)

## Features

- **Fully local** - No cloud, no costs, no limits
- **Works offline** - No internet connection required
- **Global hotkey** - Works in any app
- **Fast** - Optimized for Apple Silicon (M1/M2/M3)
- **Configurable** - Language, model, hotkey customizable

## Requirements

- macOS (Apple Silicon recommended)
- [Homebrew](https://brew.sh)

## Installation

```bash
git clone https://github.com/Vitowitsch/whisper-dictation.git
cd whisper-dictation
chmod +x install.sh
./install.sh
```

The script automatically installs:
- whisper.cpp (local Whisper engine)
- sox (audio recording)
- Hammerspoon (hotkey automation)

### Grant Permissions (manual)

After installation, you need to grant Hammerspoon permissions:

1. **Open Hammerspoon:** `open -a Hammerspoon`

2. **Accessibility:**
   - System Settings → Privacy & Security → Accessibility
   - Enable Hammerspoon ✓

3. **Microphone:**
   - System Settings → Privacy & Security → Microphone
   - Enable Hammerspoon ✓

4. **Load config:** Click 🔨 in the menu bar → "Reload Config"

## Usage

| Action | Default Key |
|--------|-------------|
| Start recording | `^` (caret key) |
| Stop recording & transcribe | `^` again |

The transcribed text is automatically pasted into the active app.

## Configuration

Edit `~/.hammerspoon/config.lua`:

```lua
return {
    -- Language: "de", "en", "auto"
    language = "de",

    -- Model: "ggml-tiny.bin", "ggml-base.bin", "ggml-small.bin",
    --        "ggml-medium.bin", "ggml-large.bin"
    model = "ggml-large.bin",

    -- Hotkey (keycode of the key)
    hotkey = {
        keycode = 10,    -- 10 = ^ on German keyboard
        modifiers = {},  -- e.g. {"cmd"}, {"alt", "shift"}
    },

    -- Auto-paste after transcription
    autoPaste = true,
}
```

### Finding Keycodes

1. Open Hammerspoon Console (🔨 → Console)
2. Press the desired key
3. The keycode appears in the console

### Download Additional Models

```bash
# Example: small model
curl -L -o ~/.whisper/models/ggml-small.bin \
  "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin"
```

## Models

| Model | Size | RAM | Quality | Speed |
|-------|------|-----|---------|-------|
| tiny | 75 MB | ~400 MB | ⭐⭐ | Very fast |
| base | 142 MB | ~500 MB | ⭐⭐⭐ | Fast |
| small | 466 MB | ~1 GB | ⭐⭐⭐⭐ | Medium |
| medium | 1.5 GB | ~2.6 GB | ⭐⭐⭐⭐⭐ | Slower |
| large | 1.5 GB | ~3 GB | ⭐⭐⭐⭐⭐ | Slow* |

*large-v3-turbo is optimized and significantly faster than the original large model.

## Troubleshooting

### "No speech detected"
- Speak louder or closer to the microphone
- Check if the correct microphone is selected (System Settings → Sound)

### Hotkey not working
- Check Accessibility permission for Hammerspoon
- Open Hammerspoon Console and check for error messages
- Reload config (🔨 → Reload Config)

### Transcription takes too long
- Switch to a smaller model (base or small)
- Make sure no other Whisper processes are running

### Wrong language detected
- Change `language` in config.lua
- Use `"auto"` for automatic detection

## Uninstall

```bash
# Remove Hammerspoon config
rm ~/.hammerspoon/init.lua ~/.hammerspoon/config.lua

# Remove models (optional, saves disk space)
rm -rf ~/.whisper

# Remove Homebrew packages (optional)
brew uninstall whisper-cpp sox
brew uninstall --cask hammerspoon
```

## Why Local Instead of Cloud?

| | Local (this project) | Cloud (API) |
|--|----------------------|-------------|
| Cost | **Free** | ~$0.006/min |
| Privacy | **Local** | Data transmitted |
| Offline | **Yes** | No |
| Latency | Low | Network-dependent |
| Limits | **None** | Rate limits |

## Credits

- [whisper.cpp](https://github.com/ggerganov/whisper.cpp) - Fast C++ implementation of Whisper
- [OpenAI Whisper](https://github.com/openai/whisper) - The original model
- [Hammerspoon](https://www.hammerspoon.org/) - macOS automation

## License

MIT
