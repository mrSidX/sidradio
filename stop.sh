#!/bin/bash
# stop.sh — forcefully stop smart.sh and all ffmpeg streams

echo "Stopping smart.sh and all ffmpeg processes..."

# Kill the smart.sh parent script first
pkill -f smart.sh

# Kill all ffmpeg processes
pkill -f ffmpeg

echo "All processes stopped."
