/// One category's spending in a period.
typedef CategorySpend = ({String id, String name, int totalMinor});

/// One sentence of the summary at the top of Analysis.
sealed class Insight {
  const Insight();
}

/// A category spent [percent]% more ([up]) or less than the period before.
final class CategoryChange extends Insight {
  const CategoryChange(this.name, this.percent, {required this.up});

  final String name;
  final int percent;
  final bool up;
}

/// A category with spending now and none in the period before.
final class NewCategory extends Insight {
  const NewCategory(this.name, this.totalMinor);

  final String name;
  final int totalMinor;
}

/// A category whose spending moved less than 1% from the period before.
final class SameAsBefore extends Insight {
  const SameAsBefore(this.name);

  final String name;
}

/// A category's spending and its share of the period, when there is no
/// period before to compare with.
final class CategoryShare extends Insight {
  const CategoryShare(this.name, this.totalMinor, this.percent);

  final String name;
  final int totalMinor;
  final int percent;
}

/// The period's day with the most spending.
final class BiggestDay extends Insight {
  const BiggestDay(this.localDate, this.totalMinor);

  final String localDate;
  final int totalMinor;
}

/// The sentences the summary loops through, one per tap. First the most
/// telling one: with spending in [previous] (the period before), the
/// category whose spending moved the most in ringgit; with nothing to
/// compare, or a move that rounds to 0%, [biggestDay]. Then every other
/// category spent on now, biggest first (compared with [previous], or as a
/// share when there is nothing to compare), then [biggestDay]. Empty when
/// [current] has no spending.
List<Insight> insightLoop({
  required List<CategorySpend> current,
  List<CategorySpend>? previous,
  ({String localDate, int totalMinor})? biggestDay,
}) {
  final total = _sum(current);
  if (total <= 0) return const [];
  final day = biggestDay == null
      ? null
      : BiggestDay(biggestDay.localDate, biggestDay.totalMinor);
  final comparable = previous != null && _sum(previous) > 0;
  final now = {for (final c in current) c.id: c};
  final before = {for (final c in previous ?? const <CategorySpend>[]) c.id: c};

  final moved = comparable ? _mostMoved(now, before) : null;
  final first = moved == null ? day : _compare(moved, now, before);
  final spent = current.where((c) => c.totalMinor > 0).toList()
    ..sort((a, b) => _byRank(a, b, now));
  return [
    if (first != null) first,
    for (final spend in spent)
      if (spend.id != moved?.id)
        comparable
            ? _compare(spend, now, before)
            : CategoryShare(
                spend.name,
                spend.totalMinor,
                (spend.totalMinor * 100 / total).round(),
              ),
    if (day != null && first is! BiggestDay) day,
  ];
}

/// The category whose spending moved the most in ringgit, or null when
/// nothing moved by at least 1%. Ties go to the bigger spender now, then by
/// name, so the sentence is stable.
CategorySpend? _mostMoved(
  Map<String, CategorySpend> now,
  Map<String, CategorySpend> before,
) {
  CategorySpend? best;
  var bestChange = 0;
  for (final id in {...now.keys, ...before.keys}) {
    final change = (now[id]?.totalMinor ?? 0) - (before[id]?.totalMinor ?? 0);
    final candidate = now[id] ?? before[id]!;
    final wins =
        change.abs() > bestChange.abs() ||
        (best != null &&
            change.abs() == bestChange.abs() &&
            _byRank(candidate, best, now) < 0);
    if (wins) {
      best = candidate;
      bestChange = change;
    }
  }
  if (best == null || _compare(best, now, before) is SameAsBefore) return null;
  return best;
}

/// [spend]'s category now against the period before.
Insight _compare(
  CategorySpend spend,
  Map<String, CategorySpend> now,
  Map<String, CategorySpend> before,
) {
  final nowMinor = now[spend.id]?.totalMinor ?? 0;
  final was = before[spend.id]?.totalMinor ?? 0;
  if (was == 0) return NewCategory(spend.name, nowMinor);
  final change = nowMinor - was;
  final percent = (change.abs() * 100 / was).round();
  if (percent == 0) return SameAsBefore(spend.name);
  return CategoryChange(spend.name, percent, up: change > 0);
}

int _sum(List<CategorySpend> spends) =>
    spends.fold(0, (sum, spend) => sum + spend.totalMinor);

/// Orders the bigger spender now first, then by name.
int _byRank(CategorySpend a, CategorySpend b, Map<String, CategorySpend> now) {
  final byTotal = (now[b.id]?.totalMinor ?? 0).compareTo(
    now[a.id]?.totalMinor ?? 0,
  );
  return byTotal != 0 ? byTotal : a.name.compareTo(b.name);
}
