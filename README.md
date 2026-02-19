# Slow Quit Apps

<p align="center">
  <img src="BuildAssets/AppIcon.png" width="128" height="128" alt="Slow Quit Apps Icon">
</p>

<p align="center">
  <strong>Prevent accidental quits and window closes by requiring long-press on ⌘Q / ⌘W</strong>
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

- 🛡️ **Prevent Accidental Quits** — Hold ⌘Q to quit; a brief tap does nothing
- 🪟 **Prevent Accidental Window Closes** — Hold ⌘W to close a window; a brief tap does nothing
- ⏱️ **Customizable Duration** — Adjust hold time from 0.3 s to 3.0 s
- 📋 **App Exclusion List** — Exempt specific apps so they quit/close immediately
- 🌐 **Multi-language** — English, Chinese (Simplified), Japanese, Russian
- 🎨 **Native macOS Design** — Progress ring overlay blends with the system UI
- 💾 **Persistent Settings** — Configuration saved to JSON

## Requirements

- macOS 14.0 (Sonoma) or later
- Accessibility permission

## Installation

### From DMG (Recommended)

1. Download the latest release from [Releases](../../releases)
2. Open the DMG file
3. Drag `SlowQuitApps.app` to the `Applications` folder
4. Open the app and grant Accessibility permission when prompted

### From Source

```bash
git clone https://github.com/030201xz/slow-quit-apps.git
cd slow-quit-apps
./build.sh
```

## Usage

### First-Time Setup

1. **Grant Accessibility Permission**
   - Open the app — System Settings opens automatically
   - Go to: **Privacy & Security → Accessibility**
   - Toggle **SlowQuitApps** to ON
   - Click **Restart App** in the settings window

2. **Configure in the menu bar**
   - Click the menu bar icon
   - **Enable ⌘Q** / **Disable ⌘Q** — toggles long-press-to-quit
   - **Enable ⌘W** / **Disable ⌘W** — toggles long-press-to-close-window
   - **Settings…** — adjust hold duration, exclusion list, language

### How It Works

| Action | Result |
|--------|--------|
| Tap ⌘Q briefly | Nothing (quit cancelled) |
| Hold ⌘Q for the set duration | App quits |
| Release ⌘Q early | Quit cancelled, ring resets |
| ⌘Q on an excluded app | Quits immediately |
| Tap ⌘W briefly | Nothing (close cancelled) |
| Hold ⌘W for the set duration | Window closes |
| Release ⌘W early | Close cancelled, ring resets |
| ⌘W on an excluded app | Closes immediately |

## Configuration

### Settings File Location

```
~/Library/Application Support/SlowQuitApps/config.json
```

### Available Options

| Key | Description | Default |
|-----|-------------|---------|
| `quitOnLongPress` | Enable long-press for ⌘Q | `true` |
| `closeWindowOnLongPress` | Enable long-press for ⌘W | `true` |
| `holdDuration` | Hold time in seconds | `1.0` |
| `launchAtLogin` | Start at login | `false` |
| `showProgressAnimation` | Show progress ring | `true` |
| `language` | UI language | `en` |
| `excludedApps` | Apps exempt from interception | Finder, Terminal |

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
- macOS 14.0+

### Build Commands

```bash
# Development build
swift build

# Release .app bundle (ad-hoc signed)
./build.sh
```

### Project Structure

```
slow-quit-apps/
├── Sources/SlowQuitApps/
│   ├── App/              # Application entry point & menu bar
│   ├── Core/
│   │   ├── Accessibility/  # CGEvent tap, permission management
│   │   └── QuitHandler/    # Progress ring UI & controller
│   ├── Features/
│   │   └── Settings/       # Settings window (General, App List, About)
│   ├── Models/           # ManagedApp model
│   ├── State/            # AppState (observable, persisted)
│   ├── Utils/            # Config, LaunchAtLogin, I18n
│   └── Resources/        # Locale JSON files
└── BuildAssets/          # App icon, DMG docs
```

## Troubleshooting

### Accessibility Permission Resets After Rebuild

Ad-hoc signed apps lose their accessibility trust when the binary changes. After every rebuild, go to **System Settings → Privacy & Security → Accessibility**, remove SlowQuitApps, then add it back and restart the app.

### App Not Intercepting ⌘Q or ⌘W

1. Confirm Accessibility permission is granted
2. Click **Restart App** in settings
3. Make sure the target app is not in the exclusion list
4. Check that the corresponding toggle (⌘Q or ⌘W) is enabled in the menu bar

## Contributing

Contributions are welcome. Please open an issue or pull request.

## License

MIT License — see [LICENSE](LICENSE) for details.

---

<p align="center">
  Made with ❤️ for macOS
</p>
