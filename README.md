# Expense Tracker

A personal expense tracker for one person. Flutter only: data stays on the
phone in SQLite (`expenses.sqlite`), and amounts are RM. Card style, light
and dark themes, 3D category icons.

- `CLAUDE.md`: how to work on the code (rules, conventions, testing)
- `docs/PLAN.md`: what the app does (screens, data model, phases, pitfalls)
- `docs/ENVIRONMENT.md`: the Windows machine setup and emulator

Run it on the `Pixel_9` emulator:

```powershell
flutter emulators --launch Pixel_9
flutter run -d emulator-5554
```

Checks before calling a change done: `flutter analyze`, `flutter test`, and
`flutter build apk --debug` after any package change.
