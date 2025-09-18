#!/usr/bin/env bash
set -euo pipefail
PORT="${1:-8001}"
MODEL="${MODEL_NAME:-Qwen/Qwen3-0.6B}"

curl -sS -X POST \
 "http://127.0.0.1:${PORT}/v1/chat/completions" \
 -H "accept: application/json" \
 -H "Content-Type: application/json" \
 -d "{
  \"model\": \"${MODEL}\",
  \"messages\": [
    {\"role\": \"system\", \"content\": \"You are a helpful AI coding assistant.\"},
    {\"role\": \"user\", \"content\": \"Write a segment tree implementation in python\"}
  ],
  \"max_tokens\": 150
 }" | jq '.choices[0].message.content // .'
