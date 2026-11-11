// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_dao.dart';

// ignore_for_file: type=lint
mixin _$CategoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $RecurringRulesTable get recurringRules => attachedDatabase.recurringRules;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  $SplitGroupsTable get splitGroups => attachedDatabase.splitGroups;
  $SplitPeopleTable get splitPeople => attachedDatabase.splitPeople;
  $SplitEntriesTable get splitEntries => attachedDatabase.splitEntries;
  CategoryDaoManager get managers => CategoryDaoManager(this);
}

class CategoryDaoManager {
  final _$CategoryDaoMixin _db;
  CategoryDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$RecurringRulesTableTableManager get recurringRules =>
      $$RecurringRulesTableTableManager(
        _db.attachedDatabase,
        _db.recurringRules,
      );
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
  $$SplitGroupsTableTableManager get splitGroups =>
      $$SplitGroupsTableTableManager(_db.attachedDatabase, _db.splitGroups);
  $$SplitPeopleTableTableManager get splitPeople =>
      $$SplitPeopleTableTableManager(_db.attachedDatabase, _db.splitPeople);
  $$SplitEntriesTableTableManager get splitEntries =>
      $$SplitEntriesTableTableManager(_db.attachedDatabase, _db.splitEntries);
}
