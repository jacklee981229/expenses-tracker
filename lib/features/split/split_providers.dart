import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/split_settle.dart';
import '../../data/data_providers.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/split_dao.dart';
import '../../shared/widgets/colour_field.dart';
import '../categories/categories_providers.dart';

/// Every group, newest first, archived ones included.
final splitGroupsProvider = StreamProvider<List<SplitGroup>>(
  (ref) => ref.watch(splitDaoProvider).watchGroups(),
);

/// Each group's people, total and top category, for the Books list.
final splitGroupSizesProvider = StreamProvider<Map<String, SplitGroupSize>>(
  (ref) => ref.watch(splitDaoProvider).watchGroupSizes(),
);

/// One group, or null once it is deleted.
final splitGroupProvider = Provider.autoDispose.family<SplitGroup?, String>(
  (ref, id) => ref
      .watch(splitGroupsProvider)
      .valueOrNull
      ?.where((g) => g.id == id)
      .firstOrNull,
);

/// A group's people in its order: Jack first.
final splitPeopleProvider = StreamProvider.autoDispose
    .family<List<SplitPerson>, String>(
      (ref, groupId) => ref.watch(splitDaoProvider).watchPeople(groupId),
    );

final _splitEntriesProvider = StreamProvider.autoDispose
    .family<List<SplitEntryWithShares>, String>(
      (ref, groupId) => ref.watch(splitDaoProvider).watchEntries(groupId),
    );

/// Names from earlier groups for a new group's chips.
final earlierNamesProvider = FutureProvider.autoDispose<List<String>>(
  (ref) => ref.watch(splitDaoProvider).earlierNames(),
);

/// Jack's name for a new group: the one he had in the newest group.
final meNameProvider = FutureProvider.autoDispose<String>(
  (ref) async =>
      await ref.watch(splitDaoProvider).lastMeName() ??
      AppStrings.meDefaultName,
);

/// One of a group's entries with its category.
@immutable
class SplitItem {
  const SplitItem(this.saved, this.category);

  final SplitEntryWithShares saved;
  final ExpenseCategory category;

  SplitEntry get entry => saved.entry;
}

/// One day of a group's entries, newest first, with the day's total.
@immutable
class SplitDay {
  SplitDay(this.localDate, this.items)
    : date = parseLocalDate(localDate),
      totalMinor = items.fold(0, (sum, item) => sum + item.entry.amountMinor);

  final String localDate;
  final DateTime date;
  final List<SplitItem> items;
  final int totalMinor;
}

/// Everything a group's page shows: its people, its days, what was spent,
/// who pays whom, and the colour field of its categories.
@immutable
class SplitSummary {
  const SplitSummary({
    required this.people,
    required this.days,
    required this.totalMinor,
    required this.balances,
    required this.payments,
    required this.field,
    required this.entryCount,
  });

  final List<SplitPerson> people;
  final List<SplitDay> days;
  final int totalMinor;
  final int entryCount;

  /// By person id: paid minus share; positive is owed.
  final Map<String, int> balances;
  final List<SplitPayment> payments;
  final List<FieldSpot> field;

  SplitPerson person(String id) => people.firstWhere((p) => p.id == id);

  /// `7–9 Nov 2026`, from the first day to the last; null with no entries.
  String? get dayRange => days.isEmpty
      ? null
      : formatDateRange(days.last.localDate, days.first.localDate);
}

final splitSummaryProvider = Provider.autoDispose
    .family<AsyncValue<SplitSummary>, String>((ref, groupId) {
      final people = ref.watch(splitPeopleProvider(groupId));
      final entries = ref.watch(_splitEntriesProvider(groupId));
      final categories = ref.watch(allCategoriesProvider);
      if (people.hasError) {
        return AsyncError(people.error!, people.stackTrace!);
      }
      if (entries.hasError) {
        return AsyncError(entries.error!, entries.stackTrace!);
      }
      final peopleList = people.valueOrNull;
      final entryList = entries.valueOrNull;
      final categoryList = categories.valueOrNull;
      if (peopleList == null || entryList == null || categoryList == null) {
        return const AsyncLoading();
      }
      final byId = {for (final c in categoryList) c.id: c};
      final items = [
        for (final saved in entryList)
          if (byId[saved.entry.categoryId] case final category?)
            SplitItem(saved, category),
      ];
      final byDay = <String, List<SplitItem>>{};
      for (final item in items) {
        byDay.putIfAbsent(item.entry.localDate, () => []).add(item);
      }
      final order = [for (final p in peopleList) p.id];
      final balances = splitBalances(order, [
        for (final saved in entryList)
          (
            payer: saved.entry.payerId,
            amount: saved.entry.amountMinor,
            shares: saved.shares,
          ),
      ]);
      final byCategory = <String, int>{};
      for (final item in items) {
        byCategory.update(
          item.category.id,
          (sum) => sum + item.entry.amountMinor,
          ifAbsent: () => item.entry.amountMinor,
        );
      }
      final totals = byCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return AsyncData(
        SplitSummary(
          people: peopleList,
          days: [
            for (final MapEntry(:key, :value) in byDay.entries)
              SplitDay(key, value),
          ],
          totalMinor: entryList.fold(0, (s, e) => s + e.entry.amountMinor),
          entryCount: entryList.length,
          balances: balances,
          payments: whoPaysWhom(order, balances),
          field: fieldSpots([for (final t in totals) (byId[t.key]!, t.value)]),
        ),
      );
    });

final splitActionsProvider = Provider<SplitActions>(
  (ref) => SplitActions(ref.watch(splitDaoProvider)),
);

/// What the split screens change, so widgets never reach the DAO.
class SplitActions {
  const SplitActions(this._dao);

  final SplitDao _dao;

  Future<String> createGroup({
    required String name,
    required String meName,
    required List<String> others,
  }) => _dao.createGroup(name: name, meName: meName, others: others);

  Future<void> renameGroup(String id, String name) =>
      _dao.renameGroup(id, name);

  Future<void> setArchived(String id, {required bool archived}) =>
      _dao.setArchived(id, archived: archived);

  Future<void> deleteGroup(String id) => _dao.deleteGroup(id);

  Future<String> addPerson(String groupId, String name) =>
      _dao.addPerson(groupId, name);

  Future<void> renamePerson(String id, String name) =>
      _dao.renamePerson(id, name);

  /// Whether they were removed: not Jack, and on no entry.
  Future<bool> removePerson(String id) => _dao.removePerson(id);

  /// Saves an entry split equally among [sharerIds] (in the group's
  /// order); with an [id], replaces that entry.
  Future<String> saveEntry({
    String? id,
    required String groupId,
    required int amountMinor,
    required String categoryId,
    required DateTime occurredAt,
    String? note,
    required String payerId,
    required List<String> sharerIds,
  }) => _dao.saveEntry(
    id: id,
    groupId: groupId,
    amountMinor: amountMinor,
    categoryId: categoryId,
    occurredAt: occurredAt,
    note: note,
    payerId: payerId,
    shares: equalShares(
      amount: amountMinor,
      payer: payerId,
      sharers: sharerIds,
    ),
  );

  Future<void> deleteEntry(String id) => _dao.deleteEntry(id);

  Future<void> restoreEntry(SplitEntryWithShares saved) =>
      _dao.restoreEntry(saved);
}
