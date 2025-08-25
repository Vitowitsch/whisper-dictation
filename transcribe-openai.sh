#!/bin/bash
#
# Transcribe audio using OpenAI Whisper API
# Usage: transcribe-openai.sh <audio_file> <language> <model>
#

AUDIO_FILE="$1"
LANGUAGE="${2:-de}"
MODEL="${3:-gpt-4o-transcribe}"

# API Key from environment or config file
if [[ -z "$OPENAI_API_KEY" ]]; then
    if [[ -f "$HOME/.config/openai/api_key" ]]; then
        OPENAI_API_KEY=$(cat "$HOME/.config/openai/api_key")
    else
        echo "Error: OPENAI_API_KEY not set" >&2
        exit 1
    fi
fi

if [[ ! -f "$AUDIO_FILE" ]]; then
    echo "Error: Audio file not found: $AUDIO_FILE" >&2
    exit 1
fi

# Call OpenAI API
RESPONSE=$(curl -s "https://api.openai.com/v1/audio/transcriptions" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: multipart/form-data" \
    -F "file=@$AUDIO_FILE" \
    -F "model=$MODEL" \
    -F "language=$LANGUAGE" \
    -F "response_format=text")

# Check for error
if echo "$RESPONSE" | grep -q '"error"'; then
    echo "API Error: $RESPONSE" >&2
    exit 1
fi

echo "$RESPONSE"
