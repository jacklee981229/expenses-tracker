# Report refine: a short report, and Claude reading the expenses

## Spec (Jack, 2026-11-06)

report跟他refine一下。
不要只是list出全部东西。
我要的是精炼的。
然后claude给的summary也erm，有点普通。
我其实是要claude去读expenses来给summary的，而不是claude去读report来给summary

## What the report shows now (6 Nov 2026, 25 expenses)

Spent and its change; per day and its change; every category, one line
each (15 lines here); fixed and everyday; biggest day, biggest expense,
count and days with no spending; the notes seen most often. Claude gets
these same figures as text (`reportBrief`) and writes 2–4 sentences.
Mid-month the per-day line misleads: it reads "323% more" because a
month's fixed expenses all fall in its first days.

## Decisions (Jack, 2026-11-06: 都按推荐)

- D1. Batch 4 is committed first; this plan runs in its own session.
- D2. The short report keeps three parts: Claude's take on top as the
  report's lead; spent and its change against last month in one line;
  the top 3 categories with their change, the rest as one line ("N
  others, RM…"). Per day, fixed and everyday, highlights and most often
  go: Claude picks what is worth saying. The shared receipt picture
  follows.
- D3. Rough prototypes first: 2–3 looks of the short report for Jack to
  pick before the app changes.
- D4. Claude reads the period's expenses themselves (date, category,
  amount, note, fixed or not) and last period's total per category. The
  prompt asks for specific patterns and exceptions, not the report's
  figures again. Notes (shop names) now go to the Claude API: Jack OK'd.
- D5. Claude's take uses Sonnet 5.5; reading screenshots stays on Haiku
  5.5.

Jack, 2026-11-07, on the rough prototypes (A short receipt, B one sentence
leads, C notes beside the figures): 要的是B。其他照推荐。

- D6. The short report takes look B.
- D7. The report asks Claude on its own when it opens, and remembers the
  reply for that period and filter until its expenses change. Without a
  key there is no Claude part; after a failure, a tap tries again.
- D8. The shared picture keeps Claude's words out, as now: it shows B's
  figures.

Must keep (B):

- Claude's headline is the one hero: big type at the receipt's top, under
  a small violet sparkle and "Claude"; two or three points below it, each
  behind its category's colour dot, their amounts in bold.
- No section stamps; a dashed line parts Claude's words from the figures.
- The total in big type with its change sticker (the Analysis list's), and
  below it "vs last month's RM…" ("the same days last month" while a month
  runs); three rows of icon, name, amount and sticker, the stickers in one
  column; "N others" quieter, with a small grid of their colours.
- While Claude reads, the figures are already printed; the headline's place
  shows soft bars with the violet light sweeping and "Claude is reading N
  expenses…", and the reply fades in where it stays.
- Still the upright glass receipt with the torn edge, its lines printing in
  one after another.

Jack, 2026-11-07, on D9–D13 and the words below: 照推荐，开 P3 做

- D9. A running period is compared with the whole period before, as
  batch 4's D12 settled after testing (Jack, 6 Nov: "compare的话，month就是
  compare last month … 不用1-6号这种"). This replaces must-keep's "the same
  days last month", which assumed the older same-days rule: the line under
  the total always reads `vs last month's RM…` (`week's`, `year's`). The
  report's current "than last month's RM…" is already right, so there is
  nothing to fix there. Claude's brief says the period is still running
  and that the comparison is the whole period before.
- D10. The report's stickers are the Analysis list's `ChangeSticker` in
  ringgit (batch 4's D11: `▲RM45.20`, `▼RM12`, `New`, `= RM0`), not the
  prototype's percent.
- D11. Claude's take is saved on the phone (one small JSON file in the
  app's support folder, the latest 12 periods and filters), so it survives
  the iPhone closing the app. It stays out of the backup: it can be asked
  again. No new package (`path_provider` is in already), no schema change.
- D12. With exactly four categories the fourth gets its own row instead of
  "1 other" (my addition).
- D13. Settings' Claude section says what now goes to Claude: title
  `Claude` (now `Reading screenshots`), footer `With a key, Claude reads
  each screenshot you scan and the expenses of each report you open,
  notes included. Without one, screenshots are read on the phone only.`

## Tasks

Defaults:

- Claude's reply is `{headline, points[{text, category}]}`. The prompt asks
  for two or three points; one is shown as is, more than three keep the
  first three. A point's category is one of the period's category names or
  `none`; `none`, or a name Claude makes up, gets the others' grey dot
  (`chartOther`). An empty headline, no points, a refusal or anything else
  off-schema counts as no answer: the tap line.
- A take is the same while the period's bounds, the filter, the expenses
  (date, category, amount, note, fixed) and last period's per-category
  totals are unchanged (the fingerprint); a new day alone doesn't ask
  again. A reply that arrives after the sheet closed is still kept, and a
  sheet reopened while Claude reads joins that request. A failure is not
  kept: the next opening asks again on its own.
- The report waits 60 s for Claude (medium took 8.2 s for 60 expenses);
  screenshots keep 15 s. Every expense goes, for any period (`shortcut:`
  comment: fine for the app's first years; group older months once All
  passes ~1,000 expenses). One call costs about US$0.02 for a 60-expense
  month; the build's own calls stay under about US$0.30.
- The others row has no sticker; its grid shows the four biggest others'
  colours.
- Reused as they are: `spendChange` and `changeLabel(percent: false)`
  (insights.dart), `ChangeSticker`, `CategoryAvatar`, `ReceiptCard`,
  `DashedLine`, `Entrance` with `staggerDelay`, the scan's sweep motion,
  the summary line's `Icons.auto_awesome_rounded`, `path_provider`.

Words on screen (Jack OK'd):

- `Claude` (the small violet mark, with the summary line's sparkle)
- `Claude is reading 60 expenses…` (`1 expense…`); replaces `Claude is
  reading the report…`
- `5 others` (the row under the top three)
- `vs last month's RM1,449.85` (`last week's`, `last year's`; nothing under
  All, or when the period before had no spending)
- Settings, D13: `Claude` and its footer as above
- kept: `Claude didn't answer. Tap to try again.`
- dropped with what they labelled: `Ask Claude what stands out.`, the
  stamps `SPENT`, `BY CATEGORY`, `FIXED AND EVERYDAY`, `HIGHLIGHTS`, `MOST
  OFTEN`, `CLAUDE`, and the report's sentence templates (per day, fixed,
  biggest day and expense, counts, notes).

- [x] 1. The brief, the reply and the fingerprint
  (`core/utils/report_brief.dart`, D4). `reportBrief` takes the period's
  `ReportExpense`s, last period's `CategorySpend`s, the period label and
  word, days so far and the period's length, whether it still runs, and
  the kind names. It writes: the period (running or finished, days so far
  of its days), what it is compared with (D9), every expense as `date |
  weekday | category | amount | note | fixed`, the notes seen more than
  once counted by the app (count, total, days), and per-category totals
  now and in the period before. The note grouping (`_tidy`, `_kindOf`,
  first spelling, case; a named kind of receipt page counts as one group)
  moves here from report.dart with its tests. Also here: reading the
  reply, splitting Claude's text so its RM amounts can be bold, and the
  fingerprint (the brief without its days-so-far line). Verify: unit tests
  for each brief line, the fixed mark, note groups, running, finished and
  All; the reply (good, refused, cut off, off-schema, unknown category,
  four points, empty headline); the amount split; the fingerprint (same
  for a new day, different for a changed amount, note, category or last
  period's total).
- [x] 2. Sonnet 5.5 for the report (`data/services/claude_api.dart`, D5).
  `_send` takes the model, max_tokens and timeout per call (two sets of
  constants: screenshots `claude-haiku-5-5`, 4000, 15 s; the report
  `claude-sonnet-5-5`, 16000, 60 s). `reviewReport` sends the brief at
  effort medium with the reply schema (the period's category names and
  `none` as an enum), `fallbacks: "default"` and the header `anthropic-beta:
  server-side-fallback-2026-07-01` (it retries a cyber or frontier-LLM
  refusal on Sonnet 5; others stay refused), and the probe's prompt
  (habits, exceptions, what the change is made of; name shop, day, count
  and amount; don't repeat the figures printed below; headline at most 14
  words, two or three points at most 22). Screenshots keep their request
  as now, without fallbacks (Haiku has none). Verify: unit tests on both
  requests (model, effort, schema, fallbacks, header, max_tokens), refusal
  and failures giving nothing, each call's own timeout; then one real call
  through `ClaudeApi` with the `.env` key on made-up data whose reply
  parses and whose figures I check by hand.
- [x] 3. The short report's figures (`core/utils/report.dart`, D2). Keep
  the total, its change and last period's total, the expense count (for
  `Claude is reading N expenses…`), the categories, and the top three with
  the rest as one group (count, total, the ids of the four biggest for the
  grid; D12). Drop per day, fixed and everyday, biggest day and expense,
  no-spend days and most often, with whatever only they used. Changes are
  `SpendChange`s from `spendChange`, in ringgit (D10). Verify: unit tests
  (top three and others, four categories, five, ties, nothing to compare,
  the filter).
- [x] 4. Claude's take asked on opening and remembered (D7, D11): a
  provider in `analysis_providers.dart` that is not autoDispose (it
  outlives the sheet), asks once per key (bounds and filter) and
  fingerprint, and shares a request already running; and
  `data/services/report_take_store.dart`, the saved takes. Verify: unit
  tests for the store (same key and fingerprint found, other fingerprint
  or filter missed, the cap of 12, a missing or broken file read as
  empty).
- [x] 5. Look B in the sheet (`report_sheet.dart`, `claude_review.dart`,
  `strings.dart`, D6, D13): the Claude part on top (mark, big headline,
  points behind their category's dot with bold amounts); while reading,
  the figures are already printed and the headline's place shows soft
  bars under the violet sweep (`AppMotion.sweep`; still under reduce
  motion) with `Claude is reading N expenses…`, and the reply fades in
  there; on failure the tap line; without a key no Claude part and no
  dashed line. Then the total in big type with its sticker and the `vs`
  line, three rows (icon, name, amount, stickers in one column) and the
  others row (quieter, 2×2 colour grid). Upright glass receipt, torn edge,
  lines printing in one after another; no stamps. Settings' words (D13).
  Verify: analyze; emulator screenshots (dark) of reading, ready, failed
  (emulator network off) and a running and a finished month, each checked
  against every must-keep line and the prototype. The key on the emulator
  is whatever Jack set there: I never type it in. Without one, Jack adds it
  in Settings (his step) or the Claude shots wait; with one, the no-key
  state is checked in code and named untested. To see "reading" again I
  delete only the take store's file (`adb shell run-as`).
- [x] 6. The shared picture shows B's figures without Claude (D8): the
  heading, the total with sticker and `vs` line, the rows, the printed
  date and app name. Verify: the picture saved on the emulator and looked
  at.
- [x] 7. Checks: `flutter analyze`, `flutter test`, a debug build; the
  project CLAUDE.md's Claude trap (with a key, each report opened sends its
  expenses, notes included) and its testing list (the store) updated; a
  fresh review of this plan against the diff. Not covered until Jack
  confirms: light theme, other sizes, the iPhone.

