# 🚀 Complete GitHub Repository Setup Commands

## ✅ Issues Fixed in Code Review

1. **✅ Fixed build.gradle.kts imports** - Added missing `java.util.Properties` and `java.io.FileInputStream`
2. **✅ Fixed workflow conditions** - Simplified conditional logic for build types
3. **✅ Updated AndroidManifest.xml** - Added proper permissions for Android 13+ compatibility
4. **✅ Verified all file structures** - All paths and configurations are correct

## 📋 Step-by-Step GitHub Setup Commands

### 1. Create GitHub Repository
Go to GitHub.com and create a new repository named `offmusic` (or your preferred name).

### 2. Add GitHub Remote and Push Code
```bash
# Add your GitHub repository as origin
git remote add origin https://github.com/YOUR_USERNAME/offmusic.git

# Verify remote is added
git remote -v

# Add all files to git
git add .

# Commit with descriptive message
git commit -m "Initial commit: Flutter music app with GitHub Actions CI/CD"

# Push to GitHub (this will trigger the first workflow)
git push -u origin main
```

### 3. Set Up GitHub Secrets (REQUIRED for Release Builds)

Go to your repository on GitHub:
**Settings → Secrets and variables → Actions → New repository secret**

#### Create Android Keystore (if you don't have one):
```bash
# Generate keystore file
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Encode keystore to base64 (Linux/macOS)
base64 -w0 upload-keystore.jks > keystore64.txt

# Encode keystore to base64 (Windows PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Out-File -Encoding ASCII keystore64.txt
```

#### Add These 4 Secrets:
| Secret Name | Value | Example |
|-------------|-------|---------|
| `KEYSTORE_BASE64` | Contents of `keystore64.txt` | `MIIKXgIBAzCCCh...` |
| `KEYSTORE_PASSWORD` | Your keystore password | `myKeystorePassword123` |
| `KEY_ALIAS` | Key alias name | `upload` |
| `KEY_PASSWORD` | Key password | `myKeyPassword123` |

### 4. Trigger Your First Build

#### Option A: Automatic (Push-triggered)
The workflow will automatically run when you push to main branch.

#### Option B: Manual Trigger
1. Go to **Actions** tab in your repository
2. Click **Build Flutter Android APK**
3. Click **Run workflow**
4. Select build type (release/debug)
5. Click **Run workflow**

### 5. Download Your APK
1. Go to **Actions** tab
2. Click on the latest workflow run
3. Scroll down to **Artifacts** section
4. Download the APK file

## 🔧 Available Workflows

### Main CI/CD Pipeline
- **File**: `.github/workflows/android-ci.yml`
- **Triggers**: Push to main/master/develop, PRs, manual
- **Builds**: Release APK (with secrets) or Debug APK
- **Artifacts**: APK files with 30-day retention

### PR Quality Checks
- **File**: `.github/workflows/pr-checks.yml`
- **Triggers**: Pull requests
- **Features**: Code analysis, tests, debug build
- **Artifacts**: Debug APK for testing

### Release Automation
- **File**: `.github/workflows/release.yml`
- **Triggers**: Git tags (v1.0.0, v2.1.0, etc.)
- **Features**: Creates GitHub releases with APK and AAB files

## 🎯 Testing Commands

### Test Locally Before Pushing:
```bash
# Get dependencies
flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test

# Build debug APK (should work without keystore)
flutter build apk --debug

# Build release APK (requires keystore setup)
flutter build apk --release
```

### Create a Release:
```bash
# Tag a version
git tag v1.0.0

# Push the tag
git push origin v1.0.0
```

## 🚨 Troubleshooting

### If Build Fails:
1. Check **Actions** tab for detailed logs
2. Verify all 4 secrets are set correctly
3. Ensure keystore file is properly base64 encoded
4. Check that no line breaks exist in base64 string

### Common Issues:
- **"Keystore not found"** → Check `KEYSTORE_BASE64` secret
- **"Wrong password"** → Verify `KEYSTORE_PASSWORD` and `KEY_PASSWORD`
- **"Key alias not found"** → Check `KEY_ALIAS` matches your keystore

## ✅ Success Indicators

Your setup is working when:
- ✅ Push to main triggers automatic build
- ✅ APK artifacts are generated and downloadable
- ✅ No errors in workflow logs
- ✅ APK installs and runs on Android device

## 📱 Next Steps

1. **Test the APK** on a real Android device
2. **Set up branch protection** rules (optional)
3. **Configure notifications** for build failures
4. **Add more tests** to improve code coverage
5. **Customize app icon** and branding

## 🎉 You're Done!

Once you complete these steps, your Flutter app will automatically build APKs on every push to GitHub, making distribution and testing much easier!
