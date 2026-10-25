// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_dao.dart';

// ignore_for_file: type=lint
mixin _$AnalysisDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $RecurringRulesTable get recurringRules => attachedDatabase.recurringRules;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  AnalysisDaoManager get managers => AnalysisDaoManager(this);
}

class AnalysisDaoManager {
  final _$AnalysisDaoMixin _db;
  AnalysisDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$RecurringRulesTableTableManager get recurringRules =>
      $$RecurringRulesTableTableManager(
        _db.attachedDatabase,
        _db.recurringRules,
      );
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
}
