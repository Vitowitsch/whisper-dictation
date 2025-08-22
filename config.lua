-- Whisper Dictation Configuration
-- Passe diese Einstellungen an deine Bedürfnisse an

return {
    -- Sprache für die Transkription
    -- "de" = Deutsch, "en" = English, "auto" = automatische Erkennung
    language = "de",

    -- Whisper-Modell (muss zuerst heruntergeladen werden)
    -- Optionen: "ggml-tiny.bin", "ggml-base.bin", "ggml-small.bin", "ggml-medium.bin", "ggml-large.bin"
    model = "ggml-large.bin",

    -- Hotkey zum Starten/Stoppen der Aufnahme
    -- Keycode der Taste (10 = ^ auf deutscher Tastatur)
    -- Tipp: Drücke eine Taste und schau in der Hammerspoon Console nach dem Keycode
    hotkey = {
        keycode = 10,        -- Keycode der Taste
        modifiers = {},      -- Modifier: {"cmd"}, {"alt"}, {"ctrl"}, {"shift"} oder Kombinationen
    },

    -- Alternative Hotkeys (optional)
    alternativeHotkeys = {
        -- { keycode = 98, modifiers = {} },  -- z.B. F7
    },

    -- Nach Transkription automatisch einfügen (Cmd+V)
    autoPaste = true,

    -- Pfade (normalerweise nicht ändern nötig)
    paths = {
        models = os.getenv("HOME") .. "/.whisper/models/",
        recording = "/tmp/whisper-recording.wav",
        whisperCli = "/opt/homebrew/bin/whisper-cli",
        rec = "/opt/homebrew/bin/rec",
    },
}
