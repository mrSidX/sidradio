#!/bin/bash

cd ~/sid-live/music/beta || { echo "Failed to change to ~/sid-live/music/beta"; exit 1; }
mkdir -p originals aac || { echo "Failed to create directories"; exit 1; }
LOGFILE="convert_aac.log"

# Check if any MP3 files exist
if ! ls *.mp3 >/dev/null 2>&1; then
    echo "No MP3 files found in $(pwd)" | tee -a "$LOGFILE"
    exit 0
fi

for f in *.mp3; do
    if [ -f "$f" ] && [[ "$f" != *.m4a ]]; then
        echo "Moving $f to originals..." | tee -a "$LOGFILE"
        mv "$f" originals/ || { echo "Failed to move $f to originals" | tee -a "$LOGFILE"; exit 1; }
        echo "Converting $f to AAC..." | tee -a "$LOGFILE"
        ffmpeg -i "originals/$f" -c:a aac -ar 44100 -b:a 128k "aac/${f%.mp3}.m4a" >>"$LOGFILE" 2>&1
        if [ $? -eq 0 ]; then
            echo "Converted $f to ${f%.mp3}.m4a" | tee -a "$LOGFILE"
        else
            echo "Failed to convert $f" | tee -a "$LOGFILE"
            exit 1
        fi
    else
        echo "Skipping $f (already converted or no MP3s found)" | tee -a "$LOGFILE"
    fi
done

echo "Replacing in beta with AAC files..." | tee -a "$LOGFILE"
mv aac/*.m4a . && rm -rf aac || { echo "Failed to move AAC files" | tee -a "$LOGFILE"; exit 1; }
echo "Conversion complete. Originals preserved in $(pwd)/originals" | tee -a "$LOGFILE"