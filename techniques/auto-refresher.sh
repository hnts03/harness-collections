#!/bin/bash
while true; do
  claude --model claude-haiku-4-5 -p "k"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Refreshed. Next refresh in 5h."
  sleep 5h
done
