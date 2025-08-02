# 🚀 GitHub Actions CI/CD Setup for OffMusic Flutter App

This guide provides step-by-step instructions to set up automated Android APK building using GitHub Actions.

## 📋 Prerequisites

- GitHub repository for your Flutter project
- Android keystore file for signing release APKs
- Basic knowledge of GitHub repository settings

## 🔐 Step 1: Create Android Keystore (If you don't have one)

If you don't have a keystore file, create one:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Important:** Keep your keystore file and passwords secure! You'll need them for the GitHub secrets.

## 🔑 Step 2: Set Up GitHub Repository Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions → New repository secret

Add these **4 required secrets**:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `KEYSTORE_BASE64` | Base64-encoded keystore file | (see encoding steps below) |
| `KEYSTORE_PASSWORD` | Password for the keystore file | `your_keystore_password` |
| `KEY_ALIAS` | Alias name used when creating keystore | `upload` |
| `KEY_PASSWORD` | Password for the specific key alias | `your_key_password` |

### 🔧 Encoding Your Keystore File

**On Linux/macOS:**
```bash
base64 -w0 upload-keystore.jks > keystore64.txt
```

**On Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Out-File -Encoding ASCII keystore64.txt
```

Copy the contents of `keystore64.txt` and paste it as the value for `KEYSTORE_BASE64` secret.

## 📁 Step 3: Push Your Code to GitHub

1. **Initialize Git (if not already done):**
   ```bash
   git init
   git add .
   git commit -m "Initial Flutter commit with GitHub Actions"
   ```

2. **Add GitHub remote and push:**
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
   git branch -M main
   git push -u origin main
   ```

## 🎯 Step 4: Trigger Your First Build

### Automatic Triggers:
- **Push to main/master/develop:** Automatically builds APK
- **Pull Request:** Runs quality checks and builds debug APK
- **Git Tags (v*):** Creates release with APK and AAB files

### Manual Trigger:
1. Go to your repository on GitHub
2. Click **Actions** tab
3. Select **Build Flutter Android APK** workflow
4. Click **Run workflow**
5. Choose build type (release/debug)
6. Click **Run workflow**

## 📥 Step 5: Download Your APK

1. Go to **Actions** tab in your repository
2. Click on the latest workflow run
3. Scroll down to **Artifacts** section
4. Download the APK file (e.g., `offmusic-release-apk-123`)
5. Extract the ZIP file to get your APK

## 🔄 Available Workflows

### 1. **Main CI/CD Pipeline** (`.github/workflows/android-ci.yml`)
- Builds release/debug APKs
- Runs tests and code analysis
- Uploads artifacts for download
- Supports manual triggers with build type selection

### 2. **PR Quality Checks** (`.github/workflows/pr-checks.yml`)
- Runs on pull requests
- Code formatting checks
- Test coverage analysis
- Debug APK build verification

### 3. **Release Pipeline** (`.github/workflows/release.yml`)
- Triggered by version tags (v1.0.0, v2.1.0, etc.)
- Creates GitHub releases
- Builds both APK and AAB files
- Automatically generates release notes

## 🛠️ Customization Options

### Change App ID
Update `applicationId` in `android/app/build.gradle.kts`:
```kotlin
applicationId = "com.yourcompany.offmusic"
```

### Add Build Flavors
Modify the workflow to support different flavors:
```yaml
- name: 🏗️ Build Production APK
  run: flutter build apk --release --flavor production -t lib/main_production.dart
```

### Environment-Specific Builds
Add environment variables to the workflow:
```yaml
env:
  ENVIRONMENT: production
  API_URL: https://api.yourapp.com
```

## 🚨 Security Best Practices

✅ **DO:**
- Use GitHub secrets for sensitive data
- Keep keystore files secure and backed up
- Use strong passwords for keystores
- Regularly rotate signing keys for production apps

❌ **DON'T:**
- Commit keystore files to version control
- Share keystore passwords in plain text
- Use debug signing for production releases
- Store secrets in code or configuration files

## 🔍 Troubleshooting

### Common Issues:

**1. "Keystore file not found"**
- Verify `KEYSTORE_BASE64` secret is correctly encoded
- Ensure no line breaks in the base64 string

**2. "Wrong password for keystore"**
- Double-check `KEYSTORE_PASSWORD` and `KEY_PASSWORD` secrets
- Verify the key alias matches `KEY_ALIAS` secret

**3. "Java version mismatch"**
- The workflow uses Java 17 (compatible with latest Flutter)
- Update local development environment if needed

**4. "Build failed with Gradle error"**
- Check the Actions logs for specific error messages
- Ensure all dependencies are compatible

### Getting Help:
- Check the **Actions** tab for detailed build logs
- Review error messages in the workflow output
- Ensure all secrets are properly configured

## 📊 Monitoring and Maintenance

- **Dependabot** is configured to automatically update dependencies
- **Weekly dependency updates** for Flutter packages and GitHub Actions
- **Artifact retention:** Release APKs (30 days), Debug APKs (7 days), PR APKs (3 days)

## 🎉 Success!

Once set up, your Flutter app will automatically build APKs on every push, ensuring you always have the latest version ready for testing or distribution!
