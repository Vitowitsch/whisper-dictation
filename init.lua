-- Whisper Dictation für Hammerspoon
-- https://github.com/sanvito/whisper-dictation
--
-- Drücke den konfigurierten Hotkey zum Starten der Aufnahme,
-- nochmal drücken zum Stoppen und Transkribieren.

-- Lade Konfiguration
local configPath = os.getenv("HOME") .. "/.hammerspoon/config.lua"
local config = dofile(configPath)

-- IPC für CLI-Zugriff
require("hs.ipc")

-- State
local recording = false
local recordingTask = nil

-- Pfade aus Config
local modelPath = config.paths.models .. config.model
local recordingFile = config.paths.recording

-- Debug logging
local function log(msg)
    print("🎤 " .. msg)
end

-- Status-Anzeige
local function showStatus(text, color)
    hs.alert.show(text, {
        fillColor = color or { red = 0.2, green = 0.2, blue = 0.2, alpha = 0.9 },
        textColor = { white = 1, alpha = 1 },
        textSize = 18,
    }, 2)
end

-- Aufnahme starten
local function startRecording()
    log("Starting recording...")
    recording = true
    showStatus("🎤 Aufnahme läuft...", { red = 0.8, green = 0.2, blue = 0.2, alpha = 0.9 })

    os.remove(recordingFile)
    recordingTask = hs.task.new(config.paths.rec, function(code, out, err)
        log("rec finished with code: " .. tostring(code))
        if err and #err > 0 then log("rec error: " .. err) end
    end, {
        "-q", "-r", "16000", "-c", "1", "-b", "16", recordingFile
    })

    if recordingTask then
        recordingTask:start()
        log("Recording started")
    else
        log("ERROR: Could not create recording task")
        showStatus("Fehler: rec nicht gefunden", { red = 0.8, green = 0.2, blue = 0.2, alpha = 0.9 })
    end
end

-- Aufnahme stoppen und transkribieren
local function stopRecording()
    if not recording then
        log("Not recording, nothing to stop")
        return
    end

    log("Stopping recording...")
    recording = false

    if recordingTask then
        recordingTask:terminate()
        recordingTask = nil
    end

    showStatus("⏳ Transkribiere...", { red = 0.2, green = 0.5, blue = 0.8, alpha = 0.9 })

    hs.timer.doAfter(0.5, function()
        -- Prüfe ob Datei existiert
        local f = io.open(recordingFile, "r")
        if not f then
            log("ERROR: Recording file not found")
            showStatus("Fehler: Keine Aufnahme", { red = 0.8, green = 0.2, blue = 0.2, alpha = 0.9 })
            return
        end
        f:close()

        log("Transcribing with model: " .. config.model)
        local task = hs.task.new(config.paths.whisperCli, function(exitCode, stdOut, stdErr)
            log("whisper exitCode: " .. tostring(exitCode))
            if stdErr and #stdErr > 0 then log("whisper stderr: " .. stdErr) end

            if exitCode == 0 and stdOut and #stdOut > 0 then
                -- Bereinige Output (entferne Timestamps und Whitespace)
                local text = stdOut:gsub("%[.-%]", ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("\n", " ")

                if #text > 0 then
                    -- Kopiere in Zwischenablage
                    hs.pasteboard.setContents(text)

                    -- Optional: In aktive App einfügen
                    if config.autoPaste then
                        hs.eventtap.keyStroke({"cmd"}, "v")
                    end

                    showStatus("✓ " .. text:sub(1, 50) .. (text:len() > 50 and "..." or ""),
                        { red = 0.2, green = 0.7, blue = 0.3, alpha = 0.9 })
                    log("Success: " .. text)
                else
                    showStatus("Keine Sprache erkannt", { red = 0.8, green = 0.5, blue = 0.2, alpha = 0.9 })
                end
            else
                showStatus("Fehler bei Transkription", { red = 0.8, green = 0.2, blue = 0.2, alpha = 0.9 })
            end
            os.remove(recordingFile)
        end, {
            "-m", modelPath,
            "-l", config.language,
            "-f", recordingFile,
            "--no-timestamps"
        })

        if task then
            task:start()
        else
            log("ERROR: Could not create whisper task")
            showStatus("Fehler: whisper-cli nicht gefunden", { red = 0.8, green = 0.2, blue = 0.2, alpha = 0.9 })
        end
    end)
end

-- Toggle Aufnahme
local function toggleRecording()
    log("Toggle called, recording=" .. tostring(recording))
    if recording then
        stopRecording()
    else
        startRecording()
    end
end

-- Hotkeys einrichten
log("Setting up hotkeys...")

-- Haupt-Hotkey
hs.hotkey.bind(config.hotkey.modifiers, config.hotkey.keycode, function()
    log("Hotkey pressed (keycode " .. config.hotkey.keycode .. ")")
    toggleRecording()
end)

-- Alternative Hotkeys
for _, hk in ipairs(config.alternativeHotkeys or {}) do
    hs.hotkey.bind(hk.modifiers or {}, hk.keycode, function()
        log("Alternative hotkey pressed (keycode " .. hk.keycode .. ")")
        toggleRecording()
    end)
end

-- Eventtap für Keycode-Debug (hilfreich um Keycodes zu finden)
keyWatcher = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
    local keyCode = event:getKeyCode()
    local char = event:getCharacters()
    -- Nur loggen wenn spezielle Tasten gedrückt werden
    if keyCode == config.hotkey.keycode or char == "^" then
        log("Detected key: code=" .. keyCode .. " char=" .. tostring(char))
    end
    return false
end)
keyWatcher:start()

-- Startup-Nachricht
log("Whisper Dictation ready!")
log("Model: " .. config.model)
log("Language: " .. config.language)
log("Hotkey keycode: " .. config.hotkey.keycode)

hs.alert.show("🎤 Whisper Dictation bereit", 2)
