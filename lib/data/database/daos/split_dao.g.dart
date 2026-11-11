// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_dao.dart';

// ignore_for_file: type=lint
mixin _$SplitDaoMixin on DatabaseAccessor<AppDatabase> {
  $SplitGroupsTable get splitGroups => attachedDatabase.splitGroups;
  $SplitPeopleTable get splitPeople => attachedDatabase.splitPeople;
  $CategoriesTable get categories => attachedDatabase.categories;
  $SplitEntriesTable get splitEntries => attachedDatabase.splitEntries;
  $SplitSharesTable get splitShares => attachedDatabase.splitShares;
  SplitDaoManager get managers => SplitDaoManager(this);
}

class SplitDaoManager {
  final _$SplitDaoMixin _db;
  SplitDaoManager(this._db);
  $$SplitGroupsTableTableManager get splitGroups =>
      $$SplitGroupsTableTableManager(_db.attachedDatabase, _db.splitGroups);
  $$SplitPeopleTableTableManager get splitPeople =>
      $$SplitPeopleTableTableManager(_db.attachedDatabase, _db.splitPeople);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$SplitEntriesTableTableManager get splitEntries =>
      $$SplitEntriesTableTableManager(_db.attachedDatabase, _db.splitEntries);
  $$SplitSharesTableTableManager get splitShares =>
      $$SplitSharesTableTableManager(_db.attachedDatabase, _db.splitShares);
}
