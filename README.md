# Slow Quit Apps

<p align="center">
  <img src="BuildAssets/AppIcon.png" width="128" height="128" alt="Slow Quit Apps Icon">
</p>

<p align="center">
  <strong>Prevent accidental app quits by requiring long-press on ⌘Q</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#configuration">Configuration</a> •
  <a href="#building">Building</a> •
  <a href="#license">License</a>
</p>

<p align="center">
  <a href="README.zh-CN.md">简体中文</a> |
  <a href="README.ja.md">日本語</a> |
  <a href="README.ru.md">Русский</a>
</p>

---

## Features

- 🛡️ **Prevent Accidental Quits** - Require holding ⌘Q to quit apps
- ⏱️ **Customizable Duration** - Adjust hold time from 0.3s to 3.0s
- 📋 **App Whitelist** - Exclude specific apps that can quit immediately
- 🌐 **Multi-language Support** - English, Chinese, Japanese, Russian
- 🎨 **Native macOS Design** - Seamless integration with system UI
- 💾 **Persistent Settings** - Configuration saved to JSON file

## Requirements

- macOS 15.0 (Sequoia) or later
- Accessibility permission required

## Installation

### From DMG (Recommended)

1. Download the latest release from [Releases](../../releases)
2. Open the DMG file
3. Drag `SlowQuitApps.app` to the `Applications` folder
4. Open the app and grant Accessibility permission

### From Source

```bash
git clone https://github.com/yourusername/slow-quit-apps.git
cd slow-quit-apps
./build.sh
```

## Usage

### First-Time Setup

1. **Grant Accessibility Permission**
   - Open the app → System Settings will open automatically
   - Navigate to: **Privacy & Security → Accessibility**
   - Toggle **SlowQuitApps** to ON
   - Click **Restart App** in the settings window

2. **Configure Settings**
   - Right-click the menu bar icon → **Settings**
   - Adjust hold duration as needed
   - Add apps to whitelist if desired

### How It Works

| Action | Result |
|--------|--------|
| Press ⌘Q briefly | Nothing happens (quit cancelled) |
| Hold ⌘Q for configured duration | App quits |
| Release ⌘Q early | Quit cancelled, progress resets |
| ⌘Q on whitelisted app | Quits immediately |

## Configuration

### Settings Location

Configuration is stored at:
```
~/Library/Application Support/SlowQuitApps/config.json
```

### Available Options

| Setting | Description | Default |
|---------|-------------|---------|
| `isEnabled` | Enable/disable the feature | `true` |
| `holdDuration` | Time to hold ⌘Q (seconds) | `1.0` |
| `launchAtLogin` | Start app on login | `false` |
| `showProgressAnimation` | Show progress ring | `true` |
| `language` | UI language | `en` |
| `excludedApps` | Whitelisted apps | System defaults |

### Supported Languages

| Code | Language |
|------|----------|
| `en` | English |
| `zh-CN` | 简体中文 |
| `ja` | 日本語 |
| `ru` | Русский |

## Building

### Prerequisites

- Xcode 16.0+ or Swift 6.0+
- macOS 15.0+

### Build Commands

```bash
# Development build
swift build

# Release build with DMG
./build.sh

# Generate app icon
swift scripts/generate-icon.swift
```

### Project Structure

```
slow-quit-apps/
├── Sources/SlowQuitApps/
│   ├── App/              # Application entry point
│   ├── Core/             # Core functionality
│   │   ├── Accessibility/  # Permission management
│   │   └── QuitHandler/    # Quit progress UI
│   ├── Features/         # Feature modules
│   │   └── Settings/       # Settings window
│   ├── Models/           # Data models
│   ├── State/            # App state management
│   ├── Utils/            # Utilities
│   │   └── I18n/           # Internationalization
│   └── Resources/        # Locale files
├── Resources/            # App icon, docs
└── scripts/              # Build scripts
```

## Troubleshooting

### Accessibility Permission Resets After Rebuild

This happens with ad-hoc signing. The build script includes a self-signed certificate mechanism to prevent this. Run:

```bash
./build.sh
```

The first run will create a persistent signing certificate.

### App Not Intercepting ⌘Q

1. Check Accessibility permission is granted
2. Click **Restart App** in settings
3. Ensure the target app is not in the whitelist

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT License - See [LICENSE](LICENSE) for details.

---

<p align="center">
  Made with ❤️ for macOS
</p>
