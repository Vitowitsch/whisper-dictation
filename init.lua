-- Whisper Dictation for Hammerspoon
-- https://github.com/Vitowitsch/whisper-dictation

-- Load configuration
local configPath = os.getenv("HOME") .. "/.hammerspoon/config.lua"
local config = dofile(configPath)

require("hs.ipc")

-- State
local recording = false
local recordingTask = nil

-- Paths from config
local modelPath = config.paths.models .. config.model
local recordingFile = config.paths.recording

-- Debug logging
local function log(msg)
    print("🎤 " .. msg)
end

-- Status display
local function showStatus(text, color)
    hs.alert.show(text, {
        fillColor = color or { red = 0.2, green = 0.2, blue = 0.2, alpha = 0.9 },
        textColor = { white = 1, alpha = 1 },
        textSize = 18,
    }, 2)
end

-- Start recording
local function startRecording()
    log("Starting recording...")
    recording = true
    showStatus("🎤 Recording...", { red = 0.8, green = 0.2, blue = 0.2, alpha = 0.9 })

    os.remove(recordingFile)
    recordingTask = hs.task.new(config.paths.rec, function(code, out, err)
        log("rec finished with code: " .. tostring(code))
        if err and #err > 0 then log("rec error: " .. err) end
    end, {
        "-q",           -- quiet
        "-r", "16000",  -- sample rate
        "-c", "1",      -- mono
        "-b", "16",     -- bit depth
        recordingFile,
        "trim", "0", "300"  -- max 5 minutes, prevents auto-stop
    })

    if recordingTask then
        recordingTask:start()
        log("Recording started")
    else
        log("ERROR: Could not create recording task")
        showStatus("Error: rec not found", { red = 0.8, green = 0.2, blue = 0.2, alpha = 0.9 })
    end
end

-- Stop recording and transcribe
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

    showStatus("⏳ Transcribing...", { red = 0.2, green = 0.5, blue = 0.8, alpha = 0.9 })

    hs.timer.doAfter(0.5, function()
        -- Check if file exists
        local f = io.open(recordingFile, "r")
        if not f then
            log("ERROR: Recording file not found")
            showStatus("Error: No recording", { red = 0.8, green = 0.2, blue = 0.2, alpha = 0.9 })
            return
        end
        f:close()

        log("Transcribing with model: " .. config.model)
        local task = hs.task.new(config.paths.whisperCli, function(exitCode, stdOut, stdErr)
            log("whisper exitCode: " .. tostring(exitCode))
            if stdErr and #stdErr > 0 then log("whisper stderr: " .. stdErr) end

            if exitCode == 0 and stdOut and #stdOut > 0 then
                -- Clean output (remove timestamps and whitespace)
                local text = stdOut:gsub("%[.-%]", ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("\n", " ")

                if #text > 0 then
                    -- Copy to clipboard
                    hs.pasteboard.setContents(text)

                    -- Optional: paste into active app
                    if config.autoPaste then
                        hs.eventtap.keyStroke({"cmd"}, "v")
                    end

                    showStatus("✓ " .. text:sub(1, 50) .. (text:len() > 50 and "..." or ""),
                        { red = 0.2, green = 0.7, blue = 0.3, alpha = 0.9 })
                    log("Success: " .. text)
                else
                    showStatus("No speech detected", { red = 0.8, green = 0.5, blue = 0.2, alpha = 0.9 })
                end
            else
                showStatus("Transcription error", { red = 0.8, green = 0.2, blue = 0.2, alpha = 0.9 })
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
            showStatus("Error: whisper-cli not found", { red = 0.8, green = 0.2, blue = 0.2, alpha = 0.9 })
        end
    end)
end

-- Toggle recording
local function toggleRecording()
    log("Toggle called, recording=" .. tostring(recording))
    if recording then
        stopRecording()
    else
        startRecording()
    end
end

-- Setup hotkeys
log("Setting up hotkeys...")

-- Main hotkey
hs.hotkey.bind(config.hotkey.modifiers, config.hotkey.keycode, function()
    log("Hotkey pressed (keycode " .. config.hotkey.keycode .. ")")
    toggleRecording()
end)

-- Alternative hotkeys
for _, hk in ipairs(config.alternativeHotkeys or {}) do
    hs.hotkey.bind(hk.modifiers or {}, hk.keycode, function()
        log("Alternative hotkey pressed (keycode " .. hk.keycode .. ")")
        toggleRecording()
    end)
end

-- Startup message
log("Whisper Dictation ready!")
log("Model: " .. config.model)
log("Language: " .. config.language)
log("Hotkey keycode: " .. config.hotkey.keycode)

hs.alert.show("🎤 Whisper ready - Press ^ to dictate", 2)
