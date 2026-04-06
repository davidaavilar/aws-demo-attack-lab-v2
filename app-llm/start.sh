#!/bin/sh
set -e

ollama serve &
PID=$!

# wait until ollama respond #
until curl -s http://localhost:11434 > /dev/null; do
  sleep 1
done

ollama pull qwen2.5:7b

wait $PID