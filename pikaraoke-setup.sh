#!/bin/bash
# PiKaraoke Kiosk Installation Script
#
# This script installs and configures PiKaraoke (https://github.com/vicwomg/pikaraoke)
# by Vic Wong as a fully automated, hands-free karaoke kiosk system.
#
# PiKaraoke credit: Vic Wong (https://github.com/vicwomg)
# Support PiKaraoke: https://www.buymeacoffee.com/vicwomg
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/joeykhan/pikaraoke-setup/main/pikaraoke-setup.sh | bash
#   or: bash pikaraoke-setup.sh
#
# What this does:
# - Installs Node.js, PiKaraoke, and dependencies
# - Creates systemd service for auto-start
# - Configures browser to launch in fullscreen kiosk mode
# - Sets up weekly auto-updates (Tuesdays at 3 AM)
# - Disables screen blanking
# - Configures autoplay for videos

set -e  # Exit on error

echo "=========================================="
echo "PiKaraoke Kiosk Setup Script"
echo "=========================================="
echo ""
echo "Installing PiKaraoke by Vic Wong"
echo "https://github.com/vicwomg/pikaraoke"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
   echo "ERROR: Please run as normal user (not root/sudo)"
   echo "Usage: bash pikaraoke-setup.sh"
   exit 1
fi

USERNAME=$(whoami)
HOMEDIR=$HOME

echo "Installing for user: $USERNAME"
echo "Home directory: $HOMEDIR"
echo ""

# Update system
echo "Step 1/8: Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Install Node.js (for yt-dlp)
echo ""
echo "Step 2/8: Installing Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
else
    echo "Node.js already installed"
fi
node --version

# Install dependencies
echo ""
echo "Step 3/8: Installing dependencies..."
sudo apt install -y python3-pip git vlc chromium stress-ng

# Clone and install PiKaraoke
echo ""
echo "Step 4/8: Installing PiKaraoke..."
if [ ! -d "$HOMEDIR/pikaraoke" ]; then
    cd "$HOMEDIR"
    git clone https://github.com/vicwomg/pikaraoke.git
fi
cd "$HOMEDIR/pikaraoke"
pip3 install --break-system-packages -e .

# Create systemd service
echo ""
echo "Step 5/8: Creating PiKaraoke systemd service..."
sudo tee /etc/systemd/system/pikaraoke.service > /dev/null <<EOF
[Unit]
Description=PiKaraoke
After=network-online.target sound.target
Wants=network-online.target

[Service]
Type=simple
User=$USERNAME
WorkingDirectory=$HOMEDIR/pikaraoke
ExecStart=$HOMEDIR/.local/bin/pikaraoke --headless --high-quality
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable pikaraoke
sudo systemctl start pikaraoke

# Create browser launch script
echo ""
echo "Step 6/8: Creating browser launch script..."
mkdir -p "$HOMEDIR/.local/bin"
tee "$HOMEDIR/.local/bin/pikaraoke-launch-browser.sh" > /dev/null <<'EOF'
#!/bin/bash
# Wait for network connectivity (max 60 seconds)
echo "Waiting for network connection..."
for i in {1..60}; do
    if nmcli -t -f STATE general | grep -q "connected"; then
        echo "Network connected!"
        break
    fi
    sleep 1
done

# Additional wait for PiKaraoke service to start
sleep 5

# Wait for the PiKaraoke service to be fully up (max 30 seconds)
echo "Waiting for PiKaraoke service..."
for i in {1..30}; do
    if curl -s http://localhost:5555 > /dev/null; then
        echo "PiKaraoke ready!"
        break
    fi
    sleep 1
done

# Disable screen blanking and screensaver
xset s off
xset -dpms
xset s noblank

# Launch Chromium in kiosk mode - use /splash for desktop/TV display
# --password-store=basic disables keyring to avoid password prompts
# --autoplay-policy=no-user-gesture-required allows videos to autoplay without interaction
chromium --kiosk --noerrdialogs --disable-infobars --disable-session-crashed-bubble --no-first-run --disable-features=TranslateUI --password-store=basic --autoplay-policy=no-user-gesture-required http://localhost:5555/splash
EOF

chmod +x "$HOMEDIR/.local/bin/pikaraoke-launch-browser.sh"

# Create autostart entry
echo ""
echo "Step 7/8: Creating autostart entry..."
mkdir -p "$HOMEDIR/.config/autostart"
tee "$HOMEDIR/.config/autostart/pikaraoke-browser.desktop" > /dev/null <<EOF
[Desktop Entry]
Type=Application
Name=PiKaraoke Browser
Comment=Launch PiKaraoke in fullscreen browser
Exec=$HOMEDIR/.local/bin/pikaraoke-launch-browser.sh
Terminal=false
Hidden=false
X-GNOME-Autostart-enabled=true
EOF

# Create auto-update script
echo ""
echo "Step 8/8: Setting up auto-updates..."
sudo tee /usr/local/bin/pikaraoke-update.sh > /dev/null <<EOF
#!/bin/bash
# PiKaraoke Auto-Update Script

LOG_FILE="/var/log/pikaraoke-update.log"
exec 1>> "\$LOG_FILE" 2>&1

echo "=== Update started at \$(date) ==="

# Update OS
echo "Updating OS packages..."
apt update
apt upgrade -y
apt autoremove -y
apt autoclean

# Update PiKaraoke
echo "Updating PiKaraoke..."
cd $HOMEDIR/pikaraoke || exit 1

# Stash any local changes
sudo -u $USERNAME git stash

# Pull latest version
sudo -u $USERNAME git pull origin master

# Update Python dependencies
sudo -u $USERNAME pip3 install --break-system-packages --upgrade -e .

# Restart service if it's running
if systemctl is-active --quiet pikaraoke; then
    echo "Restarting PiKaraoke service..."
    systemctl restart pikaraoke
fi

# Check for reboot requirement
if [ -f /var/run/reboot-required ]; then
    echo "Reboot required but not rebooting automatically. Manual reboot recommended."
fi

echo "=== Update completed at \$(date) ==="
echo ""
EOF

sudo chmod +x /usr/local/bin/pikaraoke-update.sh

# Setup cron job for Tuesday 3 AM
echo "Setting up weekly auto-update cron job (Tuesdays at 3 AM)..."
(sudo crontab -l 2>/dev/null | grep -v pikaraoke-update; echo "0 3 * * 2 /usr/local/bin/pikaraoke-update.sh") | sudo crontab -

echo ""
echo "=========================================="
echo "✅ Installation Complete!"
echo "=========================================="
echo ""
echo "What was installed:"
echo "  ✅ PiKaraoke at: $HOMEDIR/pikaraoke"
echo "  ✅ Systemd service: pikaraoke.service (enabled)"
echo "  ✅ Browser kiosk launcher (autostart enabled)"
echo "  ✅ Auto-update script (Tuesdays at 3 AM)"
echo "  ✅ Node.js $(node --version)"
echo ""
echo "Configuration:"
echo "  - PiKaraoke URL: http://localhost:5555"
echo "  - Desktop view: http://localhost:5555/splash"
echo "  - Update log: /var/log/pikaraoke-update.log"
echo ""
echo "Next steps:"
echo "  1. Reboot to test: sudo reboot"
echo "  2. Add WiFi networks as needed"
echo "  3. On boot, browser will auto-launch to PiKaraoke splash screen"
echo ""
echo "Service commands:"
echo "  - Check status: systemctl status pikaraoke"
echo "  - View logs: sudo journalctl -u pikaraoke -f"
echo "  - Restart: sudo systemctl restart pikaraoke"
echo ""
echo "Manual update:"
echo "  sudo /usr/local/bin/pikaraoke-update.sh"
echo ""
echo "Ready to karaoke! 🎤"
echo ""
