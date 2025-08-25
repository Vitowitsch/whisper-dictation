-- Whisper Dictation for Hammerspoon
-- https://github.com/Vitowitsch/whisper-dictation

-- Load configuration
local configPath = os.getenv("HOME") .. "/.hammerspoon/config.lua"
local config = dofile(configPath)

require("hs.ipc")

-- State
local recording = false
local recordingTask = nil

-- Paths
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

-- Start recording with ffmpeg (more stable than sox)
local function startRecording()
    if recording then
        log("Already recording, ignoring")
        return
    end

    log("Starting recording...")
    recording = true

    local backendLabel = config.backend == "openai" and "☁️" or "💻"
    showStatus(backendLabel .. " Recording...", { red = 0.8, green = 0.2, blue = 0.2, alpha = 0.9 })

    os.remove(recordingFile)

    -- Use ffmpeg for recording - more stable than sox
    recordingTask = hs.task.new("/opt/homebrew/bin/ffmpeg", function(code, out, err)
        log("ffmpeg finished with code: " .. tostring(code))
    end, {
        "-y",                    -- overwrite
        "-f", "avfoundation",    -- macOS audio input
        "-i", ":0",              -- default audio input device
        "-ar", "16000",          -- sample rate
        "-ac", "1",              -- mono
        "-t", "300",             -- max 5 minutes
        recordingFile
    })

    if recordingTask then
        recordingTask:start()
        log("Recording started (backend: " .. config.backend .. ")")
    else
        log("ERROR: Could not start ffmpeg")
        showStatus("Error: ffmpeg not found", { red = 0.8, green = 0.2, blue = 0.2, alpha = 0.9 })
        recording = false
    end
end

-- Transcribe with local whisper.cpp
local function transcribeLocal(callback)
    local modelPath = config.paths.models .. config.localModel
    log("Transcribing locally with model: " .. config.localModel)

    local task = hs.task.new(config.paths.whisperCli, function(exitCode, stdOut, stdErr)
        log("whisper exitCode: " .. tostring(exitCode))
        if exitCode == 0 and stdOut then
            local text = stdOut:gsub("%[.-%]", ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("\n", " ")
            callback(text)
        else
            log("whisper error: " .. tostring(stdErr))
            callback(nil)
        end
    end, {
        "-m", modelPath,
        "-l", config.language,
        "-f", recordingFile,
        "--no-timestamps"
    })

    if task then
        task:start()
    else
        callback(nil)
    end
end

-- Transcribe with OpenAI API
local function transcribeOpenAI(callback)
    log("Transcribing with OpenAI API (model: " .. config.openai.model .. ")")

    local task = hs.task.new(config.paths.transcribeOpenai, function(exitCode, stdOut, stdErr)
        log("OpenAI API exitCode: " .. tostring(exitCode))
        if exitCode == 0 and stdOut then
            local text = stdOut:gsub("^%s+", ""):gsub("%s+$", "")
            callback(text)
        else
            log("OpenAI API error: " .. tostring(stdErr))
            callback(nil)
        end
    end, {
        recordingFile,
        config.language,
        config.openai.model
    })

    if task then
        task:start()
    else
        callback(nil)
    end
end

-- Stop recording and transcribe
local function stopRecording()
    if not recording then
        log("Not recording, ignoring")
        return
    end

    log("Stopping recording...")
    recording = false

    if recordingTask then
        -- Send SIGINT to ffmpeg for clean shutdown
        recordingTask:interrupt()
        hs.timer.doAfter(0.2, function()
            if recordingTask and recordingTask:isRunning() then
                recordingTask:terminate()
            end
            recordingTask = nil
        end)
    end

    local backendLabel = config.backend == "openai" and "☁️" or "💻"
    showStatus("⏳ Transcribing " .. backendLabel .. "...", { red = 0.2, green = 0.5, blue = 0.8, alpha = 0.9 })

    -- Wait for file to be written
    hs.timer.doAfter(0.8, function()
        local f = io.open(recordingFile, "r")
        if not f then
            log("ERROR: Recording file not found")
            showStatus("Error: No recording", { red = 0.8, green = 0.2, blue = 0.2, alpha = 0.9 })
            return
        end
        local size = f:seek("end")
        f:close()
        log("Recording file size: " .. tostring(size) .. " bytes")

        if size < 1000 then
            log("Recording too short")
            showStatus("Recording too short", { red = 0.8, green = 0.5, blue = 0.2, alpha = 0.9 })
            return
        end

        local function handleResult(text)
            if text and #text > 0 then
                hs.pasteboard.setContents(text)
                if config.autoPaste then
                    hs.eventtap.keyStroke({"cmd"}, "v")
                end
                showStatus("✓ " .. text:sub(1, 50) .. (text:len() > 50 and "..." or ""),
                    { red = 0.2, green = 0.7, blue = 0.3, alpha = 0.9 })
                log("Success: " .. text)
            else
                showStatus("No speech detected", { red = 0.8, green = 0.5, blue = 0.2, alpha = 0.9 })
            end
            os.remove(recordingFile)
        end

        if config.backend == "openai" then
            transcribeOpenAI(handleResult)
        else
            transcribeLocal(handleResult)
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

hs.hotkey.bind(config.hotkey.modifiers, config.hotkey.keycode, function()
    log("Hotkey pressed")
    toggleRecording()
end)

for _, hk in ipairs(config.alternativeHotkeys or {}) do
    hs.hotkey.bind(hk.modifiers or {}, hk.keycode, function()
        toggleRecording()
    end)
end

-- Startup message
local backendLabel = config.backend == "openai" and "OpenAI" or "Local"
log("Whisper Dictation ready!")
log("Backend: " .. backendLabel)

hs.alert.show("🎤 Whisper ready (" .. backendLabel .. ")", 2)
