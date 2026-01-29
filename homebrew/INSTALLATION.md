# Installation Instructions

## Quick Start

### Install via Homebrew (Recommended)

```bash
# Add the tap
brew tap USERNAME/terminal-hangul

# Install terminalHangul
brew install --cask terminal-hangul
```

### Manual Installation

1. Download the latest release from [GitHub Releases](https://github.com/USERNAME/terminal-hangul/releases)
2. Unzip the downloaded file
3. Move `terminalHangul.app` to your Applications folder
4. Launch the app

## First Launch

After installation:

1. **Launch the app** from your Applications folder or Spotlight
2. **Grant Accessibility permissions** when prompted:
   - System Settings → Privacy & Security → Accessibility
   - Enable terminalHangul
3. **The app icon will appear in your menu bar**

## System Requirements

- macOS 12.0 (Monterey) or later
- Accessibility permissions

## Updating

### Via Homebrew

```bash
brew update
brew upgrade --cask terminal-hangul
```

### Manual Update

1. Download the latest version
2. Replace the existing app in Applications folder
3. Relaunch the app

## Uninstallation

### Via Homebrew (Complete Removal)

```bash
# Remove app and all settings
brew uninstall --zap --cask terminal-hangul

# Remove the tap (optional)
brew untap USERNAME/terminal-hangul
```

### Manual Uninstallation

1. **Remove the app:**
   ```bash
   rm -rf /Applications/terminalHangul.app
   ```

2. **Remove preferences and caches:**
   ```bash
   rm -rf ~/Library/Application\ Support/terminalHangul
   rm -rf ~/Library/Caches/com.yourcompany.terminalHangul
   rm ~/Library/Preferences/com.yourcompany.terminalHangul.plist
   ```

3. **Revoke Accessibility permissions:**
   - System Settings → Privacy & Security → Accessibility
   - Remove terminalHangul from the list

## Troubleshooting

### "App is damaged and can't be opened"

This may occur if the app isn't properly signed. Try:

```bash
xattr -cr /Applications/terminalHangul.app
```

Then launch the app again.

### App doesn't appear in menu bar

1. Check if the app is running: `ps aux | grep terminalHangul`
2. Quit and relaunch the app
3. Check console logs: Console.app → search for "terminalHangul"

### Accessibility permissions not working

1. Remove the app from Accessibility list
2. Quit the app completely
3. Relaunch and grant permissions again

### Homebrew installation fails

```bash
# Update Homebrew
brew update

# Repair taps
brew tap --repair

# Try again
brew install --cask terminal-hangul --verbose
```

## Support

For issues and support:
- [GitHub Issues](https://github.com/USERNAME/terminal-hangul/issues)
- [Documentation](https://github.com/USERNAME/terminal-hangul#readme)
