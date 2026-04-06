#!/bin/sh
set -e

ollama serve &
PID=$!

sleep 5

# wait until ollama respond
# until curl -s http://localhost:11434 > /dev/null; do
#   sleep 1
# done

ollama pull qwen2.5:1.5b

wait $PID