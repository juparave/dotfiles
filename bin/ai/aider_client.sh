#!/usr/bin/env bash

# Free models
# openrouter/qwen/qwen3-235b-a22b:free

# aider \
#     --architect \
#     --model openrouter/deepseek/deepseek-chat-v3-0324 \
#     --editor-model openrouter/google/gemini-2.0-flash-exp:free \
#     --dark-mode \
#     "$@"

aider \
    --architect \
    --model gemini/gemini-2.5-flash
    --editor-model openrouter/google/gemini-2.0-flash-exp:free \
    --dark-mode \
    "$@"
