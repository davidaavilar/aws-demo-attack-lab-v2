#!/bin/sh
set -e

ollama serve &
PID=$!

sleep 3

ollama pull gemma4:e2b-it-q4_K_M

wait $PID