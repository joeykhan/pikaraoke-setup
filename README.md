# PiKaraoke Kiosk Setup

Automated installation script for setting up a **hands-free, plug-and-play PiKaraoke system** on Raspberry Pi.

This is a deployment/setup script for [**PiKaraoke**](https://github.com/vicwomg/pikaraoke) by [Vic Wong](https://github.com/vicwomg). All credit for the amazing PiKaraoke software goes to Vic and the contributors!

## What This Does

Transforms a Raspberry Pi into a fully automated karaoke system that:

- 🎤 **Auto-boots to fullscreen karaoke splash screen** - No user interaction needed
- 📱 **Instant mobile access** - Scan QR code to browse and queue songs from phones
- 🌐 **Auto-connects to WiFi** - Configure multiple networks, works anywhere
- 🔄 **Auto-updates weekly** - OS patches and PiKaraoke updates on Tuesdays at 3 AM
- 🖥️ **Kiosk mode** - No mouse/keyboard required, videos autoplay
- 🔊 **Hardware accelerated** - Uses Pi's hardware video encoding
- 🎯 **Zero maintenance** - Just plug it in and sing!

Perfect for sending to family/friends or deploying at events.

## Quick Start

### One-Line Install

On a **fresh Raspberry Pi OS** installation (Desktop version with auto-login enabled):

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/pikaraoke-kiosk/main/pikaraoke-setup.sh | bash
```

That's it! Reboot and you're ready to karaoke.

### Manual Install

```bash
# Download the script
wget https://raw.githubusercontent.com/YOUR_USERNAME/pikaraoke-kiosk/main/pikaraoke-setup.sh

# Run it
bash pikaraoke-setup.sh

# Reboot
sudo reboot
```

## Initial Pi Configuration

Use **Raspberry Pi Imager** to set up your SD card with these settings:

1. **OS**: Raspberry Pi OS (64-bit) - **Desktop version** (required)
2. **Enable SSH**: Yes
3. **Set username/password**: Your choice (e.g., `pikaraoke`)
4. **Configure WiFi**: Your network (for initial setup)
5. **Enable auto-login**: **Important!** Check "Enable auto-login to desktop"
6. **Hostname**: `pikaraoke` (optional, but recommended)

Flash the SD card, boot the Pi, then run the installation script.

## What Gets Installed

The script automatically installs and configures:

- ✅ **Node.js** (latest LTS) - Required for yt-dlp
- ✅ **PiKaraoke** - From the official GitHub repository
- ✅ **Systemd service** - Auto-starts PiKaraoke on boot
- ✅ **Browser kiosk launcher** - Opens Chromium fullscreen to splash screen
- ✅ **Auto-update script** - Weekly updates for OS and PiKaraoke
- ✅ **Screen blanking disabled** - Display stays on

## Adding WiFi Networks

Before deploying to another location, add their WiFi network:

### GUI Method:
1. Click WiFi icon → "Add connection"
2. Enter SSID and password
3. Enable "Connect automatically"
4. Leave BSSID blank

### Command Line:
```bash
nmcli device wifi connect "NetworkName" password "password123"
```

The Pi will automatically connect to any saved network when available.

## Usage

### On the Pi (TV/Monitor):
- Automatically displays fullscreen karaoke splash screen
- Shows QR code for mobile access
- Displays current/next songs

### From Phones/Tablets:
- Scan QR code, or
- Visit: `http://pikaraoke.local:5555`
- Browse, search, and queue songs

### Remote Management (SSH):
```bash
ssh youruser@pikaraoke.local
```

## Service Management

```bash
# Check status
systemctl status pikaraoke

# View logs
sudo journalctl -u pikaraoke -f

# Restart
sudo systemctl restart pikaraoke

# Manual update
sudo /usr/local/bin/pikaraoke-update.sh
```

## Files Created

```
/home/user/pikaraoke/                           # PiKaraoke installation
/home/user/.local/bin/pikaraoke-launch-browser.sh  # Browser launcher
/home/user/.config/autostart/pikaraoke-browser.desktop  # Autostart entry
/etc/systemd/system/pikaraoke.service           # System service
/usr/local/bin/pikaraoke-update.sh              # Auto-update script
/var/log/pikaraoke-update.log                   # Update log
```

## Deployment Checklist

Before shipping/deploying:

- [ ] Run installation script
- [ ] Test reboot - verify browser auto-launches
- [ ] Add destination WiFi network
- [ ] Test video autoplay (no interaction needed)
- [ ] Verify update schedule: `sudo crontab -l`
- [ ] Optional: Set admin password in service config

## Customization

### Change Update Schedule

```bash
sudo crontab -e

# Default: Tuesdays at 3 AM
# 0 3 * * 2 /usr/local/bin/pikaraoke-update.sh

# Examples:
# Daily:    0 3 * * * /usr/local/bin/pikaraoke-update.sh
# Sundays:  0 4 * * 0 /usr/local/bin/pikaraoke-update.sh
```

### PiKaraoke Options

Edit `/etc/systemd/system/pikaraoke.service`:

```bash
sudo nano /etc/systemd/system/pikaraoke.service

# Modify ExecStart line, e.g.:
# ExecStart=/home/user/.local/bin/pikaraoke --headless --high-quality --admin-password mypass

sudo systemctl daemon-reload
sudo systemctl restart pikaraoke
```

See `pikaraoke --help` for all options.

## Troubleshooting

### Browser doesn't launch
```bash
systemctl status pikaraoke
/home/user/.local/bin/pikaraoke-launch-browser.sh
```

### Can't access web interface
```bash
sudo netstat -tlnp | grep 5555
sudo systemctl restart pikaraoke
```

### Videos won't autoplay
- Should work automatically with the included autoplay flags
- If issues persist, click the screen once to grant permission

See [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md) for detailed troubleshooting.

## Hardware Requirements

- **Raspberry Pi 4 or 5** (Pi 4 2GB+ recommended, Pi 5 4GB+ ideal)
- **16GB+ microSD card** (32GB+ recommended)
- **HDMI display** (TV or monitor)
- **Internet connection** (WiFi or Ethernet)
- **Optional**: USB microphone, speakers (or use HDMI audio)

Raspberry Pi 3 may work with reduced performance.

## Credits

- **PiKaraoke** by [Vic Wong](https://github.com/vicwomg) - [github.com/vicwomg/pikaraoke](https://github.com/vicwomg/pikaraoke)
  - The amazing karaoke software that makes this all possible
  - Support Vic: [Buy him a coffee](https://www.buymeacoffee.com/vicwomg) ☕

- **This kiosk setup script** - Automated deployment wrapper for PiKaraoke
  - Makes it easy to set up multiple Pi systems for family/friends/events

## Contributing

Improvements welcome! Feel free to:
- Report issues
- Submit pull requests
- Share your deployment stories

## License

This setup script is provided as-is under the MIT License.

PiKaraoke itself is licensed separately - see the [PiKaraoke repository](https://github.com/vicwomg/pikaraoke) for details.

## Related Resources

- [PiKaraoke Official Docs](https://github.com/vicwomg/pikaraoke)
- [PiKaraoke Wiki](https://github.com/vicwomg/pikaraoke/wiki)
- [PiKaraoke Troubleshooting](https://github.com/vicwomg/pikaraoke/wiki/FAQ-&-Troubleshooting)
- [Raspberry Pi Documentation](https://www.raspberrypi.com/documentation/)

## Support

- **PiKaraoke Issues**: [github.com/vicwomg/pikaraoke/issues](https://github.com/vicwomg/pikaraoke/issues)
- **Setup Script Issues**: [Open an issue in this repo]

---

**Note**: This is a third-party setup/deployment script for PiKaraoke. For issues with PiKaraoke itself (songs not playing, features, etc.), please refer to the [official PiKaraoke repository](https://github.com/vicwomg/pikaraoke).

Made with 🎤 for easy karaoke deployments
