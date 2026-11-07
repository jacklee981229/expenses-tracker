// The backup Worker's rules, apart from the routes (index.js) so `node --test` can check them: the token, the day a
// backup belongs to, what each upload writes, and the list the app reads back.

/** The biggest backup taken, in bytes. A year of expenses gzips to well under 1 MB. */
export const LONGEST = 5 * 1024 * 1024;
/** How long a day's copy is kept, in seconds (60 days). */
export const KEEP_SECONDS = 60 * 24 * 60 * 60;
/** The newest copy, kept with no expiry so something is left after a long break. */
export const LATEST = 'latest';
export const DAY_PREFIX = 'day:';

const encoder = new TextEncoder();
const hex = (buffer) => [...new Uint8Array(buffer)].map((b) => b.toString(16).padStart(2, '0')).join('');

/** Two strings compared in a time that doesn't depend on where they first differ. @param {string} a @param {string} b */
function sameText(a, b) {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

/**
 * The token as typed on a phone: case, spaces and the dashes between its groups don't count.
 * @param {string} token
 */
const tidyToken = (token) => token.toLowerCase().replace(/[^a-z0-9]/g, '');

/**
 * Whether a request's Authorization header carries the right token. Both are hashed first, so the comparison takes
 * the same time whatever their lengths.
 * @param {string | null} authorization @param {string | undefined} token
 */
export async function rightToken(authorization, token) {
  if (!authorization || !token) return false;
  const typed = tidyToken(authorization.replace(/^Bearer\s+/i, ''));
  const wanted = tidyToken(token);
  if (!typed || !wanted) return false;
  const digest = async (text) => hex(await crypto.subtle.digest('SHA-256', encoder.encode(text)));
  return sameText(await digest(typed), await digest(wanted));
}

/**
 * A real calendar day written YYYY-MM-DD, or null. The phone sends its own day, since the Worker runs in UTC and
 * Malaysia's day starts eight hours earlier.
 * @param {string | null} text
 */
export function dayFrom(text) {
  if (!text || !/^\d{4}-\d{2}-\d{2}$/.test(text)) return null;
  const [year, month, day] = text.split('-').map(Number);
  const date = new Date(Date.UTC(year, month - 1, day));
  const real = date.getUTCFullYear() === year && date.getUTCMonth() === month - 1 && date.getUTCDate() === day;
  return real ? text : null;
}

/**
 * What an upload says about itself, from its headers, or null when a header is missing or wrong.
 * @param {Headers} headers
 */
export function metadataFrom(headers) {
  const day = dayFrom(headers.get('X-Day'));
  const exportedAt = wholeNumber(headers.get('X-Exported-At'));
  const count = wholeNumber(headers.get('X-Count'));
  if (day === null || exportedAt === null || count === null) return null;
  return { day, exportedAt, count };
}

/** @param {string | null} text */
function wholeNumber(text) {
  if (!text || !/^\d{1,16}$/.test(text)) return null;
  return Number(text);
}

/** Whether the bytes start as a gzip file does. @param {ArrayBuffer} bytes */
export function looksGzipped(bytes) {
  const start = new Uint8Array(bytes, 0, Math.min(2, bytes.byteLength));
  return start.length === 2 && start[0] === 0x1f && start[1] === 0x8b;
}

/**
 * The two keys an upload writes: its day's copy, which expires, and the latest, which doesn't.
 * @param {{ day: string, exportedAt: number, count: number }} metadata
 */
export function writesFor(metadata) {
  return [
    { key: DAY_PREFIX + metadata.day, options: { expirationTtl: KEEP_SECONDS, metadata } },
    { key: LATEST, options: { metadata } },
  ];
}

/** The KV key for a day or `latest` in an address, or null. @param {string} name */
export function keyFor(name) {
  if (name === LATEST) return LATEST;
  const day = dayFrom(name);
  return day === null ? null : DAY_PREFIX + day;
}

/**
 * The list the app shows: the kept days, newest first, and the latest copy's details (null before any upload).
 * @param {{ name: string, metadata?: unknown }[]} dayKeys @param {{ name: string, metadata?: unknown }[]} latestKeys
 */
export function listing(dayKeys, latestKeys) {
  const days = dayKeys
    .filter((key) => key.name.startsWith(DAY_PREFIX) && isMetadata(key.metadata))
    .map((key) => key.metadata)
    .sort((a, b) => (a.day < b.day ? 1 : a.day > b.day ? -1 : 0));
  const latest = latestKeys.find((key) => key.name === LATEST)?.metadata;
  return { days, latest: isMetadata(latest) ? latest : null };
}

/** @param {any} value */
function isMetadata(value) {
  return (
    value !== null &&
    typeof value === 'object' &&
    dayFrom(value.day) !== null &&
    Number.isInteger(value.exportedAt) &&
    Number.isInteger(value.count)
  );
}
