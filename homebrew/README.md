# Homebrew Distribution Guide

## Overview

terminalHangul can be distributed via Homebrew using a custom tap. This allows users to easily install and update the application using the `brew` command.

## Structure

```
homebrew/
├── Casks/
│   └── terminal-hangul.rb    # Cask formula for the app
└── README.md                  # This file
```

## Setting Up Your Own Tap

### 1. Create a Tap Repository

Create a new GitHub repository with the naming convention:
```
homebrew-terminal-hangul
```

This creates a tap at: `USERNAME/terminal-hangul`

### 2. Repository Structure

Your tap repository should have this structure:
```
homebrew-terminal-hangul/
└── Casks/
    └── terminal-hangul.rb
```

### 3. Copy the Formula

Copy the formula from this project:
```bash
cp homebrew/Casks/terminal-hangul.rb /path/to/homebrew-terminal-hangul/Casks/
```

### 4. Update Placeholders

In `terminal-hangul.rb`, replace:
- `USERNAME` with your GitHub username
- `com.yourcompany.terminalHangul` with your actual bundle identifier

### 5. Prepare Release Assets

For each release, you need to provide a `.zip` file containing the app:

```bash
# Create a zip of your app
cd /path/to/your/build/output
zip -r terminalHangul.app.zip terminalHangul.app

# Upload to GitHub Releases as:
# terminalHangul.app.zip
```

### 6. Update SHA256 (Optional but Recommended)

For production releases, calculate and add the SHA256 checksum:

```bash
# Calculate SHA256
shasum -a 256 terminalHangul.app.zip

# Update in the formula
sha256 "abc123..."  # Replace :no_check with actual hash
```

## Installation Instructions for Users

Add these instructions to your main README.md:

### Installation via Homebrew

```bash
# Add the tap
brew tap USERNAME/terminal-hangul

# Install the app
brew install --cask terminal-hangul
```

### Updating

```bash
# Update Homebrew
brew update

# Upgrade the app
brew upgrade --cask terminal-hangul
```

### Uninstalling

```bash
# Uninstall and remove all data
brew uninstall --zap --cask terminal-hangul

# Remove the tap (optional)
brew untap USERNAME/terminal-hangul
```

## Testing Your Formula Locally

Before publishing, test your formula:

```bash
# Install from local formula
brew install --cask homebrew/Casks/terminal-hangul.rb

# Or test with a local tap
brew tap USERNAME/terminal-hangul /path/to/homebrew-terminal-hangul
brew install --cask terminal-hangul

# Audit the formula
brew audit --cask terminal-hangul

# Test installation
brew install --cask terminal-hangul --verbose

# Test uninstallation
brew uninstall --cask terminal-hangul
```

## Submitting to Official Homebrew Cask (Optional)

If you want to submit to the official Homebrew Cask repository:

1. Fork [homebrew/homebrew-cask](https://github.com/Homebrew/homebrew-cask)
2. Add your formula to `Casks/t/terminal-hangul.rb`
3. Ensure it passes all audits: `brew audit --cask --strict terminal-hangul`
4. Submit a pull request

Requirements for official submission:
- Stable, versioned release
- Valid SHA256 checksum
- Public GitHub releases
- Proper app notarization and signing

## Formula Anatomy

### Key Components

```ruby
cask "terminal-hangul" do
  version "1.0.0"                    # App version
  sha256 :no_check                   # Checksum (use actual hash for production)

  url "https://..."                  # Download URL
  name "terminalHangul"              # App name
  desc "..."                         # Short description
  homepage "https://..."             # Project homepage

  livecheck do                       # Auto-update checking
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :monterey"   # macOS version requirement

  app "terminalHangul.app"           # Install the app

  postflight do                      # Post-installation script
    # Optional setup commands
  end

  zap trash: [...]                   # Files to remove with --zap

  caveats <<~EOS                     # Installation notes
    Additional instructions...
  EOS
end
```

## Version Management

When releasing a new version:

1. Update `version` in the formula
2. Build and zip the new app version
3. Upload to GitHub Releases with matching version tag
4. Update SHA256 if used
5. Commit and push to your tap repository

Users will automatically see the update when they run `brew update`.

## Troubleshooting

### Common Issues

**Formula not found:**
```bash
brew update
brew tap --repair
```

**Download fails:**
- Ensure the release asset exists on GitHub
- Check URL format matches: `v#{version}` in tag name

**Installation fails:**
- Verify app structure is correct (must be `terminalHangul.app/`)
- Check macOS version compatibility

**Permissions issues:**
- App must be properly signed and notarized for Gatekeeper
- Users may need to grant Accessibility permissions manually

## Resources

- [Homebrew Cask Documentation](https://docs.brew.sh/Cask-Cookbook)
- [Cask Formula Reference](https://docs.brew.sh/Cask-Cookbook#stanza-reference)
- [Creating a Tap](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)

## Example Installation Flow

```bash
# User adds your tap
$ brew tap myusername/terminal-hangul
==> Tapping myusername/terminal-hangul
Cloning into '/usr/local/Homebrew/Library/Taps/myusername/homebrew-terminal-hangul'...
Tapped 1 cask (12 files, 24KB).

# User installs the app
$ brew install --cask terminal-hangul
==> Downloading https://github.com/myusername/terminal-hangul/releases/download/v1.0.0/terminalHangul.app.zip
==> Installing Cask terminal-hangul
==> Moving App 'terminalHangul.app' to '/Applications/terminalHangul.app'
🍺  terminal-hangul was successfully installed!
```
