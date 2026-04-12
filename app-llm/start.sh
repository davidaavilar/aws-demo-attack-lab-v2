#!/bin/sh
set -e

ollama serve &
PID=$!

sleep 3

ollama pull qwen2.5:1.5b

wait $PID