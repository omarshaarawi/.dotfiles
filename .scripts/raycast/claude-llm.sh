#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title LLM
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "Prompt" }

# Documentation:
# @raycast.description LLM
# @raycast.author vladstudio
# @raycast.authorURL https://raycast.com/vladstudio

llm -m claude-3-opus "$1"
