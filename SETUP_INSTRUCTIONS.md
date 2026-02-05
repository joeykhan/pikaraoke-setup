# PiKaraoke Kiosk - Easy Setup Guide

**This is a deployment/setup script for [PiKaraoke](https://github.com/vicwomg/pikaraoke) by [Vic Wong](https://github.com/vicwomg).**

All credit for the amazing PiKaraoke software goes to Vic and contributors! If you love PiKaraoke, consider [supporting Vic](https://www.buymeacoffee.com/vicwomg).

---

This setup creates a **fully automated, hands-free karaoke system** that:
- Auto-boots to karaoke splash screen in fullscreen
- Auto-connects to WiFi
- Auto-updates weekly (Tuesdays at 3 AM)
- No mouse/keyboard needed
- Videos autoplay without interaction

## Method 1: One-Line Install (Recommended)

On a **fresh Raspberry Pi OS** installation:

```bash
# Download and run the setup script
curl -fsSL https://raw.githubusercontent.com/joeykhan/pikaraoke-setup/main/pikaraoke-setup.sh | bash
```

Or download it first, then run:

```bash
wget https://raw.githubusercontent.com/joeykhan/pikaraoke-setup/main/pikaraoke-setup.sh
bash pikaraoke-setup.sh
```

## Method 2: Manual Setup

1. Copy `pikaraoke-setup.sh` to a fresh Raspberry Pi
2. Run it:
   ```bash
   bash pikaraoke-setup.sh
   ```

## Initial Raspberry Pi Setup

Before running the script, configure your Pi with Raspberry Pi Imager:

### Required Settings:
1. **OS**: Raspberry Pi OS (64-bit) - Desktop version
2. **Hostname**: `pikaraoke` (or whatever you prefer)
3. **Username/Password**: Set your username (e.g., `localadmin`)
4. **WiFi**: Configure your home WiFi (for initial setup)
5. **Enable SSH**: Yes (for remote access)
6. **Auto-login**: Enable desktop auto-login

### After First Boot:

1. **SSH into the Pi** (or use keyboard/monitor):
   ```bash
   ssh youruser@pikaraoke.local
   ```

2. **Run the setup script**:
   ```bash
   bash pikaraoke-setup.sh
   ```

3. **Reboot**:
   ```bash
   sudo reboot
   ```

4. **Add additional WiFi networks** (for deployment location):
   - GUI: Click WiFi icon → "Add connection"
   - CLI: `nmcli device wifi connect "SSID" password "PASSWORD"`

## What Gets Installed

- ✅ Node.js (latest LTS)
- ✅ PiKaraoke (from GitHub)
- ✅ VLC media player
- ✅ Chromium browser
- ✅ Systemd service (auto-start on boot)
- ✅ Browser kiosk launcher
- ✅ Auto-update script
- ✅ Cron job for weekly updates

## Files Created

```
/home/youruser/pikaraoke/                       # PiKaraoke installation
/home/youruser/.local/bin/pikaraoke-launch-browser.sh  # Browser launcher
/home/youruser/.config/autostart/pikaraoke-browser.desktop  # Autostart entry
/etc/systemd/system/pikaraoke.service           # System service
/usr/local/bin/pikaraoke-update.sh              # Update script
/var/log/pikaraoke-update.log                   # Update log
```

## Adding WiFi Networks

### Option A: GUI (Easy)
1. Click WiFi icon in system tray
2. Click "Add connection"
3. Enter SSID and password
4. Check "Connect automatically"
5. Leave BSSID blank

### Option B: Command Line
```bash
# Add a WiFi network
nmcli device wifi connect "NetworkName" password "password123"

# List saved connections
nmcli connection show

# Set a connection to auto-connect
nmcli connection modify "NetworkName" connection.autoconnect yes
```

## Accessing PiKaraoke

### On the Pi itself (TV/Monitor):
- Automatically shows splash screen in fullscreen
- Displays QR code for mobile access

### From phones/tablets (same WiFi):
- Scan QR code, or
- Visit: `http://pikaraoke.local:5555`

### From your computer (remote support):
- SSH: `ssh youruser@pikaraoke.local`
- Web: `http://pikaraoke.local:5555`

## Useful Commands

### Service Management
```bash
# Check status
systemctl status pikaraoke

# View live logs
sudo journalctl -u pikaraoke -f

# Restart service
sudo systemctl restart pikaraoke

# Stop service
sudo systemctl stop pikaraoke
```

### Manual Update
```bash
# Run update script manually
sudo /usr/local/bin/pikaraoke-update.sh

# View update log
sudo tail -f /var/log/pikaraoke-update.log
```

### WiFi Management
```bash
# Show WiFi status
nmcli device status

# List saved WiFi networks
nmcli connection show

# Connect to a saved network
nmcli connection up "NetworkName"
```

## Troubleshooting

### Browser doesn't launch
```bash
# Check if service is running
systemctl status pikaraoke

# Manually launch browser
/home/youruser/.local/bin/pikaraoke-launch-browser.sh
```

### PiKaraoke not accessible
```bash
# Check if port 5555 is listening
sudo netstat -tlnp | grep 5555

# Restart the service
sudo systemctl restart pikaraoke
```

### Videos don't autoplay
- This should be fixed by the `--autoplay-policy=no-user-gesture-required` flag
- If issues persist, click the screen once to grant permission

### Update not running
```bash
# Check cron job
sudo crontab -l

# Test update script manually
sudo /usr/local/bin/pikaraoke-update.sh
```

## Deployment Checklist

Before mailing/deploying:

- [ ] Run the setup script
- [ ] Test reboot - browser should auto-launch to splash screen
- [ ] Add destination WiFi network (SSID + password)
- [ ] Test WiFi switching (optional)
- [ ] Verify videos autoplay without interaction
- [ ] Check update schedule: `sudo crontab -l`
- [ ] Document WiFi name and password for recipient

## Customization

### Change Update Schedule
```bash
# Edit root crontab
sudo crontab -e

# Current: Tuesdays at 3 AM
# 0 3 * * 2 /usr/local/bin/pikaraoke-update.sh

# Examples:
# Daily at 3 AM:     0 3 * * * /usr/local/bin/pikaraoke-update.sh
# Sundays at 4 AM:   0 4 * * 0 /usr/local/bin/pikaraoke-update.sh
# Mondays at 2 AM:   0 2 * * 1 /usr/local/bin/pikaraoke-update.sh
```

### Change PiKaraoke Options
Edit the service file:
```bash
sudo nano /etc/systemd/system/pikaraoke.service

# Modify the ExecStart line with options from: pikaraoke --help
# Examples:
#   --port 8080                    # Change port
#   --admin-password mypass        # Set admin password
#   --download-path /path/to/songs # Set download location

sudo systemctl daemon-reload
sudo systemctl restart pikaraoke
```

## Support

**For PiKaraoke software issues** (songs not playing, features, bugs):
- PiKaraoke GitHub: https://github.com/vicwomg/pikaraoke
- PiKaraoke Issues: https://github.com/vicwomg/pikaraoke/issues
- PiKaraoke Wiki: https://github.com/vicwomg/pikaraoke/wiki

**For this setup script issues** (installation, auto-start, kiosk mode):
- Open an issue in this repository

## Credits

- **PiKaraoke** by [Vic Wong](https://github.com/vicwomg) - The incredible karaoke software
  - Repository: https://github.com/vicwomg/pikaraoke
  - Support Vic: https://www.buymeacoffee.com/vicwomg

- **This kiosk setup** - Automated deployment wrapper to make PiKaraoke easier to deploy

---

**Last Updated:** 2026-02-05
**License:** MIT
