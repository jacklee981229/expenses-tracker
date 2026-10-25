import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_providers.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/category_dao.dart';

/// Active categories in display order.
final activeCategoriesProvider = StreamProvider<List<ExpenseCategory>>(
  (ref) => ref.watch(categoryDaoProvider).watchActive(),
);

/// Every category, archived ones included (to label old expenses and filters).
final allCategoriesProvider = StreamProvider<List<ExpenseCategory>>(
  (ref) => ref.watch(categoryDaoProvider).watchAll(),
);

final archivedCategoriesProvider = StreamProvider<List<ExpenseCategory>>(
  (ref) => ref.watch(categoryDaoProvider).watchArchived(),
);

/// Expenses plus fixed monthly rules using a category. Zero means it may be
/// deleted; anything else means archive only.
final categoryUsageProvider = FutureProvider.autoDispose.family<int, String>(
  (ref, id) => ref.watch(categoryDaoProvider).usageCount(id),
);

final categoryActionsProvider = Provider<CategoryActions>(
  (ref) => CategoryActions(ref.watch(categoryDaoProvider)),
);

class CategoryActions {
  const CategoryActions(this._dao);

  final CategoryDao _dao;

  /// Returns the new category's id.
  Future<String> create({
    required String name,
    required String iconKey,
    required String colorHex,
  }) => _dao.insertCategory(
    name: name.trim(),
    iconKey: iconKey,
    colorHex: colorHex,
  );

  Future<void> update({
    required String id,
    required String name,
    required String iconKey,
    required String colorHex,
  }) => _dao.updateCategory(
    id: id,
    name: name.trim(),
    iconKey: iconKey,
    colorHex: colorHex,
  );

  Future<void> archive(String id) => _dao.archive(id);

  Future<void> restore(String id) => _dao.restore(id);

  Future<void> reorder(List<String> orderedIds) => _dao.reorder(orderedIds);

  /// Only for categories with zero usage; the foreign key rejects the rest.
  Future<void> delete(String id) => _dao.deleteCategory(id);
}
