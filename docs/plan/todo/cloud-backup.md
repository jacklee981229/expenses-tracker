# Cloud backup: the history in Jack's Cloudflare

## Spec (Jack, 2026-11-07)

expenses-tracker. 能把history放进cloudflare之类的吗？
还是google docs？之类的。研究一下

(after the research) 好，写计划

## What there is now

Settings › Backup: Export CSV, Export Backup (the gzipped JSON from
`ExportService.buildBackupBytes`, out through the share sheet) and Import
Backup (file picker, then Merge or Replace). All by hand; the ledger's
banner nudges after `kExportNudgeDays` without an export (`lastExportAt`).

## Decisions

Jack, 2026-11-07: "好，写计划", read as yes to the research's
recommendations (D1–D3). Change any of them here.

- D1. The point is a backup that happens by itself, so the history
  survives a lost phone, a failed sideload or a wrong Replace. Not reading
  it on the laptop, not syncing two phones.
- D2. Cloudflare: a small Worker of its own in this project, keeping the
  backups in Workers KV. Not R2 (the research's first idea): several
  guides say switching R2 on asks for a payment method (Jack, 2026-11-07:
  "如果R2要绑卡就考虑一下D1"). KV and D1 both need no card. KV over D1: no
  table or SQL for Jack to run, a key expires by itself (which prunes old
  copies with no delete code), a value can be 25 MB, and 1,000 writes a
  day is plenty. D1 would work too (a table of blobs, 500 MB a database
  on the free plan, a DELETE for old days, `schema.sql` run by Jack) and
  lets him query it with SQL; pick it if that matters more. Not Google
  Drive (OAuth set-up, 7-day logins in Testing), not Google Docs.
- D3. No encryption of our own: a long random token guards the Worker and
  Cloudflare keeps KV encrypted at rest. The backups can be read in Jack's
  Cloudflare dashboard. Adding our own later needs a package.

Jack, 2026-11-07, on D4–D10 and KV over D1: 照推荐，开做

- D4. When it uploads: when the app is hidden (sent home or switched
  away), at most once every 10 minutes counted from the last try; and when
  it starts or comes back, if the last good upload is over a day old (so a
  failed one is retried). No change check: an unchanged upload is harmless
  and costs nothing. Never with 0 expenses.
- D5. What is kept: one copy per day (the day's last upload wins), each
  kept 60 days, plus the latest copy, kept for good, so nothing runs out if
  the app sits unused. A wrong Replace followed by an upload also replaces
  that day's copy; yesterday's stays.
- D6. Restoring is in the app: Settings lists the kept days (date, number
  of expenses), a picked day goes through today's Import (Merge or
  Replace); the latest copy shows only when its day has expired. The
  laptop can also fetch one with wrangler (the README says how). The
  smaller choice: no list in the app, restore by fetching the file on the
  laptop and using Import Backup.
- D7. A good cloud upload also sets `lastExportAt`, so the banner only
  shows when cloud backups have failed (or are off) for
  `kExportNudgeDays`. The footer's `Last export: …` stays as it is; the
  Cloud Backup row shows the last good upload.
- D8. Setting it up on a phone: the token is 24 letters and digits in
  groups of four (about 120 bits), short enough to type by hand from the
  laptop screen, so it never passes through a chat app. The phone checks
  it with the Worker (a list, not an upload) before keeping it.
- D9. A phone that has the token but has never set up or restored here
  (the iPhone Keychain keeps the token after the app is deleted, so a
  reinstall starts empty with the token still there) does not upload by
  itself: the row says `Not set up on this phone` until Restore from Cloud
  or Turn On is done. This keeps an empty phone from overwriting the good
  copies.
- D10. Words on screen (my drafts, for Jack's OK):
  - Backup row: `Cloud Backup`, its value `Off`, `7 Nov, 14:02` (the last
    good upload) or `Not set up on this phone`
  - token dialog: title `Cloud Backup`, message `Type the backup token
    shown on the laptop.`, placeholder `Token`
  - when on, the row's sheet: `Back Up Now` (my addition: a way to check
    it works at once), `Restore from Cloud`, `Turn Off` (red; forgets the
    token on this phone, the copies in the cloud stay)
  - when not set up on this phone: `Restore from Cloud`, `Turn On`
  - restore list: `Fri 7 Nov — 214 expenses` per day, newest first, with
    the footer `A backup can take a minute to show here.`
  - toasts: `Backed up`; failures as an alert `Cloud backup failed` with
    `Wrong token.`, `No connection.` or `The cloud didn't answer.`
- D11. Jack OK'd on 2026-11-07 what the build added or changed: `Turn
  Off` also on a phone not set up; the row's value `On` before the first
  good upload; `No backups in the cloud yet.` and `No expenses to back up
  yet.`; turning on with no expenses on the phone opens the restore list
  at once; the token ignores case and dashes; Back Up Now pressed during
  an upload joins it (the button stays as it is); the restore list's date
  has no comma (`Sat 7 Nov`).

## Tasks

Defaults:

- The Worker is `backup-worker/` in this project: `index.js` (routes),
  `backup.js` (the rules: token check, keys, expiry, the list),
  `backup.test.js` (Node's own `node --test`, no package), `wrangler.toml`,
  `package.json` with wrangler pinned at 4.86.0 (the last for Node 20, as
  in jacks-space), `.dev.vars.example`, `README.md`. `.gitignore` gets
  `backup-worker/.dev.vars`, `node_modules/` and `.wrangler/` before any
  token is written. Its address:
  `https://expenses-backup.jacklee981229.workers.dev`.
- Routes, each needing `Authorization: Bearer <token>` (`BACKUP_TOKEN`, a
  Worker secret), compared through SHA-256 digests as jacks-space's
  `rightPassword` does; a request with an `Origin` header (a browser) is
  refused. `PUT /backup` takes the gzipped bytes (at most 5 MB) with the
  phone's own day (`X-Day`, from `toLocalDateString`), `exportedAt` and
  the expense count as headers, and writes `day:YYYY-MM-DD` (60-day expiry)
  and `latest`, both with that metadata. `GET /backups` lists the days and
  the latest with their metadata. `GET /backups/<day>` (or `latest`)
  returns the bytes. KV can show a write up to a minute late, and allows
  one write a second per key: a Back Up Now pressed while an upload runs
  joins that upload instead of starting another (D11).
- The app: the address is a constant, overridable with
  `--dart-define=BACKUP_URL=…` for laptop checks. The token lives in the
  Keychain / Keystore like the Claude key (`CloudBackupTokenStore`, the
  `ClaudeKeyStore` pattern), never in the database or a backup. The last
  try, the last good upload and "set up on this phone" (D9) are kept in
  `cloud_backup.json` in the app's support folder, as `report_takes.json`
  is. Uses the `http` and `path_provider` packages already in; no new
  package, no schema change.
- iOS gives a hidden app a few seconds; a ~100 KB upload fits, and one cut
  off is retried by D4 (`shortcut:` comment: no background task; add one
  if backups are seen missing).

- [x] 1. The Worker (`backup-worker/`) and its `.gitignore` lines. Verify:
  `node --test` on `backup.js` (right, wrong and missing token; the day
  key from `X-Day`, a bad day refused; expiry on `day:` keys and none on
  `latest`; the list's order and metadata); then `npx wrangler dev` on
  port 8793 with a local KV and a test token, and curl probes: no token and
  a wrong token 401, an `Origin` 403, 6 MB 413; a PUT then the list then
  the GET return identical bytes (compared with `cmp`); a second PUT the
  same day replaces the day, not adds one.
- [x] 2. Jack sets it up (his steps, the README's commands): `npx wrangler
  login` if needed, `npx wrangler kv namespace create expenses-backup` (its
  id into `wrangler.toml`; I can paste it in), `npx wrangler secret put
  BACKUP_TOKEN` with the token I generate into the gitignored
  `backup-worker/.dev.vars`, and `npx wrangler deploy`. Verify: the 401
  probe and one PUT/GET of made-up bytes against the live address (the
  GET may lag a minute), then both keys it wrote (`day:2000-01-01`,
  `latest`) deleted, before the phone uploads anything.
- [x] 3. The app's client (`data/services/cloud_backup.dart`), token store
  and `cloud_backup.json`. Verify: unit tests with a fake HTTP client: the
  request (route, token header, body, day and metadata headers), the list
  read back, and each failure (401, 5xx, no network, a broken reply)
  giving a typed failure, never a throw; the file missing or broken read
  as not set up.
- [x] 4. When to upload (`core/utils/backup_timing.dart`, D4, D9), wired
  into `app.dart`'s `AppLifecycleListener` (`onHide`, `onResume`) and the
  first frame, setting `lastExportAt` on success (D7). Verify: unit tests
  for the decision (9 and 10 minutes since the last try, over a day since
  the last good one, 0 expenses, no token, token but not set up); then on
  the emulator against step 1's local Worker (`10.0.2.2:8793`; if Android
  refuses plain `http` there, a debug-only `usesCleartextTraffic` in
  `android/app/src/debug/AndroidManifest.xml`): add an expense, send the
  app home, and the day's copy appears.
- [x] 5. Settings (D6, D8–D10): the Cloud Backup row, the token dialog
  (checked by a list before it is kept), Back Up Now, Restore from Cloud
  into the existing Import sheet, Turn On / Turn Off. Verify: analyze;
  emulator screenshots (dark) of off, on, not set up, the restore list and
  a wrong token; a Merge restore of a copy whose count matches; and the
  reinstall case: delete `cloud_backup.json` with `adb shell run-as`,
  start the app, and nothing is uploaded. My test data on the emulator
  stays marked as test and goes afterwards; Jack's own expenses are
  checked to still be there.
- [x] 6. Checks: `flutter analyze`, `flutter test`, `node --test` in
  `backup-worker/`, `flutter build apk --debug`; the project CLAUDE.md
  gets a trap line (with cloud backup on, every backup, notes included,
  goes to Jack's Cloudflare KV; the token is only in the Keychain and
  survives an iPhone reinstall), the Worker's place and commands, and the
  new tests in the testing list; a fresh review of this plan against the
  diff. Not covered until Jack confirms: light theme, the iPhone (its build
  runs on GitHub after a push), a real background upload on iOS.
