/// Splitting a group's expenses: equal shares in sen, each person's
/// balance, and who pays whom to settle it.
library;

/// One payment that settles part of a group: [from] gives [to] [amount]
/// sen.
class SplitPayment {
  const SplitPayment({
    required this.from,
    required this.to,
    required this.amount,
  });

  final String from;
  final String to;
  final int amount;

  @override
  bool operator ==(Object other) =>
      other is SplitPayment &&
      other.from == from &&
      other.to == to &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(from, to, amount);

  @override
  String toString() => '$from → $to $amount';
}

/// [amount] sen split equally among [sharers] (people ids, in the group's
/// order): each gets the amount ÷ sharers rounded down, and the sen left
/// over go one each to the [payer] first, if sharing, then in the group's
/// order, so the shares always add up to [amount]. Keys keep the order of
/// [sharers].
Map<String, int> equalShares({
  required int amount,
  required String payer,
  required List<String> sharers,
}) {
  assert(sharers.isNotEmpty, 'an expense needs someone to share it');
  final base = amount ~/ sharers.length;
  var leftover = amount - base * sharers.length;
  final shares = {for (final id in sharers) id: base};
  final order = [
    if (shares.containsKey(payer)) payer,
    for (final id in sharers)
      if (id != payer) id,
  ];
  for (final id in order) {
    if (leftover == 0) break;
    shares[id] = shares[id]! + 1;
    leftover--;
  }
  return shares;
}

/// Each of [people]'s balance over [entries]: what they paid minus their
/// shares. Positive means they are owed. The balances add up to zero when
/// every entry's shares add up to its amount.
Map<String, int> splitBalances(
  List<String> people,
  Iterable<({String payer, int amount, Map<String, int> shares})> entries,
) {
  final balances = {for (final id in people) id: 0};
  for (final entry in entries) {
    balances[entry.payer] = (balances[entry.payer] ?? 0) + entry.amount;
    entry.shares.forEach((id, share) {
      balances[id] = (balances[id] ?? 0) - share;
    });
  }
  return balances;
}

/// The payments that bring [balances] to zero: the person who owes most
/// pays the one owed most, as much as either needs, until no one owes.
/// At most one payment fewer than the people with a balance. Ties go by
/// [people]'s order, so the same balances give the same list every time.
List<SplitPayment> whoPaysWhom(List<String> people, Map<String, int> balances) {
  final left = {for (final id in people) id: balances[id] ?? 0};
  final payments = <SplitPayment>[];
  // Biggest by size; the earlier in the group wins a tie.
  String? biggest(bool owed) {
    String? pick;
    for (final id in people) {
      final value = owed ? left[id]! : -left[id]!;
      if (value <= 0) continue;
      final best = pick == null ? 0 : (owed ? left[pick]! : -left[pick]!);
      if (value > best) pick = id;
    }
    return pick;
  }

  while (true) {
    final debtor = biggest(false);
    final creditor = biggest(true);
    if (debtor == null || creditor == null) break;
    final owes = -left[debtor]!;
    final owed = left[creditor]!;
    final amount = owes < owed ? owes : owed;
    payments.add(SplitPayment(from: debtor, to: creditor, amount: amount));
    left[debtor] = left[debtor]! + amount;
    left[creditor] = left[creditor]! - amount;
  }
  return payments;
}
