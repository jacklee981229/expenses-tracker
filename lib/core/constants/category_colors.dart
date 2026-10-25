import 'dart:ui';

/// The 16 swatches offered in the category colour picker: soft "macaron"
/// tones. The 14 default categories use 14 of them; brown and
/// slate are the extras. Stored as `RRGGBB`, no `#`.
const List<String> kCategoryColorHexes = [
  'E9695B', // red
  'F3776B', // salmon
  'EA967A', // peach
  'F6AA55', // amber
  'FAC551', // yellow
  'A5C85A', // lime
  '4AB771', // green
  '3DBEA9', // teal
  '4FB3E8', // sky
  '6395EC', // blue
  '7B80E8', // indigo
  'A16AEA', // purple
  'E47CC0', // pink
  'C08A6C', // brown
  '8E9AAF', // slate
  '9E9EA3', // grey
];

/// `E9695B` -> opaque [Color].
Color colorFromHex(String hex) => Color(0xFF000000 | int.parse(hex, radix: 16));
