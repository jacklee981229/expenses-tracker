# Polish batch 3: read a screenshot

## Spec (Jack, 2026-10-26)

Product names in Jack's quotes are replaced with [brackets]: the repo is
public.

我感觉不需要face id unlock吧。我就记账，没必要藏。
倒是，那个iphone背后tap两下就记账，这种功能怎么实现
---
1 2都ok，写计划吧
不做 Siri 快捷指令 -> 去除掉。

Agreed in chat before this: batch 3 is screenshot reading (with food-delivery
receipts) plus Back Tap as a way to trigger it, using the clipboard route
(A); Face ID lock is dropped; "Siri shortcuts" leaves the out-of-scope list.

## How it works

- In the add sheet, a scan button picks a screenshot from Photos. The app
  reads its text on the phone (no internet), finds the amount, the shop and
  the date, and fills the sheet. Nothing is saved until Jack taps Save; the
  picture is never stored.
- Back Tap: an iPhone Shortcut that Jack makes once: Take Screenshot →
  Copy to Clipboard → Open URL `expenses://app/scan`. The app opens, reads the
  picture from the clipboard and opens the same filled sheet. iPhone asks
  once whether the app may paste from Shortcuts.

## Decisions

- D1. "Siri shortcuts" no longer out of scope (done).
- D2. Packages, versions the resolver picks for Dart 3.8 (Jack approves):
  `google_mlkit_text_recognition` 0.16.0 (on-device text reading, iPhone
  and Android), `image_picker` 1.2.1 (pick a screenshot), `pasteboard`
  0.5.0 (read a picture from the clipboard).
- D3. Text reading uses Google's ML Kit on both platforms, so what I test on
  the Android emulator matches the iPhone. Latin letters only to start
  (English and Malay); Chinese shop names come out empty until a Chinese
  model is added (bigger app). The iOS minimum rises from 12.0 to 15.5,
  which ML Kit needs; Android compiles against SDK 36. Found while testing:
  ML Kit sends usage statistics to Google (pictures and text stay on the
  phone).
- D4. No product names in the repo (Jack's public-repo rule): receipts are
  read by generic clues (`Total`, `RM`, dates, delivery fee lines), not by
  recognising a named app. A delivery receipt (it has a delivery fee) goes
  to Food; other receipts use the shop name and batch 1's note-picks-category.
- D5. Screenshots are read, never kept.
- D6. Jack sends 3–5 real screenshots (delivery orders, e-wallet payments)
  to tune the reader. They stay out of the repo; the unit tests use made-up
  text shaped like them.
- D7. PLAN.md is deleted (Jack, 2026-10-26: "PLAN.md可以删了，感觉很误事呢。一切基于我说的为准就好了。");
  the traps that still hold moved to CLAUDE.md, and there is no out-of-scope
  list any more.

## Loading animation (Jack, 2026-10-26)

然后那个load着receipt上的data的时候能不能给个符合主题的loading animation？
---
先做ABC原型给我看
---
B+C吧。开工！
---
erm这样看C就不好看了。我觉得你改成A+B吧。

- D8. Prototypes A (print a receipt), B (scan light), C (screenshot card):
  https://claude.ai/artifact/LQUKkMsWWsNHs8RoiAituo (private). Jack first
  picked B+C, then on the emulator found the screenshot card ugly and
  switched to A+B: a little receipt prints out of a slot at the top right
  of the amount box and keeps feeding, one soft light sweeps the box, the
  amount blurs; when read, the light fades and the receipt tears off to the
  right. Must keep: slow, soft sweep; the receipt and tear match the
  ledger's print-in and tear-away.

## Feedback after testing (Jack, 2026-10-26)

有个bug，如果已经有description了他就不会改。但是他应该description和amount都跟着改才对。所以那个blur effect不止作用于amount，也要作用在description。
---
另外，把+和-变成同一个button，就是 +/-，按一次是+，按第二次是-。类似[某记账 app]。
然后，把scan的button从上面移来下面原本-button的地方。然后换个颜色。

- D9. A scan replaces the amount, the note and the date with what it
  found; anything not found is cleared (the date goes back to today). The
  note blurs with the amount while reading.
- D10. One +/− key where + was: a plus, pressed again straight after it
  becomes a minus (and back). The scan key moves to where − was, with a
  face washed in the accent; the header loses its scan button.

## Naming the page (Jack, 2026-10-26)

哦 我现在才发现到原来是我的那个食物screenshot没有description。他能不能识别这是[外卖 app]呢？能的话就填[外卖 app]就好了
---
如果扫到店家名就 [外卖 app] - 店家名 更好。但是因为我给的screenshot是店家名cut了一半。。。所以没

- D11. Recognising an app by name would put a trademark in the public repo,
  so Jack chose "记住我填的": each read keeps the page's printed labels;
  after a save, the note names that kind of page (the whole note without a
  shop, the part before ` - Shop` with one). The next screenshot of the
  same kind fills `Name - Shop`, or the name alone. Names live only in the
  phone's database: a new `receipt_kinds` table, schemaVersion 2.

## Tasks

- [x] 1. Packages added, iOS minimum 15.5, photo-access text in Info.plist;
      `expenses://app/scan` link registered on iPhone and Android. Verify:
      `flutter build apk --debug`; the iPhone build is checked by GitHub
      Actions on the next push.
- [x] 2. Receipt reader in `core/utils`: amount, shop, date from the read
      lines. Verify: unit tests on sample texts (total line, largest RM
      amount, dates in several formats, no amount found).
- [x] 3. Scan button in the add sheet: pick, read, fill. Verify on the
      emulator with Jack's screenshots pushed to its gallery.
- [x] 4. `expenses://app/scan` opens the filled sheet from a clipboard picture;
      without a picture, the plain sheet with a short note. Verify on the
      emulator with `adb shell am start -d expenses://app/scan` (the clipboard
      picture part only on the iPhone).
- [x] 5. CLAUDE.md test list, checks, light and dark. Commit and push
      after Jack confirms.
- [ ] 6. On the iPhone, once it can be installed: Jack makes the Back Tap
      Shortcut (steps in the report) and tries it.
- [x] 7. Loading animation A+B (D8). Verify: burst screenshots on the
      emulator show the receipt printing and feeding, the moving light, the
      blur, and the receipt tearing off.
- [x] 8. Rescan replaces amount and note; the note blurs too (D9). Verify:
      scan a transfer, then a receipt without a shop: the note clears.
- [x] 9. +/− key and the scan key in the keypad (D10). Verify: unit test
      for the key; emulator 12 +/− +/− 2 shows RM12 − 2 = 10.00.
- [x] 10. Named kinds of receipt page (D11). Verify: unit tests for matching
      and naming, DAO tests; emulator: upgrade keeps all 9 expenses, typing
      the app's name once makes the next scan of that page fill it.
