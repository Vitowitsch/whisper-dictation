# 🎤 Whisper Dictation

Speech-to-text for macOS using OpenAI Whisper. Works in any app with a global hotkey.

**Press a key → Speak → Text appears.**

![Demo](https://img.shields.io/badge/macOS-Apple%20Silicon-green) ![License](https://img.shields.io/badge/license-MIT-blue)

## Features

- **Two backends** - Local (free, offline) or OpenAI API (paid, better quality)
- **Global hotkey** - Works in any app
- **Fast** - Optimized for Apple Silicon (M1/M2/M3)
- **Configurable** - Language, model, hotkey customizable

## Requirements

- macOS (Apple Silicon recommended)
- [Homebrew](https://brew.sh)
- ffmpeg (installed automatically)

## Installation

```bash
git clone https://github.com/Vitowitsch/whisper-dictation.git
cd whisper-dictation
chmod +x install.sh
./install.sh
```

The script automatically installs:
- whisper.cpp (local Whisper engine)
- ffmpeg (audio recording)
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

## Backends

### Local (default)

Free, offline, runs entirely on your Mac.

```lua
backend = "local",
localModel = "ggml-large.bin",
```

### OpenAI API (optional)

Better quality, requires API key and costs ~$0.006/min.

1. Get an API key from [platform.openai.com](https://platform.openai.com/api-keys)

2. Save your key:
   ```bash
   mkdir -p ~/.config/openai
   echo "sk-your-api-key" > ~/.config/openai/api_key
   chmod 600 ~/.config/openai/api_key
   ```

3. Edit `~/.hammerspoon/config.lua`:
   ```lua
   backend = "openai",
   ```

4. Reload Hammerspoon config (🔨 → Reload Config)

| Model | Quality | Cost |
|-------|---------|------|
| `whisper-1` | Good | $0.006/min |
| `gpt-4o-transcribe` | Best | $0.006/min |

## Configuration

Edit `~/.hammerspoon/config.lua`:

```lua
return {
    -- Backend: "local" (free) or "openai" (paid, better)
    backend = "local",

    -- Language: "de", "en", "auto"
    language = "de",

    -- Local model
    localModel = "ggml-large.bin",

    -- OpenAI settings
    openai = {
        model = "gpt-4o-transcribe",
    },

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

## Local Models

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
- Or switch to OpenAI backend for faster cloud processing

### Wrong language detected
- Change `language` in config.lua
- Use `"auto"` for automatic detection

### OpenAI API errors
- Check if your API key is valid
- Check if you have credits on platform.openai.com
- Check the Hammerspoon Console for error details

## Uninstall

```bash
# Remove Hammerspoon config
rm ~/.hammerspoon/init.lua ~/.hammerspoon/config.lua ~/.hammerspoon/transcribe-openai.sh

# Remove API key (if used)
rm -rf ~/.config/openai

# Remove models (optional, saves disk space)
rm -rf ~/.whisper

# Remove Homebrew packages (optional)
brew uninstall whisper-cpp ffmpeg
brew uninstall --cask hammerspoon
```

## Local vs Cloud

| | Local | OpenAI API |
|--|-------|------------|
| Cost | **Free** | ~$0.006/min |
| Privacy | **Local** | Data transmitted |
| Offline | **Yes** | No |
| Quality | Good | **Better** |
| Speed | Depends on model | Fast |

## Credits

- [whisper.cpp](https://github.com/ggerganov/whisper.cpp) - Fast C++ implementation of Whisper
- [OpenAI Whisper](https://github.com/openai/whisper) - The original model
- [Hammerspoon](https://www.hammerspoon.org/) - macOS automation

## License

MIT
