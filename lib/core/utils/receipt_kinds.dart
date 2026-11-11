import 'note_utils.dart';

/// A kind of receipt page Jack has named (an app's order page, say): the
/// labels printed on it, and the name he gave it.
typedef ReceiptKind = ({Set<String> labels, String name});

/// Two pages are the same kind when they share at least this many labels...
const int kKindMinShared = 4;

/// ...making up at least this share of the smaller page's labels. A page
/// scrolled elsewhere, or showing another ad, still matches.
const double kKindMinOverlap = 0.5;

/// The food apps Jack orders from, known without being named first: their
/// order pages' fixed labels, read from his own screenshots (Nov 2026).
/// Promos, statuses and ads are left out, as they change from one order to
/// the next.
const List<ReceiptKind> kBuiltInKinds = [
  (
    labels: {
      'order details',
      'take from',
      'deliver to',
      'item details',
      'item subtotal',
      'food discount voucher',
      'delivery fee',
      'tax included where applicable',
      'order info',
      'if item unavailable',
    },
    name: 'Shopeefood',
  ),
  (
    labels: {
      'get help',
      'saver delivery',
      'on time',
      'quickly next time',
      'paylater',
      'offers applied',
      'total',
      'view order summary',
    },
    name: 'Grabfood',
  ),
];

/// Whether [name] is one of [kBuiltInKinds], which never need learning.
bool isBuiltInKind(String name) => kBuiltInKinds.any(
  (kind) => kind.name.toLowerCase() == name.trim().toLowerCase(),
);

/// The kind of page [labels] come from: a built-in food app first, else a
/// kind Jack named.
ReceiptKind? kindFor(Set<String> labels, Iterable<ReceiptKind> learned) =>
    matchKind(labels, kBuiltInKinds) ?? matchKind(labels, learned);

/// The named kind [labels] belongs to, best match first; null when none is
/// close enough.
ReceiptKind? matchKind(Set<String> labels, Iterable<ReceiptKind> kinds) {
  ReceiptKind? best;
  var bestOverlap = 0.0;
  for (final kind in kinds) {
    final shared = labels.intersection(kind.labels).length;
    final smaller = labels.length < kind.labels.length
        ? labels.length
        : kind.labels.length;
    if (shared < kKindMinShared || smaller == 0) continue;
    final overlap = shared / smaller;
    if (overlap >= kKindMinOverlap && overlap > bestOverlap) {
      best = kind;
      bestOverlap = overlap;
    }
  }
  return best;
}

/// The note for a read receipt: `Name - Shop` for a named kind with a shop,
/// the kind's name or the shop alone, or null with neither.
String? receiptNote({String? shop, String? kindName}) {
  if (kindName == null) return shop;
  if (shop == null) return kindName;
  return '$kindName - $shop';
}

/// The name to remember for a receipt's kind from the note Jack saved: the
/// part before ` - Shop` when the receipt showed a shop (or before the
/// first ` - ` when he retyped the shop); with none, the
/// part before the first ` - ` (he typed the shop himself), else the whole
/// note. Null when there is nothing to learn.
String? learnedKindName({required String note, String? shop}) {
  final cleaned = cleanNote(note);
  if (cleaned == null) return null;
  if (shop == null) {
    final dash = cleaned.indexOf(' - ');
    return dash < 0 ? cleaned : cleanNote(cleaned.substring(0, dash));
  }
  final suffix = ' - $shop';
  if (cleaned.endsWith(suffix)) {
    return cleanNote(cleaned.substring(0, cleaned.length - suffix.length));
  }
  // He retyped a misread shop (`Food App - kedai ali`): the part before
  // the dash still names the kind, unless it is the read shop's own name
  // (he only tidied `Kedai Ali - Puchong`).
  final dash = cleaned.indexOf(' - ');
  if (dash < 0) return null;
  final kind = cleanNote(cleaned.substring(0, dash));
  if (kind == null || shop.toLowerCase().startsWith(kind.toLowerCase())) {
    return null;
  }
  return kind;
}
