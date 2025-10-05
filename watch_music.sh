#!/bin/bash

MUSIC_DIR="/home/sid/sid-live/music/beta"
WATCH_DIR="$MUSIC_DIR/incoming"
LOGFILE="$MUSIC_DIR/watch_music.log"

mkdir -p "$WATCH_DIR" || { echo "Failed to create $WATCH_DIR" | tee -a "$LOGFILE"; exit 1; }

while true; do
    inotifywait -m "$WATCH_DIR" -e create -e moved_to |
        while read -r path action file; do
            if [[ "$file" =~ \.mp3$ ]]; then
                echo "Converting $file to AAC..." | tee -a "$LOGFILE"
                ffmpeg -i "$WATCH_DIR/$file" -c:a aac -ar 44100 -b:a 128k "$MUSIC_DIR/${file%.mp3}.m4a" >>"$LOGFILE" 2>&1
                if [ $? -eq 0 ]; then
                    echo "Converted $file to ${file%.mp3}.m4a" | tee -a "$LOGFILE"
                    rm "$WATCH_DIR/$file"
                else
                    echo "Failed to convert $file" | tee -a "$LOGFILE"
                fi
            fi
        done
    sleep 1
done