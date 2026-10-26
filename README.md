# Expense Tracker

A personal expense tracker for one person. Flutter only: data stays on the
phone in SQLite (`expenses.sqlite`), and amounts are RM. Card style, light
and dark themes, 3D category icons.

- `CLAUDE.md`: how to work on the code (rules, conventions, testing)
- `docs/ENVIRONMENT.md`: the Windows machine setup and emulator

Run it on the `Pixel_9` emulator:

```powershell
flutter emulators --launch Pixel_9
flutter run -d emulator-5554
```

iPhone: every push to `main` builds an unsigned `.ipa` on GitHub Actions
(the run's Artifacts). Install it with Sideloadly and a free Apple ID; it
must be re-signed every 7 days, so export a JSON backup first.

Back Tap logging on the iPhone (set up once):

1. Shortcuts app › new shortcut with three actions: Take Screenshot, Copy to
   Clipboard, Open URLs `expenses://app/scan`.
2. Settings › Accessibility › Touch › Back Tap › Double Tap › that shortcut.
3. Double-tap the back of the phone on a receipt or order screen: the app
   opens with the amount, shop and date filled in. Check them and tap Save.
   The first time, allow the app to paste from Shortcuts.

Checks before calling a change done: `flutter analyze`, `flutter test`, and
`flutter build apk --debug` after any package change.
