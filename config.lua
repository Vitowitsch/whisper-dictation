-- Whisper Dictation Configuration

return {
    -- Backend: "local" (free, offline) or "openai" (paid, better quality)
    backend = "local",

    -- Language for transcription
    -- "de" = German, "en" = English, "auto" = auto-detect
    language = "de",

    -- Local backend settings (whisper.cpp)
    localModel = "ggml-large.bin",

    -- OpenAI backend settings
    openai = {
        -- Model: "whisper-1" or "gpt-4o-transcribe" (better)
        model = "gpt-4o-transcribe",
        -- API key: set via environment variable OPENAI_API_KEY
        -- or create file: ~/.config/openai/api_key
    },

    -- Hotkey to start/stop recording
    -- Keycode of the key (10 = ^ on German keyboard)
    hotkey = {
        keycode = 10,
        modifiers = {},
    },

    -- Alternative hotkeys (optional)
    alternativeHotkeys = {},

    -- Auto-paste after transcription (Cmd+V)
    autoPaste = true,

    -- Paths (usually no need to change)
    paths = {
        models = os.getenv("HOME") .. "/.whisper/models/",
        recording = "/tmp/whisper-recording.wav",
        whisperCli = "/opt/homebrew/bin/whisper-cli",
        rec = "/opt/homebrew/bin/rec",
        transcribeOpenai = os.getenv("HOME") .. "/.hammerspoon/transcribe-openai.sh",
    },
}
