# 🎵 OffMusic

A modern Flutter music player application with automated CI/CD pipeline.

## ✨ Features

- 🎵 Local music playback
- 📱 Modern Material Design UI
- 🔍 Music library browsing
- 🎛️ Audio controls and playlists
- 📱 Responsive design for all screen sizes

## 🚀 Automated APK Building

This project includes a complete GitHub Actions CI/CD pipeline for automatic APK building:

### Quick Setup
1. **[📖 Detailed Setup Guide](GITHUB_ACTIONS_SETUP.md)** - Complete step-by-step instructions
2. **[⚡ Quick Start Guide](.github/QUICK_START.md)** - 5-minute setup for experienced users

### Available Workflows
- **🏗️ Automatic APK Building** - Builds on every push to main
- **🔍 PR Quality Checks** - Code analysis and testing on pull requests
- **🚀 Release Automation** - Creates releases with APK/AAB files on version tags
- **🔄 Dependency Updates** - Automated dependency management with Dependabot

### Download APKs
1. Go to the **Actions** tab in this repository
2. Click on the latest successful workflow run
3. Download the APK from the **Artifacts** section

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio / VS Code
- Android SDK and emulator

### Installation
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/offmusic.git
cd offmusic

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Building Locally
```bash
# Debug APK
flutter build apk --debug

# Release APK (requires keystore setup)
flutter build apk --release
```

## 📱 Permissions

The app requires the following permissions:
- `READ_MEDIA_AUDIO` - Access music files on device
- `READ_EXTERNAL_STORAGE` - Access external storage (Android < 13)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **GitHub Actions Issues**: Check the [Setup Guide](GITHUB_ACTIONS_SETUP.md#-troubleshooting)
- **App Issues**: Open an issue in this repository
- **Flutter Help**: [Flutter Documentation](https://docs.flutter.dev/)
