#!/bin/bash

####This checks the music folder MUSIC_DIR: 
####builds the playlist.txt
####runs the ffmpeg stream,
####steam ends this wrapper rebuilds the directory of mp3 to playlist.txt



#!/bin/bash

MUSIC_DIR="./music/beta"
HLS_DIR="/var/www/live.sidthetech.com/hls"

while true; do
    echo "Scanning directory for MP3s..."
    > playlist.txt

    find "$MUSIC_DIR" -type f -name "*.mp3" | sort | while read -r file; do
        # Escape single quotes by closing, escaping, reopening
        safefile=$(printf "%s" "$file" | sed "s/'/'\\\\''/g")
        echo "file '$safefile'" >> playlist.txt
    done

    if [ ! -s playlist.txt ]; then
        echo "No MP3 files found, waiting 10 seconds..."
        sleep 10
        continue
    fi

    echo "Starting FFmpeg to play playlist once..."
    ffmpeg -re -stream_loop 1 -f concat -safe 0 -i playlist.txt \
        -c:a aac -b:a 128k \
        -f hls \
        -hls_time 6 \
        -hls_list_size 6 \
        -hls_flags delete_segments+append_list+omit_endlist \
        "$HLS_DIR/stream.m3u8"

    echo "Playlist finished, looping wrapper..."
done
