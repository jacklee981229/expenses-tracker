// The Expenses app's cloud backup: the phone uploads its gzipped backup here and lists or fetches the kept copies.
// The rules are in backup.js; README.md has the commands.
import { DAY_PREFIX, LATEST, LONGEST, keyFor, listing, looksGzipped, metadataFrom, rightToken, writesFor } from './backup.js';

export default {
  /** @param {Request} request @param {{ BACKUPS: KVNamespace, BACKUP_TOKEN?: string }} env */
  async fetch(request, env) {
    // Only the app calls this; a browser page never should.
    if (request.headers.get('Origin')) return json({ error: 'Not allowed.' }, 403);
    if (!(await rightToken(request.headers.get('Authorization'), env.BACKUP_TOKEN))) {
      return json({ error: 'Wrong token.' }, 401);
    }
    const { pathname } = new URL(request.url);
    if (request.method === 'PUT' && pathname === '/backup') return upload(request, env);
    if (request.method === 'GET' && pathname === '/backups') return list(env);
    const name = pathname.match(/^\/backups\/([^/]+)$/)?.[1];
    if (request.method === 'GET' && name) return download(name, env);
    return json({ error: 'Not found.' }, 404);
  },
};

/** @param {Request} request @param {{ BACKUPS: KVNamespace }} env */
async function upload(request, env) {
  if (Number(request.headers.get('Content-Length') ?? 0) > LONGEST) return json({ error: 'Too big.' }, 413);
  const metadata = metadataFrom(request.headers);
  if (metadata === null) return json({ error: 'Missing or wrong X-Day, X-Exported-At or X-Count.' }, 400);
  const bytes = await request.arrayBuffer();
  if (bytes.byteLength > LONGEST) return json({ error: 'Too big.' }, 413);
  if (!looksGzipped(bytes)) return json({ error: 'Not a gzipped backup.' }, 400);
  for (const { key, options } of writesFor(metadata)) await env.BACKUPS.put(key, bytes, options);
  return json({ ok: true, day: metadata.day });
}

/** @param {{ BACKUPS: KVNamespace }} env */
async function list(env) {
  // 60 kept days fit in one page of 1,000 keys.
  const [days, latest] = await Promise.all([
    env.BACKUPS.list({ prefix: DAY_PREFIX }),
    env.BACKUPS.list({ prefix: LATEST }),
  ]);
  return json(listing(days.keys, latest.keys));
}

/** @param {string} name @param {{ BACKUPS: KVNamespace }} env */
async function download(name, env) {
  const key = keyFor(name);
  if (key === null) return json({ error: 'Not found.' }, 404);
  const bytes = await env.BACKUPS.get(key, 'arrayBuffer');
  if (bytes === null) return json({ error: 'Not found.' }, 404);
  return new Response(bytes, { headers: { 'Content-Type': 'application/gzip' } });
}

/** @param {unknown} body @param {number} status */
function json(body, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });
}
