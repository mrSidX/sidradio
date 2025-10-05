#!/bin/bash


#THIS VERSION IS WORKING NICELY! - Oct 4, 2025
# This script continuously scans a directory for MP3 files and plays them in a loop using FFmpeg.
# It generates an HLS stream that can be served via a web server.
# Ensure you have FFmpeg installed and the necessary permissions to read the music directory and write to the HLS directory.

MUSIC_DIR="./music/beta"
HLS_DIR="/var/www/live.sidthetech.com/hls"

while true; do
    echo "Scanning directory for AAC files..."
    > playlist.txt

    find "$MUSIC_DIR" -type f -name "*.m4a" | sort | while read -r file; do
        safefile=$(printf "%s" "$file" | sed "s/'/'\\\\''/g")
        echo "file '$safefile'" >> playlist.txt
    done

    if [ ! -s playlist.txt ]; then
        echo "No audio files found, waiting 10 seconds..."
        sleep 10
        continue
    fi

    echo "Starting FFmpeg to play playlist once..."
    ffmpeg -re -f concat -safe 0 -i playlist.txt \
        -af aresample=async=1:first_pts=0 \
        -ar 44100 \
        -c:a aac -b:a 128k \
        -f hls \
        -hls_time 2 \
        -hls_list_size 10 \
        -hls_segment_type fmp4 \
        -hls_flags delete_segments+append_list+omit_endlist+independent_segments+split_by_time \
        -loglevel warning \
        "$HLS_DIR/stream.m3u8"

    echo "Playlist finished or FFmpeg exited, looping wrapper..."
done