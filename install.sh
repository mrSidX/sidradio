#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo (sudo ./install.sh)"
  exit 1
fi

# Detect script directory (repo root) as INSTALL_DIR
SCRIPT_DIR=$(dirname "$(realpath "$0")")
INSTALL_DIR="$SCRIPT_DIR"  # Use repo dir directly (e.g., ~/sid-live)

# Check for required files
if [ ! -f "$SCRIPT_DIR/smart.sh" ]; then
  echo "Error: smart.sh not found in $SCRIPT_DIR"
  exit 1
fi
if [ ! -f "$SCRIPT_DIR/src/html/index.html.template" ]; then
  echo "Error: src/html/index.html.template not found in $SCRIPT_DIR"
  exit 1
fi

# Wizard Prompts
read -p "What do you want to call your radio station service? (e.g., sidradio): " SERVICE_NAME
if [ -z "$SERVICE_NAME" ]; then
  echo "Error: Service name cannot be empty"
  exit 1
fi

read -p "What is the display name for your radio station? (e.g., SidTheTech Radio): " RADIO_DISPLAY_NAME
if [ -z "$RADIO_DISPLAY_NAME" ]; then
  echo "Error: Display name cannot be empty"
  exit 1
fi

read -p "What is the endpoint/domain for your stream? (e.g., live.sidthetech.com): " ENDPOINT
if [ -z "$ENDPOINT" ]; then
  echo "Error: Endpoint cannot be empty"
  exit 1
fi

# Define paths (relative to INSTALL_DIR)
MUSIC_DIR="$INSTALL_DIR/music/beta"
WWW_DIR="/var/www/$ENDPOINT"
HLS_DIR="$WWW_DIR/hls"
STREAM_URL="https://$ENDPOINT/hls/stream.m3u8"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

# Make smart.sh executable (no copy needed)
chmod +x "$INSTALL_DIR/smart.sh"

# Create music dir if needed (empty, user adds MP3s or AAC)
mkdir -p "$MUSIC_DIR"
chown -R $(whoami):$(whoami) "$MUSIC_DIR"  # Owned by current user
chmod -R 755 "$MUSIC_DIR"

# Create web dirs
mkdir -p "$HLS_DIR"
chown -R $(whoami):www-data "$WWW_DIR"  # Allow user and web server access
chmod -R 755 "$WWW_DIR"

# Customize and copy index.html
sed "s/{{RADIO_DISPLAY_NAME}}/$RADIO_DISPLAY_NAME/g; s|{{STREAM_URL}}|$STREAM_URL|g; s/{{LOGO_ALT}}/$RADIO_DISPLAY_NAME Logo/g" \
  "$SCRIPT_DIR/src/html/index.html.template" > "$WWW_DIR/index.html"
chown $(whoami):www-data "$WWW_DIR/index.html"
chmod 644 "$WWW_DIR/index.html"

# Generate service file (run as current user)
CURRENT_USER=$(whoami)
cat > "$SERVICE_FILE" << EOF
[Unit]
Description=$RADIO_DISPLAY_NAME Streamer
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=$CURRENT_USER
Group=$CURRENT_USER
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/smart.sh
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
Environment=FFMPEG_NOSTDIN=1

[Install]
WantedBy=multi-user.target
EOF

# Set service permissions
chmod 644 "$SERVICE_FILE"

# Reload, enable, start service
systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl start "$SERVICE_NAME"

# Verify
echo "Installation complete! Check status with: sudo systemctl status $SERVICE_NAME"
echo "Stream frontend: https://$ENDPOINT/"
echo "Add audio files to $MUSIC_DIR and they will be picked up on next playlist cycle."
echo "Edit logo path in $WWW_DIR/index.html if needed."