# Contributing

Thanks for your interest in improving the PiKaraoke Kiosk setup script!

## Reporting Issues

**For PiKaraoke software issues** (songs not playing, features, bugs):
- Go to the [official PiKaraoke repository](https://github.com/vicwomg/pikaraoke/issues)

**For setup script issues** (installation, auto-start, configuration):
- Open an issue in this repository
- Include:
  - Raspberry Pi model
  - OS version (`cat /etc/os-release`)
  - Error messages/logs
  - Steps to reproduce

## Contributing Improvements

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Make your changes
4. Test on a fresh Raspberry Pi OS installation
5. Update documentation if needed
6. Submit a pull request

## Testing

Before submitting a PR, please test on:
- Fresh Raspberry Pi OS (64-bit Desktop)
- Raspberry Pi 4 or 5 (if possible)

Test checklist:
- [ ] Script runs without errors
- [ ] PiKaraoke service starts on boot
- [ ] Browser launches in fullscreen to `/splash`
- [ ] Videos autoplay without interaction
- [ ] Auto-update script works
- [ ] Documentation is updated

## Code Style

- Use bash best practices
- Add comments for complex logic
- Keep the script as simple as possible
- Test error conditions

## Ideas for Improvements

- Support for other Linux distributions
- Optional features (VPN, remote access, etc.)
- Better error handling
- Progress indicators
- Uninstall script

## Questions?

Open an issue and we'll help!

---

Remember: This project is just a wrapper/installer for the amazing PiKaraoke software by Vic Wong.
