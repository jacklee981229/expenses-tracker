# CLAUDE.md

Project conventions for this Flutter expense tracker. `docs/ENVIRONMENT.md`
covers the machine setup. This file covers how to work, not what to build.

## Ground rules

- **What to build comes from Jack**: what he says in chat, or a plan in
  `docs/plan/todo/` agreed with him. There is no other spec; read the code
  for how a feature works now.
- **Ask before adding a package.** Add it with `flutter pub add <name>` so the
  resolver picks a version for Dart 3.8; never hand-pin from memory.
- Ask before any change that requires a Drift `schemaVersion` bump. Any table
  change needs that bump plus a step in `MigrationStrategy`.

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
  `AppSprings`; the looping scan motions (the light and the receipt's
  feed) use `AppMotion.sweep`, the colour field's change `AppMotion.flow`
  and its drift `AppMotion.drift`.

## Theme: this month's colours

One theme with a light and a dark version (Settings › Appearance picks one
or follows the phone).

- Ground: a plain page with four soft colour blobs spread evenly over it,
  in fixed places, easing off a little under the list.
- Colour logic: the blobs are the month on screen's top four categories,
  in each category's own colour; a month with fewer fills the gaps with the
  theme's violet, sky, pink and indigo. All four blobs share one base size;
  a category's share only nudges its blob (at most 15% either way), so it
  is hardly noticed. A bright colour is dimmed on the dark ground until
  page text at its centre keeps 4.5:1 (the small section labels 3:1).
  Category colour also marks the icon tiles, the total card's legend chips
  (two rows at most, with Today) and the amount box while recording.
  Everything else is neutral glass, the Analysis bars included.
- Type: Bricolage Grotesque; the month's total is the one hero.
- Shapes and material: glass, meaning a translucent tint, a 1px edge and a
  lighter top. The total card's glass is thinner than the glass under
  other text. Every text stays at least 4.5:1 (big figures 3:1) with any
  category colour behind it at full strength; `test/theme_contrast_test.dart`
  checks it. Day receipts keep the dashes, the torn edge and the slight
  alternating tilt; categories keep the Fluent 3D icons.
- Motion: the blobs drift slowly; on a month switch they change colour and
  size over `AppMotion.flow`; saving an expense swells its category's blob
  once. Reduce-motion stops the drift.
- Elements: C (gradient with glass) first, then B (colours that mean
  something) and D (one hero).
- Signature: the glass shows your month, quietly.

## Looks we don't use

Plain dark-grey cards with only a small colour block; flat full-colour cards
with no depth; every card tilted (the + button, amount box and keypad stay
upright); 3D-extruded charts (charts are 2D with shading and shadow);
per-category colours inside the total card's bars; plain line icons for
categories; a category block that fills the middle of the ledger; a mostly
blank Undo row with a small button (the deleted row becomes a full dark bar).

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

## Traps

- `fl_chart` is pinned to 1.0.0: 1.1.0 and later call
  `Matrix4.translateByDouble` (vector_math 2.2), and Flutter 3.32 pins
  vector_math 2.1.4. The resolver only checks the Dart SDK, so a package can
  still need a newer Flutter; only a real build shows it.
- `fl_chart` reports touch section `-1` on touch-exit; guard for it.
- The `Pixel_9` image uses 16 KB memory pages. Any plugin with native code
  must be 16 KB-aligned; a `dlopen` crash on start or a page-size warning
  means a plugin's native library is not.
- Android lays out the first frame at zero width, and the root shell's
  `IndexedStack` lays out both tabs. Flutter 3.32's
  `CupertinoSlidingSegmentedControl` asserts there and leaves a debug build
  black, so the period switcher is a custom pill; guard any widget that
  cannot take zero width.
- Changing the iOS bundle ID (`com.jack.expenseTracker`) makes iOS treat the
  app as new, with an empty database.
- ML Kit text recognition needs Android `compileSdk = 36` and iOS 15.5 (set in
  the committed `ios/Podfile` and the Xcode project). It also sends usage
  statistics to Google; pictures and their text stay on the phone.
- A launch through `expenses://app/scan` arrives as the first route: the whole
  link on Android, so compare `Uri.path`, never the route string.
- Sheets take their background from `bottomSheetTheme`. Passing a colour read
  when the sheet opens freezes it: a sheet opened by the scan link at launch
  then stays light after the dark theme loads.

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
- `core/utils/note_utils.dart` — history chip ranking
- `core/utils/duplicate_check.dart` — the duplicate warning
- `core/utils/insights.dart` — the Analysis summary line
- `core/utils/receipt_parser.dart` — reading a screenshot's amount, shop, date
- `core/utils/receipt_kinds.dart` and `ReceiptKindDao` — naming kinds of receipt page
- `core/utils/month_palette.dart` — the colour field's blobs and the legend's shares
- the theme's text contrast over every category colour (`test/theme_contrast_test.dart`)

Widget tests are not required. Do not write them unless asked.

## Working style

- Run `flutter analyze` and the test suite before saying a phase is done.
- When changing Drift tables, run `dart run build_runner build` and confirm the
  generated files compile. (build_runner 2.15 ignores the old
  `--delete-conflicting-outputs` flag.)
- After adding or changing a package, run `flutter build apk --debug`. Analyze
  and the unit tests do not compile package code.
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
  `C:\dev\flutter`. See `docs/ENVIRONMENT.md`.
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
