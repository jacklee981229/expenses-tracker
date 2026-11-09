import 'note_utils.dart';

final RegExp _spaces = RegExp(r'\s+');

/// [shop] as learned notes match it: case and runs of spaces ignored, since
/// two readings of one page can differ in both.
String shopKey(String shop) =>
    shop.trim().replaceAll(_spaces, ' ').toLowerCase();

/// The note to remember for a read screenshot: the one Jack saved, when it
/// differs from the note the reading [filled] in. Null when he kept that
/// note or left the note empty, or the reading found no shop or amount.
String? noteToLearn({
  required String? shop,
  required int? amountMinor,
  required String filled,
  required String saved,
}) {
  final note = cleanNote(saved);
  if (cleanNote(shop) == null || amountMinor == null || note == null) {
    return null;
  }
  return note == cleanNote(filled) ? null : note;
}
