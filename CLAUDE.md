# CLAUDE.md

Project conventions for this Flutter expense tracker. Read `docs/PLAN.md` for the
full specification and `docs/ENVIRONMENT.md` for the machine setup. This file
covers how to work, not what to build.

## Ground rules

- **Follow `PLAN.md`.** If something in the spec seems wrong or underspecified,
  say so and ask. Do not silently substitute a different design.
- **Do not add packages** beyond the list in `PLAN.md` section 2 without asking.
- **Do not build out-of-scope features** (`PLAN.md` section 1). No income, no
  budgets, no sync, no notifications, no receipt photos.
- Ask before any change that requires a Drift `schemaVersion` bump.

## Architecture rules

- Widgets never call DAOs. Screens read Riverpod providers; providers call DAOs;
  DAOs own all SQL.
- One DAO per table plus `AnalysisDao` for cross-table aggregation queries.
- Business logic lives in `core/utils/` or `data/services/`, never in a widget's
  `build` method.
- All user-facing copy goes in `core/constants/strings.dart`. No string literals
  in widget code.
- All colours, spacing, radii and motion come from `core/theme/`. No
  hardcoded hex, durations or magic numbers in widgets. Animations use only
  the five `AppMotion` durations (80/140/220/320/460 ms) and the
  `AppSprings`.

## Looks we don't use

Plain dark-grey cards with only a small colour block; flat full-colour cards
with no depth; every card tilted (the + button, amount box and keypad stay
upright); 3D-extruded charts (charts are 2D with shading and shadow);
per-category colours inside the total card's bars; plain line icons for
categories; a category block that fills the middle of the ledger.

## Hard constraints

These are correctness issues, not style preferences.

1. Money is `int` minor units (cents) everywhere. `double` for a monetary value
   is a bug. Convert to `double` only at the final chart section value.
2. Period grouping uses the `localDate` `YYYY-MM-DD` column. Never group on
   `occurredAt`.
3. Category icons come from the static `kIconRegistry` map of bundled image
   paths only. Never build an asset path from a stored icon key.
4. Categories with transactions are archived, never deleted.
5. Recurring generation updates `lastGeneratedMonth` inside the same DB
   transaction as the insert.
6. The history chip strip shows note text only. It never displays or fills an
   amount.
7. Currency is the hardcoded constant `RM`. There is no currency setting, no
   locale lookup, and no multi-currency handling anywhere.

## Code style

- `dart format` default (80 columns).
- Prefer `final`. Use `const` constructors wherever possible.
- Explicit return types on public methods.
- Riverpod providers named `<thing>Provider`, declared in the feature's
  `*_providers.dart`.
- Private widgets prefixed with `_` and kept in the same file as their parent
  only if under ~40 lines; otherwise extract to `widgets/`.
- No `print`. Use `debugPrint` and remove before phase completion.
- Fix all analyzer warnings before declaring a phase done.

## Testing

Unit tests are required for, and only for:

- `core/utils/money.dart` — parsing, formatting, rounding
- `core/utils/date_utils.dart` — period boundaries, week start, month lengths
- `data/services/recurring_generator.dart` — catch-up correctness, idempotency,
  day-of-month clamping
- `AnalysisDao` aggregation queries against an in-memory database

Widget tests are not required. Do not write them unless asked.

## Working style

- Run `flutter analyze` and the test suite before saying a phase is done.
- When changing Drift tables, run `dart run build_runner build` and confirm the
  generated files compile. (build_runner 2.15 ignores the old
  `--delete-conflicting-outputs` flag.)
- After adding or changing a package, run `flutter build apk --debug`. Analyze
  and the unit tests do not compile package code (see `docs/PLAN.md`
  section 2).
- Debug-build exceptions print to `flutter run`'s console, not reliably to
  logcat. Run `flutter run -d emulator-5554` when the app misbehaves on the
  emulator without an obvious error.
- Keep changes scoped. Do not reformat or refactor files unrelated to the
  current task.
- If a task turns out larger than expected, stop and describe the scope change
  rather than expanding silently.

## Environment

- Development machine is Windows 11; the editor is Trae. The test target is the
  Android emulator **`Pixel_9`**, the only AVD. Start it with
  `flutter emulators --launch Pixel_9`; it appears as `emulator-5554`.
- Use the installed toolchain as it is: **Flutter 3.32.0 / Dart 3.8.0** at
  `C:\dev\flutter`. See `docs/PLAN.md` section 0 and `docs/ENVIRONMENT.md`.
- Do not upgrade Flutter, switch channels, install SDKs, modify PATH, or run
  Android Studio installers.
- `flutter doctor` warnings about the unknown Flutter channel, the Android
  licence status, and Visual Studio are expected on this machine. Stop and
  report a toolchain problem only when an Android build fails for a reason
  outside the code, rather than trying to fix the toolchain yourself.
- Packages resolve against Dart 3.8, so a package may be older than its latest
  docs. Code against the version in `pubspec.lock`.
- Timezone is Asia/Kuala_Lumpur (UTC+8, no DST). Use device local time. Do not
  add a timezone package.
- iOS cannot be built on Windows. The unsigned iPhone build runs on GitHub
  Actions (`.github/workflows/ios-unsigned.yml`, on every push to `main`);
  Jack signs and installs it with Sideloadly and his free Apple ID, which
  expires every 7 days. Signing with a paid account (TestFlight) is on hold.
- Do not fine-tune spacing or typography against the Android emulator. That pass
  happens on a real iPhone later.
