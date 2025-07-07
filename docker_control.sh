#!/bin/bash
# Turn on container when USB connected and turn off when disconnected.

CONTAINER_NAME="RigCtl"
DEVICE_PATH="/dev/ttyUSB0"

while true; do
  if [ -c "$DEVICE_PATH" ]; then
    if [ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null)" != "true" ]; then
      docker start "$CONTAINER_NAME"
    fi
  else
    if [ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null)" = "true" ]; then
      docker stop "$CONTAINER_NAME"
    fi
  fi
  sleep 5
done
