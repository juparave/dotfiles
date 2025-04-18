#!/usr/bin/env bash

aider \
    --architect \
    --model openrouter/deepseek/deepseek-r1:free \
    --editor-model openrouter/google/gemini-2.0-flash-001 \
    --dark-mode \
    "$@"
