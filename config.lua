-- Whisper Dictation Configuration

return {
    -- Language for transcription
    -- "de" = German, "en" = English, "auto" = auto-detect
    language = "de",

    -- Whisper model (must be downloaded first)
    -- Options: "ggml-tiny.bin", "ggml-base.bin", "ggml-small.bin", "ggml-medium.bin", "ggml-large.bin"
    model = "ggml-large.bin",

    -- Hotkey to start/stop recording
    -- Keycode of the key (10 = ^ on German keyboard)
    -- Tip: Press a key and check the Hammerspoon Console for the keycode
    hotkey = {
        keycode = 10,        -- Keycode of the key
        modifiers = {},      -- Modifiers: {"cmd"}, {"alt"}, {"ctrl"}, {"shift"} or combinations
    },

    -- Alternative hotkeys (optional)
    alternativeHotkeys = {
        -- { keycode = 98, modifiers = {} },  -- e.g. F7
    },

    -- Auto-paste after transcription (Cmd+V)
    autoPaste = true,

    -- Paths (usually no need to change)
    paths = {
        models = os.getenv("HOME") .. "/.whisper/models/",
        recording = "/tmp/whisper-recording.wav",
        whisperCli = "/opt/homebrew/bin/whisper-cli",
        rec = "/opt/homebrew/bin/rec",
    },
}
