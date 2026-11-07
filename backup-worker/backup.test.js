import assert from 'node:assert/strict';
import { test } from 'node:test';

import { KEEP_SECONDS, dayFrom, keyFor, listing, looksGzipped, metadataFrom, rightToken, writesFor } from './backup.js';

const TOKEN = 'abcd-efgh-jkmn-pqrs-tuvw-xyz2';

test('the right token passes, in any case and with or without its dashes', async () => {
  assert.equal(await rightToken(`Bearer ${TOKEN}`, TOKEN), true);
  assert.equal(await rightToken('Bearer ABCDEFGHJKMNPQRSTUVWXYZ2', TOKEN), true);
  assert.equal(await rightToken('bearer abcd efgh jkmn pqrs tuvw xyz2', TOKEN), true);
});

test('a wrong, short or missing token fails', async () => {
  assert.equal(await rightToken('Bearer abcd-efgh-jkmn-pqrs-tuvw-xyz3', TOKEN), false);
  assert.equal(await rightToken('Bearer abcd', TOKEN), false);
  assert.equal(await rightToken('Bearer ', TOKEN), false);
  assert.equal(await rightToken('Bearer ----', TOKEN), false);
  assert.equal(await rightToken(null, TOKEN), false);
});

test('no token set on the Worker lets nothing in', async () => {
  assert.equal(await rightToken(`Bearer ${TOKEN}`, undefined), false);
  assert.equal(await rightToken(`Bearer ${TOKEN}`, ''), false);
  assert.equal(await rightToken('Bearer ', ''), false);
});

test('a day must be a real calendar day', () => {
  assert.equal(dayFrom('2026-11-07'), '2026-11-07');
  assert.equal(dayFrom('2028-02-29'), '2028-02-29');
  assert.equal(dayFrom('2026-02-29'), null);
  assert.equal(dayFrom('2026-13-01'), null);
  assert.equal(dayFrom('2026-11-7'), null);
  assert.equal(dayFrom('../latest'), null);
  assert.equal(dayFrom(null), null);
});

test('an upload reads its day, time and count from its headers', () => {
  const headers = new Headers({ 'X-Day': '2026-11-07', 'X-Exported-At': '1794038400000', 'X-Count': '214' });
  assert.deepEqual(metadataFrom(headers), { day: '2026-11-07', exportedAt: 1794038400000, count: 214 });
});

test('an upload with a missing or wrong header is refused', () => {
  const good = { 'X-Day': '2026-11-07', 'X-Exported-At': '1794038400000', 'X-Count': '214' };
  for (const [name, value] of [
    ['X-Day', '2026-02-30'],
    ['X-Exported-At', '-1'],
    ['X-Exported-At', '1.5'],
    ['X-Count', 'many'],
  ]) {
    assert.equal(metadataFrom(new Headers({ ...good, [name]: value })), null, `${name}: ${value}`);
  }
  const { 'X-Count': _, ...noCount } = good;
  assert.equal(metadataFrom(new Headers(noCount)), null);
});

test('only gzip bytes pass', () => {
  assert.equal(looksGzipped(new Uint8Array([0x1f, 0x8b, 8, 0]).buffer), true);
  assert.equal(looksGzipped(new TextEncoder().encode('{"version":1}').buffer), false);
  assert.equal(looksGzipped(new Uint8Array([0x1f]).buffer), false);
  assert.equal(looksGzipped(new ArrayBuffer(0)), false);
});

test("an upload writes its day's copy, which expires in 60 days, and the latest, which never does", () => {
  const metadata = { day: '2026-11-07', exportedAt: 1, count: 3 };
  const [day, latest] = writesFor(metadata);
  assert.deepEqual(day, { key: 'day:2026-11-07', options: { expirationTtl: KEEP_SECONDS, metadata } });
  assert.equal(KEEP_SECONDS, 60 * 86400);
  assert.deepEqual(latest, { key: 'latest', options: { metadata } });
});

test('an address names a day or the latest, nothing else', () => {
  assert.equal(keyFor('2026-11-07'), 'day:2026-11-07');
  assert.equal(keyFor('latest'), 'latest');
  assert.equal(keyFor('day:2026-11-07'), null);
  assert.equal(keyFor('2026-11-31'), null);
});

test('the list puts the newest day first and skips keys without details', () => {
  const a = { day: '2026-11-05', exportedAt: 5, count: 10 };
  const b = { day: '2026-11-07', exportedAt: 7, count: 12 };
  const c = { day: '2026-10-30', exportedAt: 1, count: 8 };
  const result = listing(
    [{ name: 'day:2026-11-05', metadata: a }, { name: 'day:2026-11-07', metadata: b }, { name: 'day:2026-10-30', metadata: c }, { name: 'day:2026-11-06' }],
    [{ name: 'latest', metadata: b }],
  );
  assert.deepEqual(result, { days: [b, a, c], latest: b });
});

test('the list before any upload is empty', () => {
  assert.deepEqual(listing([], []), { days: [], latest: null });
});
