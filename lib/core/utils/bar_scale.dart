/// How tall a row of spending bars scales to, so that one big day (or week,
/// or month) doesn't flatten the rest into stubs.
library;

/// A bar may reach this many times the median before the row caps.
const int kBarCapFactor = 2;

/// The fewest bars with spending for a median to mean anything.
const int kBarCapMinBars = 3;

/// The amount that fills a bar's whole height: the biggest of [totals], or
/// [kBarCapFactor] × the median of the bars with spending when the biggest
/// is above that and at least [kBarCapMinBars] bars have spending. Bars
/// above the result are capped: they fill the height. 0 when nothing was
/// spent. The median of an even count is the mean of the middle two.
int barScale(List<int> totals) {
  final spent = [
    for (final total in totals)
      if (total > 0) total,
  ]..sort();
  if (spent.isEmpty) return 0;
  final biggest = spent.last;
  if (spent.length < kBarCapMinBars) return biggest;
  final middle = spent.length ~/ 2;
  // Twice the median, kept in whole sen: for an even count twice the mean
  // of the middle two is their sum.
  final twiceMedian = spent.length.isOdd
      ? 2 * spent[middle]
      : spent[middle - 1] + spent[middle];
  final cap = twiceMedian * kBarCapFactor ~/ 2;
  return biggest > cap ? cap : biggest;
}
