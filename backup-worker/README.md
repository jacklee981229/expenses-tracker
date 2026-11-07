# Expenses cloud backup

A Cloudflare Worker (`index.js`, its rules in `backup.js`) that keeps the app's backups in Workers KV: one copy per
day, kept 60 days, and `latest`, kept for good. The phone uploads its gzipped backup (the same file as Export Backup)
and lists or fetches the kept copies; every call needs the token. Run every command in this folder
(`C:\repos\Jack\expenses-tracker\backup-worker`). Wrangler is pinned at 4.86.0, the last for Node 20: ignore its
"new version available".

## Setting it up, once

1. `npm install`, then `npx wrangler login` if this laptop isn't logged in (an OAuth page in the browser).
2. `npx wrangler kv namespace create expenses-backup`, only if it isn't made yet: put the `id` it prints into
   `wrangler.toml` (keep the binding name `BACKUPS`, not the one it suggests).
3. The token is in `.dev.vars` (never committed). Make it the Worker's secret:
   `npx wrangler secret put BACKUP_TOKEN`, and paste the part after `BACKUP_TOKEN=` when it asks.
4. `npx wrangler deploy`. It should print `https://expenses-backup.jacklee981229.workers.dev`, the address the app
   uses (`kBackupUrl` in `lib/core/constants/app_info.dart`).
5. On the phone: Settings › Cloud Backup, type the token from `.dev.vars` (capitals, spaces and dashes don't
   matter). Type it by hand rather than sending it through a chat app.

A new token: delete `.dev.vars`, make another 24-character one (letters and digits, no i, l, o, 0 or 1, in groups of
four), repeat step 3, and type it into the phone again.

## Getting a backup onto the laptop

In Git Bash, in this folder (`latest`, or a day such as `2026-11-07`). It lands in the project's gitignored
`scratch/`, since the file holds every expense and note and must never be committed:

```bash
mkdir -p ../scratch && curl -fsS -H "Authorization: Bearer $(sed -n 's/^BACKUP_TOKEN=//p' .dev.vars)" https://expenses-backup.jacklee981229.workers.dev/backups/latest -o ../scratch/expenses-latest.json.gz
```

The file is the same as Export Backup's, so Import Backup on any phone reads it. Don't fetch it with PowerShell's
`>`: it rewrites the bytes as text.

`curl ... /backups` (the same header) lists the kept days with their expense counts.

## Trying it on the laptop

`npm test` runs the rules' tests. A probe of the live Worker from Python must send another User-Agent (the app's is
`Dart/3.8 (dart:io)`): Cloudflare answers Python's own with `error code: 1010` before the Worker sees it. The list can
show an upload up to a minute late. `npm run dev` serves the Worker at http://localhost:8793 with a local KV in
`.wrangler/` and the token in `.dev.vars`; the emulator reaches it at `http://10.0.2.2:8793`, with the app run as
`flutter run --dart-define=BACKUP_URL=http://10.0.2.2:8793`.
