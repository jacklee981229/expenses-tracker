/// Trims a note; an empty note becomes null. Case is never changed, because
/// history chips match notes exactly (`mamak` and `Mamak` are two chips).
String? cleanNote(String? note) {
  final trimmed = note?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}
