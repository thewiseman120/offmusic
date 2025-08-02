# 🧪 Testing & Validation Guide for GitHub Actions CI/CD

This guide helps you test and validate the GitHub Actions CI/CD pipeline for your OffMusic Flutter app.

## 🔍 Pre-Push Validation

Before pushing to GitHub, validate your setup locally:

### 1. Test Flutter Build Locally
```bash
# Test debug build
flutter build apk --debug

# Test release build (requires keystore)
flutter build apk --release

# Run tests
flutter test

# Analyze code
flutter analyze
```

### 2. Validate Keystore Setup
```bash
# Check if keystore file exists and is valid
keytool -list -v -keystore upload-keystore.jks

# Verify key alias
keytool -list -keystore upload-keystore.jks -alias upload
```

## 🚀 Testing GitHub Actions Workflows

### Step 1: Initial Push Test
1. **Push your code:**
   ```bash
   git add .
   git commit -m "Add GitHub Actions CI/CD pipeline"
   git push origin main
   ```

2. **Monitor the workflow:**
   - Go to **Actions** tab in your GitHub repository
   - Watch the "Build Flutter Android APK" workflow
   - Check each step for success/failure

3. **Expected behavior:**
   - ✅ Checkout repository
   - ✅ Set up Java 17
   - ✅ Install Flutter
   - ✅ Get dependencies
   - ✅ Analyze code
   - ✅ Run tests
   - ⚠️ Skip keystore steps (no secrets yet)
   - ❌ Build may fail without keystore

### Step 2: Test with Secrets (Release Build)
1. **Add GitHub secrets** (see [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md))
2. **Trigger manual build:**
   - Go to **Actions** → **Build Flutter Android APK**
   - Click **Run workflow**
   - Select "release" build type
   - Click **Run workflow**

3. **Expected behavior:**
   - ✅ All previous steps
   - ✅ Decode keystore
   - ✅ Create key.properties
   - ✅ Build Release APK
   - ✅ Upload APK artifact

### Step 3: Test Pull Request Workflow
1. **Create a test branch:**
   ```bash
   git checkout -b test-pr
   echo "# Test change" >> test-file.md
   git add test-file.md
   git commit -m "Test PR workflow"
   git push origin test-pr
   ```

2. **Create Pull Request:**
   - Go to GitHub repository
   - Create PR from `test-pr` to `main`
   - Watch "PR Quality Checks" workflow

3. **Expected behavior:**
   - ✅ Code analysis
   - ✅ Format checking
   - ✅ Test execution
   - ✅ Debug APK build
   - ✅ Upload debug APK

### Step 4: Test Release Workflow
1. **Create a version tag:**
   ```bash
   git checkout main
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **Expected behavior:**
   - ✅ Release workflow triggers
   - ✅ Builds both APK and AAB
   - ✅ Creates GitHub release
   - ✅ Attaches files to release

## 🔧 Troubleshooting Common Issues

### Issue 1: "Keystore file not found"
**Symptoms:**
```
Error: Could not find upload-keystore.jks
```

**Solutions:**
1. Verify `KEYSTORE_BASE64` secret is set
2. Check base64 encoding (no line breaks)
3. Re-encode keystore file:
   ```bash
   base64 -w0 upload-keystore.jks > keystore64.txt
   ```

### Issue 2: "Wrong password for keystore"
**Symptoms:**
```
Error: keystore password was incorrect
```

**Solutions:**
1. Verify `KEYSTORE_PASSWORD` secret
2. Check `KEY_PASSWORD` secret
3. Confirm `KEY_ALIAS` matches keystore
4. Test locally:
   ```bash
   keytool -list -keystore upload-keystore.jks -alias YOUR_ALIAS
   ```

### Issue 3: "Java version mismatch"
**Symptoms:**
```
Error: Unsupported Java version
```

**Solutions:**
1. Workflow uses Java 17 (correct)
2. Update local environment if needed
3. Check Flutter compatibility

### Issue 4: "Flutter analyze failed"
**Symptoms:**
```
Error: Analysis failed with errors
```

**Solutions:**
1. Run locally: `flutter analyze`
2. Fix code issues
3. Update `analysis_options.yaml` if needed

### Issue 5: "Tests failed"
**Symptoms:**
```
Error: Some tests failed
```

**Solutions:**
1. Run locally: `flutter test`
2. Fix failing tests
3. Update test files

## 📊 Monitoring Workflow Health

### Key Metrics to Watch:
- **Build Success Rate**: Should be >95%
- **Build Duration**: Typically 5-10 minutes
- **Artifact Size**: Monitor APK size growth
- **Test Coverage**: Maintain good coverage

### Regular Maintenance:
1. **Weekly**: Check Dependabot PRs
2. **Monthly**: Review workflow performance
3. **Quarterly**: Update secrets if needed

## 🎯 Validation Checklist

### ✅ Basic Functionality
- [ ] Code pushes trigger builds
- [ ] Pull requests run quality checks
- [ ] Manual workflows can be triggered
- [ ] Artifacts are uploaded successfully

### ✅ Security
- [ ] No secrets in logs
- [ ] Keystore files not committed
- [ ] Proper secret management
- [ ] Signed APKs for release

### ✅ Quality
- [ ] Code analysis passes
- [ ] Tests execute successfully
- [ ] Formatting is enforced
- [ ] Coverage reports generated

### ✅ Artifacts
- [ ] APK files are generated
- [ ] Correct file sizes
- [ ] Proper naming convention
- [ ] Retention policies work

## 🚨 Emergency Procedures

### If Secrets Are Compromised:
1. **Immediately revoke** GitHub secrets
2. **Generate new keystore** for future releases
3. **Update secrets** with new values
4. **Review access logs**

### If Builds Are Failing:
1. **Check workflow logs** for specific errors
2. **Test locally** to isolate issues
3. **Rollback changes** if necessary
4. **Update dependencies** if outdated

### If APKs Are Corrupted:
1. **Verify keystore integrity**
2. **Check build environment**
3. **Test on multiple devices**
4. **Compare with local builds**

## 📈 Performance Optimization

### Speed Up Builds:
- Use Flutter action caching (already enabled)
- Cache Gradle dependencies
- Optimize test execution
- Parallel job execution

### Reduce Costs:
- Limit concurrent workflows
- Optimize artifact retention
- Use efficient runners
- Monitor usage metrics

## 🎉 Success Indicators

Your CI/CD pipeline is working correctly when:
- ✅ Builds complete in <10 minutes
- ✅ APKs install and run on devices
- ✅ No security warnings in logs
- ✅ Consistent build results
- ✅ Automated releases work smoothly

## 📞 Getting Help

If you encounter issues not covered here:
1. Check the [detailed setup guide](GITHUB_ACTIONS_SETUP.md)
2. Review GitHub Actions documentation
3. Check Flutter CI/CD best practices
4. Open an issue in the repository
