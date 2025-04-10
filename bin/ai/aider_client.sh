#!/usr/bin/env bash

aider \
    --model openrouter/google/gemini-2.5-pro-exp-03-25:free \
    --architect \
    --editor-model openrouter/google/gemini-2.0-flash-exp:free \
    --yes-always "$@"
