# Polish batch 4: a name, the folded card, Analysis and sharing

## Spec (Jack, 2026-11-06)

Product names in Jack's quotes are replaced with [brackets]: the repo is
public.

expenses-tracker. 取个正式名字吧。
然后，那个homepage的spent this month，要save着他的collapsed/expand status，现在关掉开过都是expanded。
---
看能不能在analysis加多一些功能，也可以上网找看大家是怎么做的。尤其[一个记账 app]的很不错，每个category还有WoW(price)，就是比如在month里，对比上个month是up还是down。我一下子就发screenshot给你。
---
然后还有一些generate bill report的功能，screenshot and share的功能。都很不错，可以参考。
我也是都会发screenshots给你。
现在去研究一下。

Jack's five screenshots of that app (kept out of the repo) show:

- Analysis: a category donut over a list; each category has its share, a
  bar, the amount, the count and its change against the month before
  (▲ red up, ▶ yellow no change, ▼ green down). Two toggles above:
  `WoW(Price)` and first-/second-level categories.
- A day-by-day table (date, expense, income, balance) with a
  `Screenshot & Share` link under it, which offers Bill Report or
  Screenshot & Share.
- Bill Report, "Jack's Bill Report, Oct 2026": tiles for expense, income,
  expense/income ratio, biggest expense, biggest income, biggest transfer,
  net assets change, number of bills and days with records, then the
  categories with share, amount and count. Save to album / Share.
- Screenshot & Share: the month's figures as one long picture under a
  "Jack's Bill Report 2026/10" header. Save to album / Share.

## Decisions (Jack, 2026-11-06: 名字先不定，其他开始。)

- D1. Name: not picked yet. The app stays `Expenses` until Jack picks;
  the shortlist was Monthglass, Bulan, 月色 (a fourth was taken by another
  expense app). The bundle ID never changes (iOS would start empty).
- D2. The total card remembers folded or open across restarts: a column in
  the settings table, schema 3 → 4. A backup made before it still imports
  (the missing setting reads as open).
- D3. This batch: A, B, C, D and E below. Next batch: F a running total
  against last month, G a comparison with the last 3 months' average,
  H a calendar heatmap. Later: I a year in review.
  - A. Each category card shows its change against the period before
    (▲/▼ in ringgit). A tap cycles ringgit, percent, hidden.
  - B. Analysis as one long picture, shared.
  - C. The picture can hide amounts (shares and counts only).
  - D. The report shared as a picture: the receipt itself.
  - E. The summary line says where the period is heading: "At this pace,
    about RM… by month end."
- D4. Pictures go through the phone's share sheet, whose Save Image puts
  them in Photos; no separate Save to album button (it needs a package).
  iOS gets the add-to-Photos permission text, without which saving crashes.
- D5. Defaults (Jack can change them): A's mode is remembered, in the same
  settings change as D2. E shows only while the period is running, from
  its third day; fixed expenses count once (those still due this period
  included), and only everyday spending is carried forward. The report gets
  no "days with records" line: its no-spend days line already says it.

## Picks (Jack, 2026-11-06: 按推荐选)

- D6. A1, two stickers: the share tag stays as it is, and a change
  sticker sits under it, tilted the other way: ▲ in `heroUp`, ▼ in
  `heroDown`, New in the theme's violet, no change neutral, each with a
  faint glow in its own colour. One pill above the list cycles ringgit,
  percent and off for every card, and is remembered (D5).
- D7. While a period runs, it is compared with the same days of the period
  before (1–6 Nov against 1–6 Oct; a longer month is cut to the shorter
  one's length). The summary line and the report follow the same rule.
  A finished period compares whole with whole, as now.
- D8. B2, a poster: the period's total as the one hero with a small donut
  beside it, the top five categories with their change stickers, the
  month's colour field behind, short enough to read at a glance. Hide
  amounts swaps money for counts and percentages. A `Share as picture`
  link at the bottom of Analysis opens the preview with the switch and a
  Share button.
- D9. D as in the prototype: the report's upright receipt on the month's
  colour field, the date and the app name at its foot, shared from a
  button in the report's header. No hide amounts.
- D10. Copy as drafted: `At this pace, about RM… by month end`,
  `Share as picture`, `Hide amounts`, and the iPhone's Photos text
  `Save a picture of your spending to Photos.`

## Changes (Jack, 2026-11-06, after testing: 去掉这个吧。然后只有show RM就好了 / compare的话，month就是compare last month, week compare last week，不用1-6号这种)

- D11. No pill above the category cards: the stickers show the change in
  ringgit only, nothing remembered (replaces the cycling and D5's
  remembered mode). The shared picture still shows percent under Hide
  amounts.
- D12. Every comparison is the whole period before, running or not: this
  month against all of last month, this week against all of last week
  (replaces D7). The summary line and the report go back to "than last
  month".

## Tasks

- [x] 1. Prototype page for A's change tag and the pictures of B, C and D.
  Verify: Jack picks a look (D6–D10).
- [x] 2. The total card remembers folded (D2). Verify: unit tests that the
  setting survives a backup round trip and that an older backup without it
  imports; on the emulator, fold, close the app, reopen: still folded.
- [x] 3. E, the month-end projection (D5). Verify: unit tests (fixed counted
  once, fixed still due, period over, before day 3); seen on the emulator.
- [x] 4. A, the change on each category card, in the picked look. Verify:
  the change figures unit-tested; emulator screenshots, light and dark.
- [x] 5. B and C, Analysis as a picture with hide amounts. Verify: the
  picture saved on the emulator and looked at; the share sheet opens.
- [x] 6. D, the report as a picture. Verify: as task 5.
- [ ] 7. Analyze, tests, debug build; review of the plan against the diff.
  On the iPhone after the push (Jack): Save Image from the share sheet.
