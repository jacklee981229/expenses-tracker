# Total card: week bars and fixed expenses

## Spec (Jack, 2026-11-05)

Ok有一个问题，首先我不理解那个排序，T是星期四，是今天，是最后一个，所以是今天会是最后一个？倒不如用回M to S，monday to sunday。然后那个Sunday那边因为是1号，1号都是fixed的支出，我要可以set fixed支出的feature，就是每个月固定支出。然后还有就是固定支出那天因为amount太高，变成其他days看不出有bar size。这个怎么solve？

A + B cap

B吧。再加一点颜色variant。

B3吧。但是其他颜色不用变。
然后加多一个feature，就是点bar就可以scroll去那个day。在previous month点bar就可以scroll去那个week。然后在analysis tab，为什么不管是week/month/year，都会有那个Last 6 months的bar chart？有点confusing。建议dynamic by filter不然就删掉。
另外那个pie chart可以做的亮一点，符合主题的。不用所谓的3D了，就发亮的感觉应该就够生动了。

呃我要主体是A，但是需要C的那个soft，那个比较round一点的，比较没有那么板正的感觉。

## Decisions

- D1. This month's bars are this week, in the order set by Settings' first
  day of week (Monday unless changed), today lit. Days still to come look
  like a day with no spending (`PillBars` already draws that). Only the
  provider changes: a this-week provider watching `firstDayOfWeekProvider`
  replaces `lastSevenDaysProvider`. Early in a month the week can start in
  last month; those days show their real spending.
- D2. Fixed monthly expenses already exist (Settings › Fixed monthly
  expenses). The total card's bars leave out expenses they generate
  (`source = recurring`), in this week's bars and other months' week bars.
  They still count in the month total, the legend and the Today chip.
  Analysis keeps them.
- D3. Cap: when the biggest bar is more than 2× the median of the bars
  with spending, and at least three bars have spending, bars scale to that
  2× line and taller bars fill the height. Median of an even count is the
  mean of the middle two. The rule is a pure function in `core/utils/`
  with named constants and a unit test (added to CLAUDE.md's Testing
  list); `PillBars` only draws its result, on both the total card and the
  Analysis bar card.
- D4. Cap mark: B (fade). A capped bar fades out towards its top. Only a
  capped bar changes colour, to the theme's coral (a new `core/theme`
  token, light and dark values, from the `E9695B` swatch); every other bar
  keeps today's look. A capped bar that is today is coral at full strength
  with the lit glow. CLAUDE.md's Theme line "the Analysis bars included"
  gains this one exception. Prototype: the private canvas "Expenses bar
  cap marks" (link in Claude's memory, never in this repo), card B and
  card B3 with its sky bars kept white. Must keep: the fade reads as
  "goes on beyond"; no labels or numbers added; today still stands out.
- D5. The import from the old app is remade so Sep–Nov's fixed items are
  Fixed monthly expenses: six rules on day 1 (rent, insurance, phone and
  subscriptions), already generated up to November, and those rows linked
  to them; two one-off items stay ordinary expenses. The items, amounts
  and start months are in `make_backup.py` and the rows file in `scratch/`
  (both gitignored, so this public repo carries no personal figures). Jack imports it with Replace, which also clears the
  duplicate categories the first (Merge) import made; Replace deletes
  everything else in the app, so it waits for his go.
- D6. Tapping a total card bar scrolls the ledger to that day (this month)
  or to the first day with expenses in that week (other months). It works
  whenever the ledger shows rows for that day, fixed ones included; a day
  with none, or from another month, or hidden by the category filter,
  does nothing. The ledger is a lazy list, so the scroll jumps to an
  estimated offset, then settles on the day's header once it is built; a
  day near the end scrolls as far as the list allows. No new package.
- D7. Analysis's bar card follows the period filter instead of always
  "Last 6 months": Week shows the last 6 weeks (a new `AnalysisDao` query
  that respects the first day of week, with a test), Month the last 6
  months (as now), Year the 12 months of that year (future months empty).
  The bar of the period on screen is lit. Week bars are labelled with the
  week's first date (`3 Nov`).
- D8. The Analysis pie gets a glow in the theme's colours, still 2D, in
  place of the current 3D look: the slice shading, the ring's dropped
  shadow, the raised centre disc's shadow and the inner-edge shade all go,
  and their unused tokens are removed. "Pie with 3D shading and a dropped
  shadow" joins CLAUDE.md's "Looks I don't prefer", and its "(charts are
  2D with shading and shadow)" note changes to say charts glow. The glow
  is picked from a quick prototype (task 7) on the same private canvas,
  made with the designer skill. Pick: A (Halo) as the body, with C's
  (Neon ring) softness: slices with rounded ends, less rigid. Must keep:
  A's full-width ring with each slice glowing softly in its own colour;
  C's round, soft slice ends; still 2D and not too shiny; labels and
  leader lines stay readable over the glow. Built: fl_chart can't round
  slice ends, so the ring is painted by hand (`glow_ring.dart`) and
  fl_chart, now unused, is removed. The hole shows the card, as in A; a
  slice thinner than 2px isn't drawn. Jack then found the gaps between
  slices off ("每个category之前的感觉还是差一点…但是我觉得方向是对的") and
  picked B of three gap looks: corners round off by 5px, slices 3px apart
  measured on the inner edge (9px corners opened uneven V notches; fully
  round 15px ends split the ring into pills). Then a thinner ring, picked
  from a sheet of thicknesses, ends and gaps: "B2H2", a 16px ring with 3px
  corners, 3px apart, the same outer edge (square ends and fully round
  ends not picked). And a minimum slice: "就算他只是1 sen，为了piechart的
  整体性他也要类似图片里的蓝色。就是不要让他只有一条线…不需要完完全全按照他
  的percentage…只要visually接近就可以了". Every slice takes at least 15°
  (the blue one, Phone & Internet at 4.3%, is 15.5°); the labels keep the
  real shares.

- D9. Under All, the Analysis bar card is hidden.
- D10. Its titles: `Last 6 weeks`, `Last 6 months`, `2026 by month` (the
  year on screen).

## Tasks

- [x] 1. Prototype two or three cap marks on the total card's bars; Jack
      picks one. Check: he has picked by ID. (B fade, B3 colour, D4.)
- [x] 2. Week bars in first-day-of-week order (D1). Check: on the emulator
      on a Thursday, M T W T F S S with T lit and F S S as stubs.
- [x] 3. Fixed expenses out of the total card's bars (D2). Check: a test
      fixed expense on today adds to the total but not to today's bar;
      afterwards delete the rule and the expense it made.
- [x] 4. The cap (D3, D4): the function and its test, the coral token,
      both cards. Check: the test covers odd and even counts, fewer than
      three bars and no cap needed; on the emulator a test day far above
      the rest fades out in coral, other days readable, a normal week
      looks as before.
- [ ] 5. Remake the import from the old app (D5). Check: the app's own ImportService
      reads it on a fresh database with month totals unchanged (Sep
      RM2,912.76, Oct RM2,531.06, Nov RM1,993.48) and six rules whose last
      generated month is 2026-11; then Jack's go and his Replace import.
- [x] 6. Tap a bar to scroll the ledger (D6). Check: on the emulator,
      tapping Monday's bar brings Monday's header to the top; in October,
      tapping the second week's bar brings that week's first day up.
- [x] 7. Prototype two or three glowing pie looks; Jack picks one, then
      build it (D8). Check: he picked by ID; the built pie matches the pick
      in both themes; CLAUDE.md's Looks line updated. Built with B's gaps,
      then thinned to B2H2 with a 15° minimum slice; Jack confirmed it.
- [x] 8. Analysis bar card by period (D7, D9, D10). Check: the new query's
      test passes; switching Week, Month, Year and All shows 6 weeks,
      6 months, 12 months and no card, each with its title.

Each code task: `flutter analyze` and the test suite pass. Emulator checks
add test expenses on top of what is there and remove only those.
