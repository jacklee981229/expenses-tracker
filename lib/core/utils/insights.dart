import '../constants/strings.dart';
import 'money.dart';

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

/// Where a running month's spending is heading ([projectMonth]).
final class Projection extends Insight {
  const Projection(this.totalMinor);

  final int totalMinor;
}

/// The month's day from which it is projected: the first days' spending
/// says too little about the pace.
const int kProjectionFromDay = 3;

/// The month's spending by its last day if everyday spending carries on at
/// its pace over [daysSoFar] of [monthDays]. [fixedMinor], the fixed
/// expenses, counts once: a month's are all added on its first day. Null
/// before day [kProjectionFromDay], on or after the last day, or with
/// nothing spent.
int? projectMonth({
  required int totalMinor,
  required int fixedMinor,
  required int daysSoFar,
  required int monthDays,
}) {
  if (totalMinor <= 0 ||
      daysSoFar < kProjectionFromDay ||
      daysSoFar >= monthDays) {
    return null;
  }
  final everyday = totalMinor - fixedMinor;
  return fixedMinor + averageMinor(everyday * monthDays, daysSoFar);
}

/// The sentences the summary loops through, one per tap. First the most
/// telling one: with spending in [previous] (the period before), the
/// category whose spending moved the most in ringgit; with nothing to
/// compare, or a move that rounds to 0%, [biggestDay]. Then every other
/// category spent on now, biggest first (compared with [previous], or as a
/// share when there is nothing to compare), then [biggestDay]. A
/// [projectedMinor] goes before them all. Empty when [current] has no
/// spending.
List<Insight> insightLoop({
  required List<CategorySpend> current,
  List<CategorySpend>? previous,
  ({String localDate, int totalMinor})? biggestDay,
  int? projectedMinor,
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
    if (projectedMinor != null) Projection(projectedMinor),
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
  final change = changePercent(nowMinor, before[spend.id]?.totalMinor ?? 0);
  if (change == null) return NewCategory(spend.name, nowMinor);
  if (change == 0) return SameAsBefore(spend.name);
  return CategoryChange(spend.name, change.abs(), up: change > 0);
}

/// Which way a category's spending went against the period before.
enum ChangeKind { up, down, same, fresh }

/// A category's change as its sticker shows it: [deltaMinor] signed, and
/// [percent] as [changePercent] gives it (null for [ChangeKind.fresh]).
typedef SpendChange = ({ChangeKind kind, int deltaMinor, int? percent});

/// [now] against [was], judged as the summary line judges it: new with
/// nothing before, the same when the change rounds to 0%.
SpendChange spendChange(int now, int was) {
  final percent = changePercent(now, was);
  final kind = switch (percent) {
    null => ChangeKind.fresh,
    0 => ChangeKind.same,
    > 0 => ChangeKind.up,
    _ => ChangeKind.down,
  };
  return (kind: kind, deltaMinor: now - was, percent: percent);
}

/// A sticker's words for [change], in percent or in ringgit: `▲RM45`,
/// `▼12%`, `New`; the same is `= RM0`, or `≈ RM3.50` for a move too small
/// to reach 1%, and `0%`.
String changeLabel(SpendChange change, {required bool percent}) {
  final figure = percent
      ? AppStrings.changePercent(change.percent?.abs() ?? 0)
      : formatShortWithSymbol(change.deltaMinor);
  return switch (change.kind) {
    ChangeKind.fresh => AppStrings.changeNew,
    ChangeKind.same when percent => figure,
    ChangeKind.same when change.deltaMinor == 0 => AppStrings.changeSame(
      figure,
    ),
    ChangeKind.same => AppStrings.changeAbout(figure),
    ChangeKind.up => AppStrings.changeUp(figure),
    ChangeKind.down => AppStrings.changeDown(figure),
  };
}

/// [now] against [was] in whole percent, signed (+ more, - less); null when
/// [was] is zero, so there is nothing to compare with.
int? changePercent(int now, int was) {
  if (was == 0) return null;
  final percent = ((now - was).abs() * 100 / was).round();
  return now < was ? -percent : percent;
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
