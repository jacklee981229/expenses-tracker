/// The month's spending as the colour field behind the glass and the total
/// card's legend.
///
/// Shares are worked out in whole numbers from integer minor units; only the
/// blob's size factor is a `double`, and it is never money.
library;

/// The field always shows this many blobs, in fixed places.
const int kFieldBlobs = 4;

/// A blob's size moves at most this far either way with its share, so the
/// field stays even and a big category is only hinted at.
const double kBlobNudge = 0.15;

/// How much a blob grows per unit of share above an even split.
const double _nudgePerShare = 0.6;

/// One blob of the field: [categoryId] is null for a gap the theme fills.
class FieldBlob {
  const FieldBlob(this.categoryId, this.scale);

  final String? categoryId;

  /// The blob's size relative to its place's base size.
  final double scale;

  @override
  bool operator ==(Object other) =>
      other is FieldBlob &&
      other.categoryId == categoryId &&
      other.scale == scale;

  @override
  int get hashCode => Object.hash(categoryId, scale);

  @override
  String toString() => 'FieldBlob($categoryId, $scale)';
}

/// The month's top [kFieldBlobs] categories by spending, each sized by its
/// share of the month; places without a category are gaps at the smallest
/// size. [totals] is `(categoryId, minor)`; non-positive totals are skipped
/// and ties keep their order.
List<FieldBlob> fieldBlobs(List<(String, int)> totals) {
  final top = _positiveLargestFirst(totals).take(kFieldBlobs).toList();
  final sum = _sum(_positiveLargestFirst(totals));
  return [
    for (var i = 0; i < kFieldBlobs; i++)
      if (i < top.length)
        FieldBlob(top[i].$1, _scale(top[i].$2, sum))
      else
        const FieldBlob(null, 1 - kBlobNudge),
  ];
}

/// The legend: the top [count] categories with their share of the month in
/// whole percent, rounded half up. [totals] is `(categoryId, minor)`.
List<(String, int)> topShares(List<(String, int)> totals, {int count = 3}) {
  final positive = _positiveLargestFirst(totals);
  final sum = _sum(positive);
  return [
    for (final (id, minor) in positive.take(count))
      (id, (minor * 200 + sum) ~/ (sum * 2)),
  ];
}

double _scale(int minor, int sum) {
  final perMille = minor * 1000 ~/ sum;
  const even = 1000 ~/ kFieldBlobs;
  final scale = 1 + (perMille - even) / 1000 * _nudgePerShare;
  return scale.clamp(1 - kBlobNudge, 1 + kBlobNudge);
}

List<(String, int)> _positiveLargestFirst(List<(String, int)> totals) {
  final positive = [
    for (final total in totals)
      if (total.$2 > 0) total,
  ];
  // List.sort is not stable; sort on index too so ties keep their order.
  final indexed = positive.indexed.toList()
    ..sort((a, b) {
      final byAmount = b.$2.$2.compareTo(a.$2.$2);
      return byAmount != 0 ? byAmount : a.$1.compareTo(b.$1);
    });
  return [for (final (_, total) in indexed) total];
}

int _sum(List<(String, int)> totals) =>
    totals.fold(0, (sum, total) => sum + total.$2);
