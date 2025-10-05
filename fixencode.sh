#!/bin/bash
cd ~/sid-live/music/beta
mkdir -p originals normalized || { echo "Failed to create directories"; exit 1; }
for f in *.mp3; do
  if [ -f "$f" ] && [[ "$f" != *_norm.mp3 ]]; then
    echo "Moving $f to originals..."
    mv "$f" originals/ || { echo "Failed to move $f to originals"; exit 1; }
    echo "Processing $f..."
    ffmpeg -i "originals/$f" -c:a mp3 -ar 44100 -b:a 128k "normalized/$f" && echo "Normalized $f"
  else
    echo "Skipping $f (already normalized or no MP3s found)"
  fi
done
echo "Replacing in beta with normalized files..."
mv normalized/*.mp3 . && rm -rf normalized
echo "Normalization complete. Originals preserved in $(pwd)/originals"