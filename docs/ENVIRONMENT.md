# ENVIRONMENT.md

The development environment for this project, as installed on this machine and
checked on 2026-09-24. This machine is the source of truth: `CLAUDE.md` is
written against it.

Nothing here needs installing. Each step records what is installed and gives a
command to confirm it still works. If any of it changes (a Flutter upgrade, a
new emulator), update all three docs.

---

## Summary

| Component | Installed | Location |
|---|---|---|
| OS | Windows 11 Pro 25H2 (build 26200), locale en-MY | |
| Git for Windows | 2.53.0 | on PATH |
| Flutter SDK | 3.32.0 (Dart 3.8.0, DevTools 2.45.1) | `C:\dev\flutter` |
| JDK used by Flutter | Microsoft OpenJDK 21.0.12 | `C:\Program Files\Microsoft\jdk-21.0.12.101-hotspot` |
| Android Studio | 2026.1.4 | `C:\Program Files\Android\Android Studio` |
| Android SDK | see Step 4 | `C:\Users\jiuny\AppData\Local\Android\Sdk` |
| Emulator | AVD `Pixel_9` (Android 17, API 37) | `C:\Users\jiuny\.android\avd\Pixel_9.avd` |
| Hypervisor | Windows Hypervisor Platform (WHPX) | |
| Editor | Trae, Dart + Flutter extensions 3.142.0 | |
| Project folder | `C:\repos\Jack\expenses-tracker` | `CLAUDE.md` at the root, spec in `docs\` |

---

## Step 1 — Git for Windows

Flutter shells out to `git`.

**Verify:**

```powershell
git --version
```

Expect `git version 2.53.0.windows.2`.

---

## Step 2 — Flutter SDK

Flutter **3.32.0** (framework revision `be698c48a6`, 2025-05-19) with Dart 3.8.0,
at `C:\dev\flutter`. `C:\dev\flutter\bin` is on the user PATH.

The SDK sits on a local branch with no official upstream remote, so Flutter
reports its channel as `[user-branch]`. That is expected. **Do not run
`flutter channel` or `flutter upgrade`.** The project is pinned to 3.32.0.

**Verify:**

```powershell
flutter --version
```

Expect `Flutter 3.32.0 • channel [user-branch]` and `Dart 3.8.0`.

---

## Step 3 — JDK

Gradle builds use Microsoft OpenJDK 21.0.12. It is set as `JAVA_HOME` and in the
Flutter config (`flutter config --jdk-dir`). Android Studio bundles its own JDK
(version 25); Flutter builds do not use it.

**Verify:** in `flutter doctor -v`, the Android toolchain section shows
`Java version OpenJDK Runtime Environment Microsoft-... (build 21.0.12...)`.

---

## Step 4 — Android Studio and SDK

Android Studio 2026.1.4 provides the SDK and the emulator. Code is written in
Trae, not in Android Studio.

Installed SDK components (`C:\Users\jiuny\AppData\Local\Android\Sdk`):

| Component | Versions |
|---|---|
| SDK Platforms | android-33, 34, 35, 36, 37.0 |
| Build-Tools | 34.0.0, 36.0.0, 37.0.0 |
| NDK (Side by side) | 26.3.11579264, 27.0.12077973 |
| CMake | 3.22.1 |
| Command-line Tools | latest |
| Platform-Tools, Emulator | installed |

**Verify:**

```powershell
flutter doctor -v
```

The Android toolchain section should show `Android SDK at ...\Android\sdk` and
`Platform android-37.0, build-tools 37.0.0`.

---

## Step 5 — Android licences

`flutter doctor` shows `X Android license status unknown`. **This is expected and
harmless on this machine.** The installed Command-line Tools deprecate
`sdkmanager` in favour of the new `android` CLI, and `sdkmanager --licenses` now
replies "The --licenses option is no longer needed." Flutter 3.32 does not
recognise that reply, so it reports the status as unknown.

Step 9 proves the licences are not blocking builds. Only if a Gradle build fails
with a licence error, run `flutter doctor --android-licenses` and accept.

---

## Step 6 — Hardware acceleration

Windows Hypervisor Platform is enabled, so the emulator runs with hardware
acceleration.

**Verify:**

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -accel-check
```

Expect `WHPX(10.0.26200) is installed and usable.`

---

## Step 7 — Emulator

`Pixel_9` is the only AVD, and it is the test device for this project.

| Setting | Value |
|---|---|
| Device | Pixel 9 |
| System image | android-37.1 (Android 17, API 37), Google APIs + Play Store, x86_64 |
| Page size | **16 KB** (see `CLAUDE.md`, Traps) |
| RAM | 2 GB |
| Graphics | auto |
| Time zone | UTC (emulator default). The app uses device local time, so this only changes which day a late-evening test entry lands on. |
| Keyboard | A hardware keyboard is attached, so text fields show only Gboard's floating toolbar. Type with the PC keyboard; check on-screen keyboard layouts on a real phone. |

Start it:

```powershell
flutter emulators --launch Pixel_9
```

The first boot takes a minute or two. While it is booting, `flutter devices` and
`flutter doctor` report `emulator-5554 is offline`. Wait for the Android home
screen.

**Verify:**

```powershell
flutter devices
```

Expect:

```
sdk gphone16k x86 64 (mobile) • emulator-5554 • android-x64 • Android 17 (API 37) (emulator)
```

---

## Step 8 — Editor

Trae, with the Dart-Code **Dart** and **Flutter** extensions (3.142.0). Claude
Code runs as an extension inside Trae. VS Code is also installed but has no
Flutter extension and is not used for this project.

---

## Step 9 — Smoke test

Proves the whole chain (Flutter → Gradle → APK → emulator) before any real work.
Passed on 2026-09-24: the debug APK built in under a minute and the counter app
ran on `Pixel_9`.

With the emulator running:

```powershell
cd $env:TEMP
flutter create smoke_test
cd smoke_test
flutter run -d emulator-5554
```

You should get the default counter app. Press `r` for hot reload, `q` to quit.
Then delete the `smoke_test` folder.

**If this fails, stop and fix it.** Debugging toolchain problems through Claude
Code is far more painful than fixing them directly.

---

## Step 10 — Expected `flutter doctor` output

`flutter doctor` never shows all green on this machine. These lines are expected:

| Section | What it says | Why it is fine |
|---|---|---|
| Flutter | `[!]` unknown channel, unknown upstream | SDK pinned to 3.32.0 on a local branch (Step 2) |
| Android toolchain | `[!]` Android license status unknown | New Command-line Tools, older Flutter (Step 5) |
| Visual Studio | `[!]` missing C++ components | Windows desktop target only, not used |
| VS Code | `X` unable to determine version | Not the editor for this project (Step 8) |

What must pass: **Android Studio**, **Connected device** (with the emulator
running), and a working Android build (Step 9). Ignore Chrome, Edge, Xcode, and
CocoaPods. Xcode and CocoaPods can never pass on Windows.

---

## Step 11 — Project folder

The project lives at `C:\repos\Jack\expenses-tracker`. `CLAUDE.md` sits at the
root, where Claude Code loads it automatically; this file is in `docs\`.

The folder name contains a hyphen, which is not a valid Dart package name.
Always pass `--project-name expense_tracker` to `flutter create`.

---

## Step 12 — Start the build

The app was scaffolded on 2026-09-24 with:

```powershell
flutter create . --org com.jack --project-name expense_tracker --platforms android,ios
```

Only Android (development) and iOS (final target) are generated. Web and desktop
are not used.

Phases 0–6 were built and checked on `Pixel_9` on 2026-09-24. Phase 7 (iOS)
is next, when you are ready for it.

To continue in Claude Code (inside Trae), from the project folder, with
`Pixel_9` running:

```
Read CLAUDE.md, then <the change you want>.
```

---

## Optional — Speed up builds

Windows Defender real-time scanning inspects every file Flutter and Gradle touch,
which noticeably slows builds. You can exclude the two directories:

Windows Security → Virus & threat protection → Manage settings → Exclusions →
Add an exclusion → Folder:

- `C:\dev\flutter`
- `C:\repos\Jack\expenses-tracker`

This is a real tradeoff, not free. Exclude these two folders only, never a whole
drive or your Downloads folder.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `'flutter' is not recognized` | PATH not applied | Close all terminals, open a new one. Check `C:\dev\flutter\bin` is on the user PATH (Step 2). |
| `Unable to locate Android SDK` | SDK path lost | `flutter config --android-sdk "C:\Users\jiuny\AppData\Local\Android\Sdk"` |
| `cmdline-tools component is missing` | Missing SDK tool | SDK Manager → SDK Tools → Android SDK Command-line Tools |
| `Android license status unknown` | Expected here (Step 5) | Ignore unless a build fails with a licence error |
| `emulator-5554 is offline` | Emulator still booting | Wait for the home screen, then re-run |
| Emulator black screen or crawling | Hardware acceleration off | Step 6. In Device Manager, set the AVD's graphics to a Hardware option. |
| Gradle download hangs on first build | Large one-time download | Leave it. The first Android build can take 10+ minutes. |
| Wall of analyzer errors after codegen | build_runner failed | `dart run build_runner build` and read the *first* error, not the last |
| Build fails inside a package, e.g. `translateByDouble isn't defined` | `flutter pub add` picked a release that needs a newer Flutter | Pin the last release that builds, with a comment in `pubspec.yaml` (fl_chart is pinned to 1.0.0 for this reason) |
| App shows only a black screen, but the launcher and other apps are fine | The emulator's window manager is stuck in the app's launch animation (`adb shell dumpsys SurfaceFlinger --list` shows `animation-leash of starting_reveal`) | `adb reboot`, wait for the home screen, relaunch the app |
| App misbehaves but logcat shows no exception | Debug exceptions go to the Dart VM console | Run `flutter run -d emulator-5554` and read its output |
| `flutter create` fails on project name | Hyphen in the folder name | Pass `--project-name expense_tracker` (Step 11) |
| A package's documented API does not exist | Pub picked an older release that supports Dart 3.8 | Check the version in `pubspec.lock` and use that version's API. Do not upgrade Flutter. |
| App fails to start with a `dlopen` error or page-size warning | Native library not 16 KB-aligned | See `CLAUDE.md`, Traps |

If `flutter doctor` reports something not covered here, paste its full output into
Claude Code before letting it start building.
