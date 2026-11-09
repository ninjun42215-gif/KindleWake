# Building and installing the Android APK (v0.5.1)

Status: the pipeline was written and checked offline (settings, icons, signing key, simulated downloads).
**It has not been run against the real Godot / Android downloads yet**, because the sandbox that wrote it had no internet
and no Godot. Expect to paste one error back the first time; the script prints clear messages and saves logs.

## What you get
`dist/Kindlewake.apk`: a signed, release-mode installer. It asks for **no permissions at all** (the build fails if the
INTERNET permission ever appears). Package name `com.kindlewake.game`, landscape (either side), arm64 + 32-bit ARM.

## Way 1: on your Windows PC (easiest)
1. Install Python 3 from python.org (tick "Add python.exe to PATH"). Skip if you already have it.
2. Unzip `Kindlewake_Project.zip`. Double-click **`Build_APK.bat`**.
3. First run downloads about 1.3 GB (JDK, Android SDK, Godot 4.2.2 and its export templates) into `C:\Users\<you>\.kindlewake_build`
   and takes 10 to 25 minutes. Later runs take a few minutes. Nothing is installed system-wide.
4. When it says DONE, your installer is **`dist\Kindlewake.apk`**.
5. It also runs the game tests and saves the output in `dist\logs\`. Paste `dist\logs\BUILD_SUMMARY.txt`
   (and `run_tests.txt` if it says tests had problems) into the next chat. That is the first real run of the code in Godot.

Linux: `sh tools/build_apk.sh`. Offline settings check only: `python tools/build_apk.py --check`.

## Way 2: in the cloud (GitHub, no Android tools on your PC)
1. Make a free GitHub account and a new repository. Upload the unzipped project files (the folder contents, including the hidden `.github` folder).
2. Repository -> **Actions** -> **Build Android APK** -> **Run workflow**. Wait about 15 to 20 minutes.
3. Open the finished run and download **Kindlewake-APK** (a zip with `Kindlewake.apk` inside). **test-logs** holds the test output.
4. Or create a release with a tag such as `v0.5.1`: the APK is then attached to the release as a direct download you can open from your phone.

## Way 3: by hand in the Godot editor
1. Godot 4.2.x (standard), then Editor -> Manage Export Templates -> Download and Install.
2. Install JDK 17 and the Android SDK command-line tools; with `sdkmanager` install `platform-tools`, `build-tools;34.0.0`, `platforms;android-34`.
3. Editor -> Editor Settings -> Export -> Android: set the Android SDK path, the Java SDK path and a debug keystore
   (you can use `tools/keys/kindlewake-sideload.keystore`, alias `kindlewake`, password `kindlewake-sideload`).
4. Project -> Export -> preset **Android** (already in `export_presets.cfg`). Under Keystore -> Release enter the same keystore, alias and password. Click **Export Project**, untick "Export With Debug", save as `dist/Kindlewake.apk`.

## Install on the phone
1. Copy `Kindlewake.apk` to the phone (USB cable, Google Drive, Telegram "Saved Messages", or the GitHub release link).
2. Open it from the Files app. Android asks to allow "Install unknown apps" for that app: allow it once.
3. If Play Protect warns about an unknown app, choose **Install anyway** (it is your own build, not from the Play Store).
4. Open **Kindlewake**. The first battle starts on the pre-battle panel. Saves live in the app's private storage.
5. With a USB cable and USB debugging on, `python tools/build_apk.py --install` installs it for you.

Updating: build again and install over the top. Saves are kept as long as you do not uninstall first. Every build is signed with the
same key (`tools/keys/kindlewake-sideload.keystore`), which is what lets Android accept the update. Do not delete that file.

## Things to know
- The sideload key is public on purpose (like Android's debug key). **Do not use it for Google Play.** For a store release create
  a private key (`keytool -genkeypair -v -keystore release.keystore -alias mykey -keyalg RSA -keysize 2048 -validity 36500`),
  keep it safe, then set `KINDLEWAKE_KEYSTORE`, `KINDLEWAKE_KEY_ALIAS`, `KINDLEWAKE_KEY_PASS` before building.
  Play Store uploads also want an `.aab` (Gradle build) and a newer Godot; that is Milestone 10.
- Godot 4.2.2 builds are not yet "16 KB page size" ready. Almost all phones are fine. If a very new phone refuses to start the app
  with a page-size message, rebuild with a newer Godot: `python tools/build_apk.py --godot 4.5` (best effort, retest the game).
- The build excludes `tests/`, `tools/`, `docs/` and markdown from the APK and includes every `*.json` in `data/`.
- Autosave runs when the app is paused (`SaveSystem`, `NOTIFICATION_APPLICATION_PAUSED`), so switching apps is safe.

## Troubleshooting
| You see | Do this |
|---|---|
| "Could not download ..." | Check the internet/firewall and run again; finished downloads are kept. |
| "Installing the Android SDK failed" | Open `dist\logs\sdk_install.txt`; usually a network drop. Run again. |
| "Godot could not export the APK" | Paste the last 30 lines of `dist\logs\export.txt` into the chat. |
| "requests the INTERNET permission" | Do not ignore: something re-enabled it. Check `export_presets.cfg` (`permissions/internet=false`). |
| App installs but closes at once | Run it from a PC with `adb logcat -s godot` and paste the output; also paste `dist\logs\run_tests.txt`. |
| "App not installed" over an old copy | The old copy was signed with a different key. Uninstall the old one first (this deletes its saves). |

## Building from a phone only (no PC)
Put two things in a GitHub repo: `Kindlewake_Project.zip` at the root, and the workflow `.github/workflows/build-apk.yml` (a copy is in `tools/phone_build_apk.yml`). In the repo open Actions, Build Android APK, Run workflow. When it is green, open Releases and tap `Kindlewake.apk`. To update: upload the new zip with the same file name, then Run workflow again (do not use Re-run, it rebuilds the old commit). The run page now shows a "Kindlewake build report" (open the run, then Summary): build result, test problems and the last lines of the test output, so you can read or screenshot it without downloading anything. The `build-logs` artifact still holds the full files.


## Updated CI and production release workflow

For the current repository-wide process, see [`ANDROID_RELEASE_WORKFLOW.md`](ANDROID_RELEASE_WORKFLOW.md). The CI workflow creates a development/test APK artifact and an independent split source handoff on every branch push, pull request, tag push and manual run. It does not publish a production release. Production publishing is a separate manual workflow protected by the `android-production` GitHub Environment and a private keystore supplied through environment secrets. Do not use the sideload/test key for production or Google Play. The current builder exports APK only; AAB/Gradle publishing is not implemented yet. CI success is not a substitute for physical Android device testing.


### Strict verification behavior

The builder now fails closed if APK permissions cannot be inspected (`aapt2` missing/failing), if the APK signature cannot be verified (`apksigner` missing/failing), if the balance report exits unsuccessfully or reports failures, or if `project.godot` and Android export preset version names differ. Do not bypass these checks to force a release.
