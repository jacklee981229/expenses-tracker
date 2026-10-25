import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../seed/default_categories.dart';
import '../tables/categories_table.dart';
import '../tables/recurring_rules_table.dart';
import '../tables/transactions_table.dart';

part 'category_dao.g.dart';

const Uuid _uuid = Uuid();

@DriftAccessor(tables: [Categories, Transactions, RecurringRules])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.attachedDatabase);

  SimpleSelectStatement<$CategoriesTable, ExpenseCategory> _ordered() =>
      select(categories)..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]);

  Stream<List<ExpenseCategory>> watchActive() =>
      (_ordered()..where((c) => c.isArchived.equals(false))).watch();

  Stream<List<ExpenseCategory>> watchArchived() =>
      (_ordered()..where((c) => c.isArchived.equals(true))).watch();

  Stream<List<ExpenseCategory>> watchAll() => _ordered().watch();

  Future<List<ExpenseCategory>> getAll() => _ordered().get();

  Future<ExpenseCategory?> findById(String id) =>
      (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> countAll() async {
    final count = categories.id.count();
    final row = await (selectOnly(categories)..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  /// Inserts the default categories when the table is empty.
  Future<void> seedDefaultsIfEmpty() async {
    if (await countAll() > 0) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    await batch((batch) {
      batch.insertAll(categories, [
        for (final (index, seed) in kDefaultCategories.indexed)
          CategoriesCompanion.insert(
            id: _uuid.v4(),
            name: seed.name,
            iconKey: seed.iconKey,
            colorHex: seed.colorHex,
            sortOrder: index,
            isDefault: const Value(true),
            createdAt: now,
          ),
      ]);
    });
  }

  /// Adds a category at the end of the list and returns its id.
  Future<String> insertCategory({
    required String name,
    required String iconKey,
    required String colorHex,
  }) {
    return transaction(() async {
      final id = _uuid.v4();
      await into(categories).insert(
        CategoriesCompanion.insert(
          id: id,
          name: name,
          iconKey: iconKey,
          colorHex: colorHex,
          sortOrder: await _nextSortOrder(),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      return id;
    });
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required String iconKey,
    required String colorHex,
  }) async {
    await (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        name: Value(name),
        iconKey: Value(iconKey),
        colorHex: Value(colorHex),
      ),
    );
  }

  Future<void> archive(String id) async {
    await (update(categories)..where((c) => c.id.equals(id))).write(
      const CategoriesCompanion(isArchived: Value(true)),
    );
  }

  /// Restored categories go to the end of the active list.
  Future<void> restore(String id) {
    return transaction(() async {
      final sortOrder = await _nextSortOrder();
      await (update(categories)..where((c) => c.id.equals(id))).write(
        CategoriesCompanion(
          isArchived: const Value(false),
          sortOrder: Value(sortOrder),
        ),
      );
    });
  }

  /// Sets `sortOrder` to each id's position in [orderedIds].
  Future<void> reorder(List<String> orderedIds) {
    return transaction(() async {
      for (final (index, id) in orderedIds.indexed) {
        await (update(categories)..where((c) => c.id.equals(id))).write(
          CategoriesCompanion(sortOrder: Value(index)),
        );
      }
    });
  }

  /// Expenses plus fixed monthly rules that reference the category. Only a
  /// category with no usage may be deleted; otherwise it can only be archived.
  Future<int> usageCount(String id) async {
    final expenses = transactions.id.count();
    final expenseRow =
        await (selectOnly(transactions)
              ..addColumns([expenses])
              ..where(transactions.categoryId.equals(id)))
            .getSingle();
    final rules = recurringRules.id.count();
    final ruleRow =
        await (selectOnly(recurringRules)
              ..addColumns([rules])
              ..where(recurringRules.categoryId.equals(id)))
            .getSingle();
    return (expenseRow.read(expenses) ?? 0) + (ruleRow.read(rules) ?? 0);
  }

  Future<void> deleteCategory(String id) async {
    await (delete(categories)..where((c) => c.id.equals(id))).go();
  }

  /// Backup import. With [skipExisting], rows whose id is already present
  /// are left alone (merge); otherwise a clash is an error.
  Future<void> importRows(
    List<ExpenseCategory> rows, {
    required bool skipExisting,
  }) async {
    await batch(
      (batch) => batch.insertAll(
        categories,
        rows,
        mode: skipExisting ? InsertMode.insertOrIgnore : InsertMode.insert,
      ),
    );
  }

  /// Backup import (replace). Expenses and rules must be deleted first.
  Future<void> deleteAll() async {
    await delete(categories).go();
  }

  Future<int> _nextSortOrder() async {
    final max = categories.sortOrder.max();
    final row = await (selectOnly(categories)..addColumns([max])).getSingle();
    return (row.read(max) ?? -1) + 1;
  }
}
