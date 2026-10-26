import 'note_utils.dart';

/// A kind of receipt page Jack has named (an app's order page, say): the
/// labels printed on it, and the name he gave it.
typedef ReceiptKind = ({Set<String> labels, String name});

/// Two pages are the same kind when they share at least this many labels...
const int kKindMinShared = 4;

/// ...making up at least this share of the smaller page's labels. A page
/// scrolled elsewhere, or showing another ad, still matches.
const double kKindMinOverlap = 0.5;

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
/// whole note when the receipt showed no shop, or the part before
/// ` - Shop` when it did. Null when there is nothing to learn.
String? learnedKindName({required String note, String? shop}) {
  final cleaned = cleanNote(note);
  if (cleaned == null) return null;
  if (shop == null) return cleaned;
  final suffix = ' - $shop';
  if (!cleaned.endsWith(suffix)) return null;
  return cleanNote(cleaned.substring(0, cleaned.length - suffix.length));
}
