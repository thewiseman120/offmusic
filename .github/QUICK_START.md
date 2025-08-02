# ⚡ Quick Start: GitHub Actions for OffMusic

## 🚀 5-Minute Setup

### 1. Create Keystore (if needed)
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. Encode Keystore
```bash
# Linux/macOS
base64 -w0 upload-keystore.jks > keystore64.txt

# Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Out-File -Encoding ASCII keystore64.txt
```

### 3. Add GitHub Secrets
Go to: **Repository → Settings → Secrets and variables → Actions**

| Secret | Value |
|--------|-------|
| `KEYSTORE_BASE64` | Contents of `keystore64.txt` |
| `KEYSTORE_PASSWORD` | Your keystore password |
| `KEY_ALIAS` | Key alias (usually `upload`) |
| `KEY_PASSWORD` | Key password |

### 4. Push Code
```bash
git add .
git commit -m "Add GitHub Actions CI/CD"
git push origin main
```

### 5. Download APK
1. Go to **Actions** tab
2. Click latest workflow run
3. Download APK from **Artifacts** section

## 🎯 Quick Commands

### Manual Build
- Go to **Actions** → **Build Flutter Android APK** → **Run workflow**

### Create Release
```bash
git tag v1.0.0
git push origin v1.0.0
```

### Check Build Status
- **Green checkmark** = Build successful
- **Red X** = Build failed (check logs)
- **Yellow circle** = Build in progress

## 🔧 File Structure Created

```
.github/
├── workflows/
│   ├── android-ci.yml      # Main CI/CD pipeline
│   ├── pr-checks.yml       # Pull request checks
│   └── release.yml         # Release automation
├── dependabot.yml          # Dependency updates
└── QUICK_START.md          # This file

android/app/build.gradle.kts # Updated with signing config
.gitignore                  # Updated to exclude keystores
GITHUB_ACTIONS_SETUP.md     # Detailed setup guide
```

## 🚨 Important Notes

- **NEVER** commit `.jks` files or `key.properties`
- Keep keystore passwords secure
- Use strong passwords for production keystores
- Backup your keystore file safely

## 🆘 Need Help?

1. Check **Actions** logs for error details
2. Verify all 4 secrets are set correctly
3. Ensure keystore file is properly encoded
4. Review the detailed setup guide: `GITHUB_ACTIONS_SETUP.md`
