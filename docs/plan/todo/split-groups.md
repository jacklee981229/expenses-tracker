# Split: groups that share expenses

## Spec (Jack, 2026-11-11)

OK. expenses.
这里我们能不能加一种独立功能？
就是像splitwise的那个，establish一个group/trip，还是单纯一顿饭。然后，里面的钱开始写paid by who，by多少钱。然后share by几个人。然后最后可以算出来谁还谁多少钱。这个我用数学都算得出，算法是非常简单的对吧。就是对比每个人应该出多少钱和已经出了多少钱。balance就好了。
做这个功能。看一下是不是可以refer to icost的ledger功能？就是我平常的是一个ledger，如果有新的trip还是啥的就可以另外开一个。然后再要一个小小的私人定制。反正是我的part的比如Jack的就会auto record在我的私人ledger。当然这个可以之后才做。先看我们怎么做这个新功能。先plan。

## What the references give

- iCost: 多账本, one book per occasion (daily, a trip), which can be
  edited, copied and archived, and bills filtered by book. Its App Store
  page shows no split between people. So iCost gives the "open another
  book" part, Splitwise the split part.
- Splitwise: each person's balance is what they paid minus their share.
  People who are owed and people who owe are then paired off, biggest
  first, which settles everyone in at most (people − 1) payments.

## Defaults (unless a decision changes them)

- A group is a name plus its people, for a trip or a single meal alike.
  People are only names on Jack's phone: friends don't need the app,
  nothing syncs. `Me` (Jack) is in every group, first, and can't be
  removed; the others keep the order they were added in ("the group's
  order").
- A group expense: amount, note, day, category, who paid (one person,
  D2), who shares it (any of the group's people, all by default), split
  equally (D3). The payer need not be among those who share it.
- Equal split in sen: each share is the amount ÷ sharers, rounded down;
  the sen left over go one each to those sharing it, the payer first if
  they share, then in the group's order. So the shares always add up to
  the amount (RM100 by 3, Ali paying: Ali 33.34, the others 33.33).
  Shares are stored per person when saved, so adding a person later
  leaves old expenses as they were.
- Balance per person = paid − share, summed over the group; the
  balances always add up to zero. Who pays whom: biggest debtor pays
  biggest creditor, repeat; ties go by the group's order, so the list is
  the same each time.
- Who pays whom is only shown (D5): no repayments are recorded, and a
  settled group is archived.
- Groups: create, rename, add people, rename a person; a person is
  removed only while no entry names them. A group can be deleted with a
  confirm (cannot be undone). My addition, from iCost: a finished group
  can be archived, folded away below the others.
- Group expenses stay out of the personal ledger, Analysis, the report,
  the personal colour field and the CSV export (until the later "my part
  goes to my ledger" plan). A category used by a group expense counts as
  used, so it can only be archived (hard constraint 4 widens to group
  expenses).
- Backup: groups go into the Export Backup file, and so the cloud backup,
  under a new optional key; a file without it has no groups, so backups
  stay format 1 and old files and builds still read each other (D7).
  Merge adds groups, people, entries and shares the phone doesn't have,
  row by row by id like expenses, with each entry's category matched by
  name as expenses are. Replace replaces the groups too; the Merge or
  Replace prompt counts groups beside the rest, so a file with none shows
  it before anything is wiped.
- RM only, as everywhere (hard constraint 7).
- Database: four new tables, schema 6 → 7 with a migration step:
  - groups: name, archived, order;
  - people: group, name, is `Me`, order;
  - entries: group, amount, category, note, day, payer;
  - shares: entry, person, amount.
  Indexes on entries by group and shares by entry, made both on a fresh
  install and in the step to 7.

## Out of scope

- My part going into my personal ledger by itself: the later plan Jack
  named. The data leaves room (entries keep a category; `Me` is marked).
- Several payers on one expense, unequal splits (exact amounts, shares,
  percent): only if D2/D3 say so.
- Friends on their own phones, sync, invites.
- Scanning a screenshot into a group, group charts or reports, reminders,
  settling across groups.

## Decisions

Jack, 2026-11-11, on the options below:

D5的话只需要结果。不需要marked paid。
D6可以做一个小卡片的image，可以share的。符合我的app主题的，但是重点是要让大家一目了然。便利性>美观。最好两者兼施。
其他都ok，开始吧。

So: D1 (a), D2 one payer, D3 equal, D4 category, D5 result only (no
Mark paid, no repayments), D6 a small shareable picture card of who pays
whom (clear at a glance first, in the app's theme too), D7 schema 7 with
the optional backup key, D8 earlier names as chips.

The options as put to him:

- D1. Where groups live. The spec reads two ways:
  - (a) A group is a page of its own: a book button in the Ledger's top
    row (the month title already picks the month) lists the groups, and
    one opens with its people, its expenses, who pays whom, and its own
    + button. The personal ledger, Analysis and the add sheet stay as
    they are. Recommended: it is the smallest change and keeps trips out
    of the month's figures.
  - (b) Full iCost books: every expense belongs to a book; the Ledger,
    Analysis, report, search and colour field all switch with it, and a
    trip book adds people, payer and shares. About twice the work, and
    it touches every screen there is.
  - (c) A fourth tab for groups in the bottom bar: changes the bar Jack
    picked (tabs left, + right).
- D2. Who paid ("paid by who，by多少钱"): one payer per expense
  (recommended; a bill two people paid goes in as two expenses), or
  several payers, each with an amount.
- D3. Split: equally among the people ticked (recommended); unequal
  splits later.
- D4. Category on group expenses: yes, the same category grid
  (recommended; the row shows its icon and the later plan needs it), or
  a note only.
- D5. Settling: each suggested payment has Mark paid, which opens with
  the amount filled in (change it for part of it) and records a
  repayment (recommended), or only show the result.
- D6. My addition: share who pays whom as plain text through the share
  sheet, to paste into the group chat (recommended: small, `share_plus`
  is already in).
- D7. Schema 6 → 7 (needed); backup stays format 1 with the optional
  groups key (recommended), or a format 2 that older builds refuse.
- D8. For a one-off meal: names from earlier groups offered as chips when
  adding people (recommended, my addition, no friends screen), or type
  every name each time.

## Tasks

- [x] 1. Plan agreed with Jack (D1–D8); to-do item added.
- [x] 2. Design with the designer skill: two or three rough prototypes
      (A/B/C) on a private page of the book button and group list, the
      group page with who pays whom, the add sheet for a group expense,
      and the share card (D6), inside the theme card, including what the
      group page's colour field shows; draft labels with them. Verify:
      Jack's pick, his words and a must-keep list recorded here.

D9. Jack, 2026-11-11: "我选了A,但是我还是希望这些split result是在click一个button后才出现的，而不是常驻". Asked how: a Settle up button on the
group page opens A's result in a bottom sheet (payments, balance chips,
Share as picture); the Books list drops "You pay …" too and shows only
people and total. Row 0 (book button, Books sheet, New group with
earlier-name chips, add sheet with Paid by / Split between) as drawn.

Must keep (prototype A, private page in Jack's memory notes):
- The group page is the app's own: the group's top four categories as the
  colour field, days as receipts, the + button.
- Who pays whom reads at a glance: two avatars with an arrow, "Ali pays
  Jack", the amount big on the right.
- Balances as small chips, green owed, red owes.
- The share card: only the payments, big, on the group's colours, in the
  glass card; group name, days, people and total above; readable as a
  chat thumbnail.
- The add sheet keeps the usual amount box, categories and keypad, with
  Paid by (one) and Split between (any) chips and the live "RM70.00 each".
- [x] 3. `core/utils/split_settle.dart`: equal shares in sen, balances,
      who pays whom. Unit tests: RM100 by 3, payer not sharing, payments
      adding up and settling everyone, at most (people − 1), nobody at
      zero listed, same order every run. Verify: `flutter test`.
- [x] 4. Schema 7: the four tables and indexes, `SplitDao`, the migration
      step, `dart run build_runner build`; `CategoryDao.usageCount`
      counts group entries (its accessor gets the table, and the
      comments on `deleteAll` and `categoryUsageProvider` are put right).
      DAO tests on an in-memory database: saving and editing an entry
      rewrites its shares, deleting a group takes everything in it, a
      person with entries can't be removed, a category used only by a
      group expense counts as used. Verify: tests pass; the app opens
      Jack's existing emulator data at schema 6 and it is all still
      there.
- [x] 5. Backup: the optional groups key in export and import (Merge
      with categories matched, Replace deleting group rows before
      categories), the import prompt's counts, and the cloud backup
      counting group entries so a phone with only groups still uploads.
      Tests in the export, import and cloud backup suites: round trip,
      a file without the key, Merge from another install's category ids.
      Verify: `flutter test`.
- [x] 6. Providers and screens as picked in task 2: book button and group
      list, new and edit group (earlier names as chips), group page with
      who pays whom, add, edit and delete a group expense, archive and
      delete a group, the share card through `picture_share.dart`. Reuse
      the existing
      pieces: `AmountKeypad` (scan made optional), `AmountDisplay`,
      `CategoryGrid`, `DateChip`, the sheets in `sheets.dart`,
      `SwipeActionRow` with Undo, `ReceiptCard`, `GlowScaffold`,
      `FloatingAddButton`; not `AddExpenseController`, which is tied to
      personal expenses. Copy in `strings.dart`. Verify: `flutter
      analyze` clean.
- [x] 7. Run on `Pixel_9` with a marked test group: 3 people, 4
      expenses (one the payer doesn't share), check the payments match
      hand maths, share the card, then check the personal ledger's month
      total didn't change; screenshots beside the prototype. Remove the
      test group after.
- [x] 8. Checks: `flutter analyze`, `flutter test`, `flutter build apk
      --debug`; review my own diff; fresh-eyes review of plan + diff and
      the designer's screenshot review; fix what holds up.
- [x] 9. CLAUDE.md: the new tests in the Testing list, hard constraint 4
      covering group expenses, group expenses kept out of the personal
      figures, the backup's groups key.
- [ ] 10. Jack confirms → wide sweep (both themes, other sizes) → check
      the iPhone has a fresh cloud backup → commit and push → put the
      CI's `.ipa` at `C:\Jack\ipa\` → delete this plan and tick its
      to-do items.
