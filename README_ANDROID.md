Quick guide — build Android installable (Capacitor)

Overview
- This repo contains the web game. To create an Android app we use Capacitor to wrap the `www/` web assets into a native Android project.

Prerequisites (Windows)
- Node.js (16+), npm
- Java JDK 11+
- Android Studio (with Android SDK, platform-tools, and an emulator or USB debugging enabled on a device)
- Optional: `adb` in PATH (comes with Android SDK platform-tools)

Steps (run in PowerShell or cmd from project root)

1) Install dependencies

```powershell
npm install
```

2) Initialize Capacitor (only if not already initialized)

```powershell
npx cap init "WaterGuardianX" "com.yourdomain.waterguardian"
```

Note: `capacitor.config.json` is already provided; if you run `npx cap init` again, follow prompts or skip.

3) Ensure `www/index.html` exists and all `assets/` and `local_assets_map.json` are inside `www/` (we already copied a packaged `index.html` to `www/`).

4) Add Android platform

```powershell
npx cap add android
```

5) Copy web assets into native project

```powershell
npx cap copy
```

6) Open Android Studio project

```powershell
npx cap open android
```

In Android Studio:
- Let Gradle sync.
- Select a device/emulator and Run the app to test.
- For release & Play Store: Build → Generate Signed Bundle / APK → follow steps to sign with your keystore. Prefer `AAB` for Play Store.

7) Install APK on device (optional debug install)

```powershell
adb install -r android/app/build/outputs/apk/release/app-release.apk
```

Troubleshooting notes
- Audio autoplay: Mobile WebView may block autoplay. If sound doesn't start, tap once to resume `AudioContext`. Consider keeping a small "شروع" button that calls `audioContext.resume()` on first user interaction.
- 404 missing assets: check `www/` paths and `local_assets_map.json`.
- If Capacitor CLI complains about versions, run `npm install @capacitor/core @capacitor/cli` locally.

If you want, I can:
- (A) attempt to run `npm install` and `npx cap add android` here (requires Node & Android SDK installed on this machine — likely unavailable), or
- (B) continue by adding a small `pack-and-open.ps1` script to automate the local commands for you to run.

Tell me which next step you prefer.

Fallback (recommended if local Gradle can't resolve dependencies)

- Commit and push this repository to GitHub.
- On GitHub, open Actions → choose the `Android build` workflow and run it (or push to `main`).
- After the workflow finishes, download the `app-debug-apk` artifact from the workflow run — it contains `app-debug.apk`.

I added a workflow file at `.github/workflows/android-build.yml` to automate the build on GitHub Actions.