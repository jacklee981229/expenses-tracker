# Expense Tracker — Build Plan

A personal iOS expense tracking app built in Flutter. Local-only, single-user,
single-currency. The look is raised, slightly irregular cards over soft
drifting colour glows, 3D category icons, a violet gradient total card, and
sheet-based entry, with an animation on every action. It has a light and a
dark theme, chosen in Settings › Appearance (System by default).

**Primary dev target during build:** the `Pixel_9` Android emulator on Windows.
**Final target:** personal iPhone, installed through a friend's Apple Developer
Program account. iOS packaging is Phase 7 and is deliberately not a concern until
Phases 0–6 are done.

**Locale:** Malaysia. Currency is RM only, hardcoded. Timezone is Asia/Kuala_Lumpur
(UTC+8, no daylight saving), so local date boundaries are stable year-round.

---

## 0. Development environment (installed)

Everything below is already installed and verified. The app is built against
exactly this setup. Do not upgrade, reinstall, or switch any of it. Details,
verification commands, and troubleshooting are in `ENVIRONMENT.md`.

| Component | Installed |
|---|---|
| OS | Windows 11 Pro 25H2 |
| Git for Windows | 2.53.0 |
| Flutter SDK | **3.32.0** (Dart 3.8.0) at `C:\dev\flutter` |
| JDK used by Flutter | Microsoft OpenJDK 21.0.12 |
| Android Studio | 2026.1.4 (for the SDK and emulator; not the editor) |
| Android SDK | platforms 33–37, build-tools 34/36/37, NDK 26.3 and 27.0, CMake 3.22.1, command-line tools |
| Emulator | AVD **`Pixel_9`**: Android 17 (API 37), Google Play, x86_64, 16 KB memory pages |
| Editor | Trae with the Dart and Flutter extensions |

Start the emulator and check that Flutter sees it:

```
flutter emulators --launch Pixel_9
flutter devices          # lists emulator-5554, Android 17 (API 37)
```

`flutter doctor` shows these warnings on this machine. All are expected:

- **Flutter**: "unknown channel" / "unknown source". The SDK is pinned to 3.32.0
  on a local branch. Never run `flutter channel` or `flutter upgrade`.
- **Android toolchain**: "Android license status unknown". The installed
  command-line tools retired `sdkmanager --licenses`, and Flutter 3.32 does not
  recognise the new output. Android builds work regardless.
- **Visual Studio**: only needed for the Windows desktop target, which this
  project does not use.

A real toolchain problem shows up as a failing Android build
(`flutter build apk --debug`), not as one of the lines above.

---

## 1. Scope

### In scope

- Ledger: monthly total, day-grouped expense list, add/edit/delete
- Categories: 14 defaults, fully editable, custom icon + colour, reorderable, archivable
- Analysis: Week / Month / Year / All, pie chart, category breakdown, drilldown, multi-select filter
- Fixed monthly (recurring) expenses
- History chips on the add screen for fast re-entry
- Export to CSV and JSON, import from JSON
- Light and dark themes with an Appearance setting (System / Light / Dark)

### Out of scope (do not build)

- Income tracking, budgets, net worth, accounts
- Multi-currency
- Cloud sync, accounts, login
- Receipt photos / OCR
- Notifications and reminders
- Widgets, Siri shortcuts, watch app
- Localisation beyond English

Adding income later is a single Drift migration plus a filter clause. Do not
pre-build for it.

---

## 2. Stack

| Concern | Choice |
|---|---|
| Framework | Flutter 3.32.0, Dart 3.8.0 (pinned; see section 0) |
| State management | Riverpod (`flutter_riverpod`) |
| Database | Drift over SQLite |
| Charts | `fl_chart` |
| Formatting | `intl` |
| ID generation | `uuid` |
| File sharing | `share_plus` |
| File picking (import) | `file_picker` |
| Paths | `path_provider`, `path` |
| Native SQLite | `sqlite3_flutter_libs` |
| Codegen | `drift_dev`, `build_runner` (dev deps) |

Add packages with `flutter pub add <name>` so the resolver picks versions
compatible with the installed Flutter SDK. Do not hand-pin versions from memory.

Flutter 3.32 is not the newest SDK, so the resolver may choose an older release
of a package than its current documentation describes. Accept that, and code
against the version recorded in `pubspec.lock`. Never upgrade Flutter to get a
newer package.

The resolver only checks the Dart SDK constraint, so it can still pick a
release whose code needs a newer Flutter. `flutter analyze` and the unit tests
do not compile package code, so this only shows up in a real build: after
adding or changing a package, run `flutter build apk --debug`. Known case:
`fl_chart` is pinned to 1.0.0, because 1.1.0 and later call
`Matrix4.translateByDouble` (vector_math 2.2) and Flutter 3.32 pins
vector_math 2.1.4.

Do not add any package not listed here without asking first.

### UI approach

Material `Scaffold` as the base, with a custom token layer in `core/theme/`.
Cupertino pieces only where they genuinely match:

- `CupertinoPicker` / `showCupertinoModalPopup` — date selection
- `CupertinoActionSheet` — confirmations and option lists
- `BouncingScrollPhysics` on all scrollables

Do not attempt a pure-Cupertino app. It is missing pieces this app needs and is
awkward to theme.

Bundled assets (files, not packages):

- **Bricolage Grotesque** (SIL OFL), the one typeface, in `assets/fonts/` with
  its licence. It is a variable font: every text style sets its `wght` and
  `opsz` axes, because Flutter does not pick a variable weight from
  `fontWeight` alone.
- **Fluent Emoji 3D** (MIT, Microsoft) PNGs for the 40 category icons and the
  interface pictures, in `assets/icons/` with the licence, renamed to the
  icon keys.

---

## 3. Project structure

```
lib/
  main.dart
  app.dart                          # MaterialApp, theme wiring, root shell

  core/
    theme/
      app_colors.dart               # colour tokens, light and dark
      app_spacing.dart              # spacing, radii, sizes, motion, springs
      app_text_styles.dart
      app_theme.dart                # ThemeData assembly
    utils/
      money.dart                    # minor-unit <-> display conversion
      date_utils.dart               # period boundaries, local date strings
      icon_registry.dart            # STATIC icon key -> image path map
    constants/
      strings.dart                  # all user-facing copy
      category_colors.dart          # the colour palette for categories

  data/
    database/
      app_database.dart             # Drift database, schemaVersion, migrations
      tables/
        categories_table.dart
        transactions_table.dart
        recurring_rules_table.dart
        app_settings_table.dart
      daos/
        category_dao.dart
        transaction_dao.dart
        recurring_dao.dart
        analysis_dao.dart
        settings_dao.dart
      seed/
        default_categories.dart
    services/
      recurring_generator.dart      # catch-up generation on launch
      export_service.dart
      import_service.dart

  features/
    ledger/
      ledger_screen.dart
      widgets/
        total_card.dart             # violet total card with 7-day bars
        category_drawer.dart        # folded category filter
        day_grouped_expense_list.dart  # one receipt per day
        expense_row.dart
      ledger_providers.dart
    add_expense/
      add_expense_sheet.dart
      widgets/
        amount_display.dart
        amount_keypad.dart
        category_grid.dart
        date_chip.dart
        history_chip_strip.dart
      add_expense_controller.dart
    analysis/
      analysis_screen.dart
      widgets/
        period_switcher.dart
        category_filter_sheet.dart
        spend_pie_chart.dart
        category_breakdown_list.dart
      analysis_providers.dart
      category_detail_screen.dart
    categories/
      manage_categories_screen.dart
      edit_category_screen.dart
      widgets/
        icon_picker.dart
        colour_picker.dart
    recurring/
      recurring_list_screen.dart
      edit_recurring_screen.dart
    settings/
      settings_screen.dart

  shared/
    widgets/
      app_card.dart                 # raised card + the shared card shadows
      inset_group.dart              # grouped rows in one raised card
      inset_row.dart
      receipt_card.dart             # zigzag-bottomed receipt, dashed lines
      hero_surface.dart             # the violet gradient surface
      summary_card.dart             # label, big rolling figure, details
      large_title.dart              # kicker over a large title
      glow_background.dart          # page colour with drifting glows
      glow_scaffold.dart            # pushed pages over the glows
      floating_tab_bar.dart
      floating_add_button.dart      # the violet + button
      circle_icon_button.dart
      category_avatar.dart          # tinted tile with the 3D icon
      pressable.dart                # spring press for every tappable
      entrance.dart                 # play-once entrance, stagger helper
      rolling_amount.dart           # money that counts to its value
      swipe_action_row.dart
      pill_chip.dart
      empty_state.dart
      amount_text.dart
```

Rule: widgets never touch the database directly. Screens read providers,
providers call DAOs.

---

## 4. Data model

All tables use Drift. `schemaVersion` starts at 1.

### `categories`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | uuid v4 |
| `name` | TEXT NOT NULL | |
| `iconKey` | TEXT NOT NULL | key into `icon_registry.dart` |
| `colorHex` | TEXT NOT NULL | e.g. `FF7043`, no `#` |
| `sortOrder` | INTEGER NOT NULL | |
| `isArchived` | BOOLEAN NOT NULL DEFAULT 0 | |
| `isDefault` | BOOLEAN NOT NULL DEFAULT 0 | seeded categories |
| `createdAt` | INTEGER NOT NULL | epoch ms |

### `transactions`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | uuid v4 |
| `amountMinor` | INTEGER NOT NULL | **cents. Never a double.** |
| `categoryId` | TEXT NOT NULL | FK → categories.id, RESTRICT |
| `occurredAt` | INTEGER NOT NULL | epoch ms |
| `localDate` | TEXT NOT NULL | `YYYY-MM-DD` in device local time |
| `note` | TEXT NULL | |
| `source` | TEXT NOT NULL | `manual` \| `recurring` |
| `recurringRuleId` | TEXT NULL | FK → recurring_rules.id, SET NULL |
| `createdAt` | INTEGER NOT NULL | epoch ms |
| `updatedAt` | INTEGER NOT NULL | epoch ms |

`localDate` is written at insert time from `occurredAt` using the device
timezone. All period grouping queries use `localDate`, never `occurredAt`.
Grouping off a UTC epoch puts late-night entries on the wrong day.

### `recurring_rules`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | uuid v4 |
| `amountMinor` | INTEGER NOT NULL | |
| `categoryId` | TEXT NOT NULL | FK → categories.id |
| `note` | TEXT NULL | |
| `dayOfMonth` | INTEGER NOT NULL | 1–31 |
| `startMonth` | TEXT NOT NULL | `YYYY-MM` |
| `endMonth` | TEXT NULL | `YYYY-MM`, null = open-ended |
| `isActive` | BOOLEAN NOT NULL DEFAULT 1 | |
| `lastGeneratedMonth` | TEXT NULL | `YYYY-MM`, idempotency guard |
| `createdAt` | INTEGER NOT NULL | |

### `app_settings`

Single row, `id = 1`.

| Column | Type | Default |
|---|---|---|
| `firstDayOfWeek` | INTEGER | 1 (Monday) |
| `themeMode` | TEXT | `system` |
| `lastExportAt` | INTEGER NULL | epoch ms |

`themeMode` is the Appearance setting: `system`, `light` or `dark`.

Currency is not a setting. `kCurrencySymbol = 'RM'` lives in
`core/constants/strings.dart`.

### Indexes

```sql
CREATE INDEX idx_tx_local_date ON transactions(local_date);
CREATE INDEX idx_tx_category ON transactions(category_id);
CREATE INDEX idx_tx_date_category ON transactions(local_date, category_id);
CREATE INDEX idx_tx_cat_occurred ON transactions(category_id, occurred_at DESC);
```

The last one backs the history chip strip.

---

## 5. Seed data

### Default categories

Seeded on first launch only, guarded by a row-count check.

| name | iconKey | colorHex |
|---|---|---|
| Food | `food` | `E9695B` |
| Groceries | `groceries` | `4AB771` |
| Transport | `transport` | `F6AA55` |
| Petrol | `petrol` | `F3776B` |
| Toll & Parking | `parking` | `3DBEA9` |
| Utilities | `utilities` | `FAC551` |
| Rent | `rent` | `EA967A` |
| Phone & Internet | `internet` | `6395EC` |
| Shopping | `shopping` | `E47CC0` |
| Entertainment | `entertainment` | `A16AEA` |
| Health | `health` | `4FB3E8` |
| Education | `education` | `7B80E8` |
| Travel | `travel` | `A5C85A` |
| Others | `others` | `9E9EA3` |

### Icon registry

`core/utils/icon_registry.dart` must be a **static const map** from icon key
to a bundled image path:

```dart
const Map<String, String> kIconRegistry = {
  'food': 'assets/icons/food.png',
  'groceries': 'assets/icons/groceries.png',
  ...
};
```

**Never build an asset path from a stored key at runtime.** A key from the
database (or an imported backup) may name no bundled file; looking it up in
the map, with `others` as the fallback, keeps every icon a real image.

Icon keys (40), each a Fluent Emoji 3D picture named after it:

`food`, `fastfood`, `snack`, `coffee`, `drinks`, `groceries`, `transport`,
`car`, `taxi`, `train`, `petrol`, `parking`, `utilities`, `rent`, `internet`,
`phone`, `shopping`, `clothes`, `beauty`, `entertainment`, `game`, `music`,
`movie`, `book`, `education`, `health`, `medical`, `gym`, `insurance`,
`subscription`, `travel`, `pet`, `gift`, `charity`, `laundry`, `haircut`,
`baby`, `tools`, `savings`, `others`

Interface pictures from the same set (`UiIcons`): receipt, chart, gear, sun,
calendar, label, plus.

### Category colour palette

16 hex values offered in the colour picker, in soft "macaron" tones:
all 14 above plus `C08A6C` (brown) and `8E9AAF` (slate). The picker shows them
in hue order, red through grey.

---

## 6. Design system

Two themes from one token set (`core/theme/app_colors.dart`):

| Token | Light | Dark | Used for |
|---|---|---|---|
| `background` | `EEF0F7` | `0A0C18` | the page, under the glows |
| `surface` | `FFFFFF` | `151829` | cards and receipts |
| `sheetBackground` | `F6F5FD` | `12152A` | the add sheet and other sheets |
| `label` | `17172B` | `EEF0FF` | primary text |
| `accent` | `5A4BE8` | `7B6DFF` | selected states, tags, links |
| `heroBase` + glows | `5A4BE8` lit by `9B8CFF` and `FF8DCB` | same | total card, amount box, + button, Save |
| `glowA/B/C` | lilac, pink, sky | violet, teal, magenta | the drifting page glows |
| `destructive` | `D6335A` | `E0365C` | delete |

Category icon tiles mix the category colour into the card colour (`tint`:
20% light, 24% dark).

**Depth:** every card wears two shadows, a thin hard edge just below it and a
wide soft shadow (`cardShadows`). Keys and the + button stand on a hard
shadow and press down onto it.

**Irregularity, where it helps:** the total card leans −1.4°, receipts lean
0.6° alternating, category tags lean ±2.5°, a picked add-sheet tile leans −3°.
The + button, the amount box and the keypad never lean.

**Type:** Bricolage Grotesque throughout; large titles 36 bold with a small
grey kicker above; money in tabular figures, the hero figure 52 extra bold.

**Motion:** only five durations — 80 / 140 / 220 / 320 / 460 ms — smaller
things faster, closing a step faster than opening; enter curve
`(0.2, 0.8, 0.2, 1)`, exit `(0.4, 0, 0.6, 1)`, a small overshoot `pop` for
playful entrances. Springs (`AppSprings`): press 900/40, release 900/30, pick
520/12, card 300/32. Every tappable springs under the finger (`Pressable`).
Lists come in staggered once per month or filter, never again on scroll.

Spacing scale: `4, 8, 12, 16, 20, 24, 32`. Radii: card 24, receipt 22, amount
box 26, tile and key 18, control 12, sheet 32, + button 22.

---

## 7. Screens

### 7.1 Root shell

A frosted tab bar floats at the bottom with two tabs, **Ledger** and
**Analysis**, and a dark pill that glides to the selected tab. Pages sit over
the drifting colour glows. The violet + button floats above the tab bar on the
Ledger tab, opening the add sheet; on Analysis it spins away. Settings is
reached from the gear button in the ledger header.

### 7.2 Ledger

**Header** (scrolls with the list):
- The month as the large title (`Oct 2026`, tap to pick a month) under a
  `My ledger` kicker, with `‹` `›` and the gear on the right. The title slides
  the way the month moved. A `This Month` chip appears when viewing another
  month.
- The total card: `Spent this month` (or `Spent in Sep 2026`), the total in
  big figures that roll to their value, a `Today RM45.00` chip, a receipt
  sticker, and a white pill bar for each of the last seven days ending today
  (today's glows). It swings in when the ledger opens.
- The category drawer: one `All categories` pill. Tapping opens tilted tags,
  one per category spent on this month with its total; picking one narrows the
  list, lights the tag in its colour, slides out its name and folds the drawer,
  leaving the pill showing that category with a × to clear. The filter drops
  when the month changes or the category has no spending left.

**Body:**
- One receipt per day, newest first: a stamp `SUN · 25 OCT` (and a `TODAY`
  badge), a row per expense separated by dashed lines, and `TOTAL` with the
  day's sum above a torn zigzag edge. Receipts come in staggered from below,
  or from the side the month moved.
- Expense row: the category tile with its 3D icon, the note as the title (the
  category name when there is no note), `12:30 · Food` beneath (just the time
  when the title is already the category), and `-RM12.50`.
- Rows for `source = recurring` get a small repeat glyph next to the title.
- Swipe left on a row → Edit and Delete (with confirmation). Tap → edit.
- A new expense prints into its receipt (the row unrolls, the receipt
  wobbles); a deleted one tears away to the right.

**Empty state:** the receipt picture, "No expenses this month" and a button
that opens the add sheet.

**Export nudge:** if `lastExportAt` is null or older than 14 days AND there is at
least one transaction, show a dismissible banner above the list:
"Back up your data — last export was N days ago". Dismissal lasts for the session.

### 7.3 Add expense sheet

The most-used screen. It must be fast. A full-height sheet in the sheet
colour with a grab bar, rising on a slight overshoot.

Layout top to bottom:

1. **Header** — a close button (`×`) on the left, the title (`New Expense` or
   `Edit Expense`) centred.
2. **Category tiles** — every active category in a 4-column grid of tiles
   (3D icon over the name) that scrolls when there are many, filling the
   space the other parts leave. The picked tile fills with its colour, leans,
   grows a touch and its icon pops. Archived categories are excluded. The last
   tile is a `+` that opens Edit Category.
3. **Amount box** — the violet gradient box (no lean) holding:
   - the amount in big white figures, `RM0.00` while empty, bumping on every
     key. It shows the live expression while typing (`RM12.5 + 3`), with the
     total on the right (`= 15.50`); it resolves on save.
   - under a dashed line, the date pill and the note field side by side. The
     pill reads `Today`, `Yesterday`, or `09/22 Tue`; tapping it opens a
     Cupertino date wheel with `Today` and `Yesterday` one-tap shortcuts.
   - the history chip strip (7.4).
4. **Keypad** — keys stand on a hard shadow and press down onto it:

   ```
   1  2  3  +
   4  5  6  −
   7  8  9  Save & Add
   .  0  ⌫  Save
   ```

   `Save` is the violet gradient key. After `Save & Add` the cleared amount
   drops in from above.

Keypad rules:
- Max 2 decimal places, enforced at input.
- `+` and `−` chain a running expression; the display shows the pending
  expression and resolves on save.
- Save and Save & Add are disabled (dimmed) while the amount resolves to 0.
- `Save & Add` keeps the sheet open, resets amount and note, keeps the selected
  category and date. It is disabled when editing an expense.

### 7.4 History chip strip

Sits at the bottom of the amount box, under the note field it fills.
Horizontally scrollable, single row of frosted chips that slide in one after
another when the category changes.

**Content:** every distinct note ever used in the currently selected category,
deduplicated, ordered by most recently used, unlimited length. **Amounts are not
shown and are never filled by a chip.** This is a description picker, nothing more.

```sql
SELECT note,
       MAX(occurred_at) AS last_used
FROM transactions
WHERE category_id = ?
  AND note IS NOT NULL
  AND TRIM(note) != ''
GROUP BY note
ORDER BY last_used DESC;
```

**Chip label:** the note text, exactly as stored. `Mamak`. Nothing else.

**Tap:** fills the note field only. Does not touch the amount. Does not save.
Tapping the already-selected chip clears the note.

**Rendering:** `ListView.builder` with `scrollDirection: Axis.horizontal` so it
stays lazy no matter how long the list gets.

**Empty:** fold the strip away and collapse its height. Do not show a
placeholder or an empty-state message.

**Reload:** the strip rebuilds whenever the selected category changes.

> Deduplication is deliberate. Without it, a daily-use category produces hundreds
> of identical chips and the strip stops being useful. Notes are matched
> case-sensitively and exactly, so `mamak` and `Mamak` are two chips. Do not
> normalise case; the user's own capitalisation is the label they expect to see.

### 7.5 Analysis

**Header:**
- Large title `Analysis` under an `Insights` kicker.
- Week / Month / Year / All as a frosted bar with a violet pill that glides
  to the chosen period, and a funnel filter button to its right.
- Period navigator below it: `‹` `›` around `1–7 Sep 2026`. Hidden for All.

**Filter:** the funnel opens a sheet of category chips (each with its icon),
multi-select, with `Clear` and `Done`. When any are selected, the funnel turns
violet, and the totals, chart, and list show only those categories.

**Chart card:** `Spent` (the period total) and `Per day` (the total divided by
the number of days in the period that had at least one expense), both rolling
to their values, over the donut.

**Pie chart** (`fl_chart` `PieChart`), 2D with depth:
- A donut with one section per category, coloured by `colorHex` and shaded
  lighter top-left to deeper bottom-right, largest first, clockwise from 12
  o'clock, casting a soft shadow below. The hole is a raised disc reading
  `Expense` over the period total.
- Each slice of at least 5% has its share (`8.73%`, `27.5%`: no trailing zeros)
  over its name outside the ring, on a leader line in the slice's colour.
  Labels that would collide fan apart, and the chart grows taller when one
  side needs the room.
- It swings in when shown; leader lines and labels follow.
- Tapping a section pushes it out and highlights its category card below
  (the others dim). Labels do not move.
- Categories under 3% of the total are merged into a grey "Other" slice, but
  stay as separate cards below.

**Category cards:** one raised card per category, sorted by amount, coming in
staggered: tile · name and amount over a share bar in the category colour that
grows to its share, with the expense count · the share in a small violet tag.
Tap → `CategoryDetailScreen`.

**Category detail:** a summary card with the category's tile and name in its
colour, its total, and the period and expense count, then the same receipts as
the Ledger, scoped to that category and period.

**Empty state:** "No expenses in this period".

### 7.6 Settings

`InsetGroup` sections:

1. **Data** — Manage Categories, Fixed Monthly Expenses
2. **Preferences** — Appearance (System / Light / Dark), First day of week
3. **Backup** — Export CSV, Export JSON, Import JSON, with a "Last export: …" line
4. **About** — version, build number

### 7.7 Manage categories

Reorderable list of active categories. Drag handle updates `sortOrder`. Tap to
edit. Swipe to archive. An "Archived" section at the bottom, collapsed, with a
restore action.

**Edit category:** name field, icon picker (grid of the 40 registry icons),
colour picker (16 swatches), live preview of the tile that pops on each
change.

Deleting is not offered for categories with transactions. Archive is the only
option there. Categories with zero transactions may be deleted outright.

### 7.8 Fixed monthly expenses

List of rules showing amount (`RM150.00`), category, note, and
`Monthly on the 15th`.
Inactive rules are dimmed with a "Paused" tag.

**Edit rule:** amount, category, note, day of month (1–31 picker), start month,
optional end month, active toggle.

Editing a rule affects future generations only. Already-generated transactions
are untouched. Show this as a footnote on the edit screen.

Deleting a rule leaves its generated transactions in place and nulls their
`recurringRuleId`.

---

## 8. Business logic

### Money

`core/utils/money.dart` owns all conversion.

```dart
int parseToMinor(String input);      // '12.5'  -> 1250
String formatMinor(int minor);       // 1250    -> '12.50'
String formatWithSymbol(int minor);  // 1250    -> 'RM12.50'
```

Thousands separators via `intl` `NumberFormat`. The symbol is the constant `RM`,
not a lookup. Amounts are non-negative; this is an expense-only app.

Never use `double` for a monetary value anywhere in the codebase, including
intermediate sums in Dart and including chart section values (convert to double
only at the final `PieChartSectionData`).

### Dates

`core/utils/date_utils.dart`:

```dart
String toLocalDateString(DateTime dt);           // 'YYYY-MM-DD'
(String start, String end) weekBounds(DateTime); // honours firstDayOfWeek
(String start, String end) monthBounds(DateTime);
(String start, String end) yearBounds(DateTime);
String toMonthKey(DateTime dt);                  // 'YYYY-MM'
int daysInMonth(int year, int month);
```

All period queries take `localDate BETWEEN ? AND ?` with inclusive string bounds.
String comparison on `YYYY-MM-DD` is correctly ordered, so no date parsing in SQL.

Use the device local timezone via `DateTime.now()` and `DateTime.toLocal()`. Do
not add a timezone package. Malaysia is UTC+8 with no daylight saving, so day
boundaries never shift and there is no ambiguous or skipped local hour to handle.

### Recurring generation

Runs in `RecurringGenerator.catchUp()`, called on app start and on resume.

```
for each rule where isActive = 1:
    cursor = lastGeneratedMonth == null
             ? startMonth
             : nextMonth(lastGeneratedMonth)

    while cursor <= currentMonth
          and (endMonth == null or cursor <= endMonth):

        day = min(rule.dayOfMonth, daysInMonth(cursor))
        insert transaction {
            amountMinor      = rule.amountMinor
            categoryId       = rule.categoryId
            note             = rule.note
            occurredAt       = dateAt(cursor, day)
            localDate        = toLocalDateString(occurredAt)
            source           = 'recurring'
            recurringRuleId  = rule.id
        }
        rule.lastGeneratedMonth = cursor
        cursor = nextMonth(cursor)
```

Each rule's catch-up runs inside one DB transaction. `lastGeneratedMonth` is the
sole idempotency guard: if the user deletes a generated transaction, it is not
recreated. That is intended.

`dayOfMonth = 31` in a 30-day month clamps to the 30th; in February it clamps to
the 28th or 29th.

### Export

**CSV** — header row `date,category,amount,note`, one row per transaction,
`localDate` ascending, amount as a plain decimal string, RFC 4180 quoting.

**JSON** — full fidelity:

```json
{
  "version": 1,
  "exportedAt": 1757000000000,
  "settings": { ... },
  "categories": [ ... ],
  "recurringRules": [ ... ],
  "transactions": [ ... ]
}
```

Both written to the temp directory and handed to `share_plus`. On success, write
`lastExportAt`.

**Import** — JSON only. Presents a dialog with two options: *Merge* (insert rows
whose `id` is not already present) and *Replace* (wipe all tables, then insert).
Validate `version` before touching anything. Never partially apply: wrap the whole
import in one DB transaction and roll back on any error.

### Database location

`path_provider`'s `getApplicationDocumentsDirectory()`, file `expenses.sqlite`.
On iOS this directory is included in device backups.

---

## 9. Phases

**Build all phases in one continuous session. Do not stop between phases to ask
for confirmation.** The ordering is a dependency order, not a set of review gates.

Between phases, run `flutter analyze` and the test suite as a self-check. Only
stop and report if something fails to compile, a test fails, or the spec is
genuinely ambiguous. Otherwise continue to the next phase.

The "done when" lines below are self-checks for you, not handoff points.

### Phase 0 — Foundation
Project init, package installation, folder structure, theme tokens, `InsetGroup`
and `CategoryAvatar` widgets, Drift schema with all four tables, codegen wired,
default category seeding, `Money` and `DateUtils` with unit tests.

*Done when:* app launches to an empty shell, DB file exists, 14 categories are
seeded, money and date helpers pass their tests.

### Phase 1 — Core loop
Ledger screen with month navigation and day grouping. Add expense sheet with
keypad, category grid, note, date. Edit and delete.

*Done when:* an expense can be added, seen in the list, edited, and deleted, and
the month total is correct.

### Phase 2 — Categories
Manage categories screen, reorder, archive/restore, edit screen with icon and
colour pickers.

*Done when:* a custom category can be created, used on an expense, reordered, and
archived without breaking existing transactions.

### Phase 3 — Analysis
Period switcher, period navigation, pie chart, breakdown list, category filter,
category detail drilldown.

*Done when:* switching Week/Month/Year/All produces correct totals, the pie
matches the list, and the filter narrows both.

### Phase 4 — Fixed monthly expenses
Rules CRUD, `RecurringGenerator.catchUp()`, repeat glyph in the ledger.

*Done when:* a rule with a past start month generates one transaction per month
up to the current month, running catch-up twice creates no duplicates, and day 31
clamps correctly in February.

### Phase 5 — History chips
The chip strip on the add sheet, wired to category selection.

*Done when:* selecting a category shows deduplicated note chips ordered by
recency, tapping one fills the note field and leaves the amount untouched, a
category with no notes hides the strip, and a category with 500+ distinct notes
scrolls smoothly.

### Phase 6 — Backup and settings
Export CSV/JSON, import JSON, settings screen, export nudge banner.

*Done when:* a full export/wipe/import cycle restores the database exactly.

### After Phase 6 — Card redesign
Every screen redesigned as raised, slightly irregular cards with an animation
on every action, in a light and a dark theme, with Bricolage Grotesque and
Fluent Emoji 3D icons. Sections 1, 2, 5, 6 and 7 describe the result.

### Phase 7 — iOS packaging
Deferred. See section 11.

---

## 10. Known pitfalls

Read this list before writing code. Each one has already cost someone a day.

1. **Icon tree-shaking.** Dynamic `IconData` construction breaks in release
   builds only. Use the static registry map.
2. **Float money.** Store and compute in integer cents throughout.
3. **UTC date grouping.** Group on `localDate`, never on a raw epoch.
4. **Category deletion.** Foreign key is RESTRICT. Archive instead.
5. **Recurring double-posting.** `lastGeneratedMonth` must be updated inside the
   same DB transaction as the insert.
6. **Drift migrations.** Any schema change requires bumping `schemaVersion` and
   adding a step to `MigrationStrategy`. Do not edit tables without one.
7. **`fl_chart` touch handling.** Section index comes back as `-1` on touch-exit.
   Guard for it or the highlight state will throw.
8. **Unbounded history list.** `ListView.builder`, not a `Row` inside a
   `SingleChildScrollView`.
9. **Sheet + keyboard.** The note field must not be covered when the keyboard
   opens. Use `viewInsets` padding, and consider dismissing the system keyboard
   whenever the custom keypad is used.
10. **Android is not iOS.** Scroll physics, safe areas, and font metrics differ.
    Do not fine-tune spacing against the Android emulator; that pass happens on a
    real iPhone in Phase 7.
11. **16 KB memory pages.** The `Pixel_9` image uses 16 KB pages. Flutter's own
    engine runs fine on it, but any plugin that ships native code must also be
    16 KB-aligned; in this stack that is `sqlite3_flutter_libs`. If the app
    fails to open the database, crashes on start with a `dlopen` error, or shows
    a page-size compatibility warning, check that plugin's resolved version
    first.
12. **Zero-width first frame.** Android lays out the first frame at zero
    width, and the root shell's `IndexedStack` lays out both tabs.
    Flutter 3.32's `CupertinoSlidingSegmentedControl` then gives its segments
    a negative width and asserts; in a debug build the failed layout leaves
    the whole app black. The period switcher is a custom pill instead; guard
    any widget that cannot take zero width.

---

## 11. iOS packaging (Phase 7, deferred)

Do not act on this section until Phase 6 is complete. Recorded here so the
decisions are not re-litigated later.

Distribution uses a friend's paid **Apple Developer Program** account. That
removes the free-Apple-ID route (Sideloadly or SideStore, re-signing every 7
days) entirely.

Flutter cannot build an iOS binary on Windows. The pipeline:

1. Push the repo to GitHub.
2. A macOS CI runner (Codemagic free tier, or GitHub Actions) builds the release
   with the same Flutter version used for development, 3.32.0.
3. The runner signs the build with the friend's team: a distribution certificate
   and provisioning profile, or an App Store Connect API key.
4. The build reaches the iPhone by one of two routes, chosen at Phase 7:
   - **TestFlight**: upload to App Store Connect, install with the TestFlight
     app. Each build expires after 90 days. The friend adds you as a tester.
   - **Ad Hoc**: the friend registers the iPhone's UDID on their account. The
     build stays installable until its provisioning profile expires.

The bundle ID is registered under the friend's team. Settle it before the first
install on the iPhone: changing it later makes iOS treat the app as a new one,
which starts with an empty database.

Reinstalls still happen (an expired build, a new phone, a bundle ID change), so
the export nudge in section 7.2 is not optional polish. It is the backup strategy.

---

## 12. Open items

Decide when reached, not before:

- Whether the `Others` category should be undeletable
- Whether the pie chart needs a trend/bar view alongside it
- Whether to add a search field to the ledger
- Whether Flutter 3.32.0 still builds with the Xcode version the chosen iOS route
  needs (TestFlight uploads require a recent Xcode). Check at the start of
  Phase 7; upgrade Flutter only if it does not.
- In Phase 7, on the iPhone: check Bricolage Grotesque and the 3D icons
  render, and give the iOS launch screen (`LaunchScreen.storyboard`, still
  Flutter's white default) the page colour (`EEF0F7` light, `0A0C18` dark) so
  launch does not flash.
