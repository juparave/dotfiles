#!/usr/bin/env bash

aider \
    --architect \
    --model openrouter/google/gemini-2.5-pro-exp-03-25:free \
    --editor-model openrouter/google/gemini-2.0-flash-exp:free \
    --dark-mode \
    "$@"
