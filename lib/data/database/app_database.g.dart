// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, ExpenseCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconKey,
    colorHex,
    sortOrder,
    isArchived,
    isDefault,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_iconKeyMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class ExpenseCategory extends DataClass implements Insertable<ExpenseCategory> {
  final String id;
  final String name;

  /// Key into `kIconRegistry`.
  final String iconKey;

  /// `RRGGBB`, no `#`.
  final String colorHex;
  final int sortOrder;
  final bool isArchived;
  final bool isDefault;

  /// Epoch milliseconds.
  final int createdAt;
  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorHex,
    required this.sortOrder,
    required this.isArchived,
    required this.isDefault,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_key'] = Variable<String>(iconKey);
    map['color_hex'] = Variable<String>(colorHex);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_archived'] = Variable<bool>(isArchived);
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      iconKey: Value(iconKey),
      colorHex: Value(colorHex),
      sortOrder: Value(sortOrder),
      isArchived: Value(isArchived),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
    );
  }

  factory ExpenseCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseCategory(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconKey': serializer.toJson<String>(iconKey),
      'colorHex': serializer.toJson<String>(colorHex),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isArchived': serializer.toJson<bool>(isArchived),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ExpenseCategory copyWith({
    String? id,
    String? name,
    String? iconKey,
    String? colorHex,
    int? sortOrder,
    bool? isArchived,
    bool? isDefault,
    int? createdAt,
  }) => ExpenseCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    iconKey: iconKey ?? this.iconKey,
    colorHex: colorHex ?? this.colorHex,
    sortOrder: sortOrder ?? this.sortOrder,
    isArchived: isArchived ?? this.isArchived,
    isDefault: isDefault ?? this.isDefault,
    createdAt: createdAt ?? this.createdAt,
  );
  ExpenseCategory copyWithCompanion(CategoriesCompanion data) {
    return ExpenseCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    iconKey,
    colorHex,
    sortOrder,
    isArchived,
    isDefault,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconKey == this.iconKey &&
          other.colorHex == this.colorHex &&
          other.sortOrder == this.sortOrder &&
          other.isArchived == this.isArchived &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<ExpenseCategory> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> iconKey;
  final Value<String> colorHex;
  final Value<int> sortOrder;
  final Value<bool> isArchived;
  final Value<bool> isDefault;
  final Value<int> createdAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required String iconKey,
    required String colorHex,
    required int sortOrder,
    this.isArchived = const Value.absent(),
    this.isDefault = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       iconKey = Value(iconKey),
       colorHex = Value(colorHex),
       sortOrder = Value(sortOrder),
       createdAt = Value(createdAt);
  static Insertable<ExpenseCategory> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? iconKey,
    Expression<String>? colorHex,
    Expression<int>? sortOrder,
    Expression<bool>? isArchived,
    Expression<bool>? isDefault,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconKey != null) 'icon_key': iconKey,
      if (colorHex != null) 'color_hex': colorHex,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isArchived != null) 'is_archived': isArchived,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? iconKey,
    Value<String>? colorHex,
    Value<int>? sortOrder,
    Value<bool>? isArchived,
    Value<bool>? isDefault,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringRulesTable extends RecurringRules
    with TableInfo<$RecurringRulesTable, RecurringRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayOfMonthMeta = const VerificationMeta(
    'dayOfMonth',
  );
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
    'day_of_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMonthMeta = const VerificationMeta(
    'startMonth',
  );
  @override
  late final GeneratedColumn<String> startMonth = GeneratedColumn<String>(
    'start_month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMonthMeta = const VerificationMeta(
    'endMonth',
  );
  @override
  late final GeneratedColumn<String> endMonth = GeneratedColumn<String>(
    'end_month',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastGeneratedMonthMeta =
      const VerificationMeta('lastGeneratedMonth');
  @override
  late final GeneratedColumn<String> lastGeneratedMonth =
      GeneratedColumn<String>(
        'last_generated_month',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountMinor,
    categoryId,
    note,
    dayOfMonth,
    startMonth,
    endMonth,
    isActive,
    lastGeneratedMonth,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
        _dayOfMonthMeta,
        dayOfMonth.isAcceptableOrUnknown(
          data['day_of_month']!,
          _dayOfMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayOfMonthMeta);
    }
    if (data.containsKey('start_month')) {
      context.handle(
        _startMonthMeta,
        startMonth.isAcceptableOrUnknown(data['start_month']!, _startMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_startMonthMeta);
    }
    if (data.containsKey('end_month')) {
      context.handle(
        _endMonthMeta,
        endMonth.isAcceptableOrUnknown(data['end_month']!, _endMonthMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('last_generated_month')) {
      context.handle(
        _lastGeneratedMonthMeta,
        lastGeneratedMonth.isAcceptableOrUnknown(
          data['last_generated_month']!,
          _lastGeneratedMonthMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      dayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_month'],
      )!,
      startMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_month'],
      )!,
      endMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_month'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      lastGeneratedMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_generated_month'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RecurringRulesTable createAlias(String alias) {
    return $RecurringRulesTable(attachedDatabase, alias);
  }
}

class RecurringRule extends DataClass implements Insertable<RecurringRule> {
  final String id;
  final int amountMinor;
  final String categoryId;
  final String? note;

  /// 1–31. Clamped to the month's last day when generating.
  final int dayOfMonth;

  /// `YYYY-MM`.
  final String startMonth;

  /// `YYYY-MM`, null = open-ended.
  final String? endMonth;
  final bool isActive;

  /// `YYYY-MM`. The sole idempotency guard for generation.
  final String? lastGeneratedMonth;
  final int createdAt;
  const RecurringRule({
    required this.id,
    required this.amountMinor,
    required this.categoryId,
    this.note,
    required this.dayOfMonth,
    required this.startMonth,
    this.endMonth,
    required this.isActive,
    this.lastGeneratedMonth,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['day_of_month'] = Variable<int>(dayOfMonth);
    map['start_month'] = Variable<String>(startMonth);
    if (!nullToAbsent || endMonth != null) {
      map['end_month'] = Variable<String>(endMonth);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastGeneratedMonth != null) {
      map['last_generated_month'] = Variable<String>(lastGeneratedMonth);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  RecurringRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurringRulesCompanion(
      id: Value(id),
      amountMinor: Value(amountMinor),
      categoryId: Value(categoryId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      dayOfMonth: Value(dayOfMonth),
      startMonth: Value(startMonth),
      endMonth: endMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(endMonth),
      isActive: Value(isActive),
      lastGeneratedMonth: lastGeneratedMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(lastGeneratedMonth),
      createdAt: Value(createdAt),
    );
  }

  factory RecurringRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringRule(
      id: serializer.fromJson<String>(json['id']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      note: serializer.fromJson<String?>(json['note']),
      dayOfMonth: serializer.fromJson<int>(json['dayOfMonth']),
      startMonth: serializer.fromJson<String>(json['startMonth']),
      endMonth: serializer.fromJson<String?>(json['endMonth']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastGeneratedMonth: serializer.fromJson<String?>(
        json['lastGeneratedMonth'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'categoryId': serializer.toJson<String>(categoryId),
      'note': serializer.toJson<String?>(note),
      'dayOfMonth': serializer.toJson<int>(dayOfMonth),
      'startMonth': serializer.toJson<String>(startMonth),
      'endMonth': serializer.toJson<String?>(endMonth),
      'isActive': serializer.toJson<bool>(isActive),
      'lastGeneratedMonth': serializer.toJson<String?>(lastGeneratedMonth),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  RecurringRule copyWith({
    String? id,
    int? amountMinor,
    String? categoryId,
    Value<String?> note = const Value.absent(),
    int? dayOfMonth,
    String? startMonth,
    Value<String?> endMonth = const Value.absent(),
    bool? isActive,
    Value<String?> lastGeneratedMonth = const Value.absent(),
    int? createdAt,
  }) => RecurringRule(
    id: id ?? this.id,
    amountMinor: amountMinor ?? this.amountMinor,
    categoryId: categoryId ?? this.categoryId,
    note: note.present ? note.value : this.note,
    dayOfMonth: dayOfMonth ?? this.dayOfMonth,
    startMonth: startMonth ?? this.startMonth,
    endMonth: endMonth.present ? endMonth.value : this.endMonth,
    isActive: isActive ?? this.isActive,
    lastGeneratedMonth: lastGeneratedMonth.present
        ? lastGeneratedMonth.value
        : this.lastGeneratedMonth,
    createdAt: createdAt ?? this.createdAt,
  );
  RecurringRule copyWithCompanion(RecurringRulesCompanion data) {
    return RecurringRule(
      id: data.id.present ? data.id.value : this.id,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      note: data.note.present ? data.note.value : this.note,
      dayOfMonth: data.dayOfMonth.present
          ? data.dayOfMonth.value
          : this.dayOfMonth,
      startMonth: data.startMonth.present
          ? data.startMonth.value
          : this.startMonth,
      endMonth: data.endMonth.present ? data.endMonth.value : this.endMonth,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastGeneratedMonth: data.lastGeneratedMonth.present
          ? data.lastGeneratedMonth.value
          : this.lastGeneratedMonth,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRule(')
          ..write('id: $id, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('startMonth: $startMonth, ')
          ..write('endMonth: $endMonth, ')
          ..write('isActive: $isActive, ')
          ..write('lastGeneratedMonth: $lastGeneratedMonth, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amountMinor,
    categoryId,
    note,
    dayOfMonth,
    startMonth,
    endMonth,
    isActive,
    lastGeneratedMonth,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringRule &&
          other.id == this.id &&
          other.amountMinor == this.amountMinor &&
          other.categoryId == this.categoryId &&
          other.note == this.note &&
          other.dayOfMonth == this.dayOfMonth &&
          other.startMonth == this.startMonth &&
          other.endMonth == this.endMonth &&
          other.isActive == this.isActive &&
          other.lastGeneratedMonth == this.lastGeneratedMonth &&
          other.createdAt == this.createdAt);
}

class RecurringRulesCompanion extends UpdateCompanion<RecurringRule> {
  final Value<String> id;
  final Value<int> amountMinor;
  final Value<String> categoryId;
  final Value<String?> note;
  final Value<int> dayOfMonth;
  final Value<String> startMonth;
  final Value<String?> endMonth;
  final Value<bool> isActive;
  final Value<String?> lastGeneratedMonth;
  final Value<int> createdAt;
  final Value<int> rowid;
  const RecurringRulesCompanion({
    this.id = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.startMonth = const Value.absent(),
    this.endMonth = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastGeneratedMonth = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringRulesCompanion.insert({
    required String id,
    required int amountMinor,
    required String categoryId,
    this.note = const Value.absent(),
    required int dayOfMonth,
    required String startMonth,
    this.endMonth = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastGeneratedMonth = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amountMinor = Value(amountMinor),
       categoryId = Value(categoryId),
       dayOfMonth = Value(dayOfMonth),
       startMonth = Value(startMonth),
       createdAt = Value(createdAt);
  static Insertable<RecurringRule> custom({
    Expression<String>? id,
    Expression<int>? amountMinor,
    Expression<String>? categoryId,
    Expression<String>? note,
    Expression<int>? dayOfMonth,
    Expression<String>? startMonth,
    Expression<String>? endMonth,
    Expression<bool>? isActive,
    Expression<String>? lastGeneratedMonth,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (categoryId != null) 'category_id': categoryId,
      if (note != null) 'note': note,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (startMonth != null) 'start_month': startMonth,
      if (endMonth != null) 'end_month': endMonth,
      if (isActive != null) 'is_active': isActive,
      if (lastGeneratedMonth != null)
        'last_generated_month': lastGeneratedMonth,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringRulesCompanion copyWith({
    Value<String>? id,
    Value<int>? amountMinor,
    Value<String>? categoryId,
    Value<String?>? note,
    Value<int>? dayOfMonth,
    Value<String>? startMonth,
    Value<String?>? endMonth,
    Value<bool>? isActive,
    Value<String?>? lastGeneratedMonth,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return RecurringRulesCompanion(
      id: id ?? this.id,
      amountMinor: amountMinor ?? this.amountMinor,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      startMonth: startMonth ?? this.startMonth,
      endMonth: endMonth ?? this.endMonth,
      isActive: isActive ?? this.isActive,
      lastGeneratedMonth: lastGeneratedMonth ?? this.lastGeneratedMonth,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (startMonth.present) {
      map['start_month'] = Variable<String>(startMonth.value);
    }
    if (endMonth.present) {
      map['end_month'] = Variable<String>(endMonth.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastGeneratedMonth.present) {
      map['last_generated_month'] = Variable<String>(lastGeneratedMonth.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRulesCompanion(')
          ..write('id: $id, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('startMonth: $startMonth, ')
          ..write('endMonth: $endMonth, ')
          ..write('isActive: $isActive, ')
          ..write('lastGeneratedMonth: $lastGeneratedMonth, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurringRuleIdMeta = const VerificationMeta(
    'recurringRuleId',
  );
  @override
  late final GeneratedColumn<String> recurringRuleId = GeneratedColumn<String>(
    'recurring_rule_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recurring_rules (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountMinor,
    categoryId,
    occurredAt,
    localDate,
    note,
    source,
    recurringRuleId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('recurring_rule_id')) {
      context.handle(
        _recurringRuleIdMeta,
        recurringRuleId.isAcceptableOrUnknown(
          data['recurring_rule_id']!,
          _recurringRuleIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      recurringRuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_rule_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final String id;

  /// Sen. Never a double.
  final int amountMinor;
  final String categoryId;

  /// Epoch milliseconds.
  final int occurredAt;

  /// `YYYY-MM-DD` in device local time, written from [occurredAt] at insert.
  /// All period grouping uses this column, never [occurredAt].
  final String localDate;
  final String? note;

  /// [TransactionSource.manual] or [TransactionSource.recurring].
  final String source;
  final String? recurringRuleId;
  final int createdAt;
  final int updatedAt;
  const Expense({
    required this.id,
    required this.amountMinor,
    required this.categoryId,
    required this.occurredAt,
    required this.localDate,
    this.note,
    required this.source,
    this.recurringRuleId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['category_id'] = Variable<String>(categoryId);
    map['occurred_at'] = Variable<int>(occurredAt);
    map['local_date'] = Variable<String>(localDate);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || recurringRuleId != null) {
      map['recurring_rule_id'] = Variable<String>(recurringRuleId);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      amountMinor: Value(amountMinor),
      categoryId: Value(categoryId),
      occurredAt: Value(occurredAt),
      localDate: Value(localDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      source: Value(source),
      recurringRuleId: recurringRuleId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringRuleId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<String>(json['id']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
      localDate: serializer.fromJson<String>(json['localDate']),
      note: serializer.fromJson<String?>(json['note']),
      source: serializer.fromJson<String>(json['source']),
      recurringRuleId: serializer.fromJson<String?>(json['recurringRuleId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'categoryId': serializer.toJson<String>(categoryId),
      'occurredAt': serializer.toJson<int>(occurredAt),
      'localDate': serializer.toJson<String>(localDate),
      'note': serializer.toJson<String?>(note),
      'source': serializer.toJson<String>(source),
      'recurringRuleId': serializer.toJson<String?>(recurringRuleId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Expense copyWith({
    String? id,
    int? amountMinor,
    String? categoryId,
    int? occurredAt,
    String? localDate,
    Value<String?> note = const Value.absent(),
    String? source,
    Value<String?> recurringRuleId = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => Expense(
    id: id ?? this.id,
    amountMinor: amountMinor ?? this.amountMinor,
    categoryId: categoryId ?? this.categoryId,
    occurredAt: occurredAt ?? this.occurredAt,
    localDate: localDate ?? this.localDate,
    note: note.present ? note.value : this.note,
    source: source ?? this.source,
    recurringRuleId: recurringRuleId.present
        ? recurringRuleId.value
        : this.recurringRuleId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Expense copyWithCompanion(TransactionsCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      note: data.note.present ? data.note.value : this.note,
      source: data.source.present ? data.source.value : this.source,
      recurringRuleId: data.recurringRuleId.present
          ? data.recurringRuleId.value
          : this.recurringRuleId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('categoryId: $categoryId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('localDate: $localDate, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('recurringRuleId: $recurringRuleId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amountMinor,
    categoryId,
    occurredAt,
    localDate,
    note,
    source,
    recurringRuleId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.amountMinor == this.amountMinor &&
          other.categoryId == this.categoryId &&
          other.occurredAt == this.occurredAt &&
          other.localDate == this.localDate &&
          other.note == this.note &&
          other.source == this.source &&
          other.recurringRuleId == this.recurringRuleId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TransactionsCompanion extends UpdateCompanion<Expense> {
  final Value<String> id;
  final Value<int> amountMinor;
  final Value<String> categoryId;
  final Value<int> occurredAt;
  final Value<String> localDate;
  final Value<String?> note;
  final Value<String> source;
  final Value<String?> recurringRuleId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.localDate = const Value.absent(),
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    this.recurringRuleId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required int amountMinor,
    required String categoryId,
    required int occurredAt,
    required String localDate,
    this.note = const Value.absent(),
    required String source,
    this.recurringRuleId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amountMinor = Value(amountMinor),
       categoryId = Value(categoryId),
       occurredAt = Value(occurredAt),
       localDate = Value(localDate),
       source = Value(source),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Expense> custom({
    Expression<String>? id,
    Expression<int>? amountMinor,
    Expression<String>? categoryId,
    Expression<int>? occurredAt,
    Expression<String>? localDate,
    Expression<String>? note,
    Expression<String>? source,
    Expression<String>? recurringRuleId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (categoryId != null) 'category_id': categoryId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (localDate != null) 'local_date': localDate,
      if (note != null) 'note': note,
      if (source != null) 'source': source,
      if (recurringRuleId != null) 'recurring_rule_id': recurringRuleId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<int>? amountMinor,
    Value<String>? categoryId,
    Value<int>? occurredAt,
    Value<String>? localDate,
    Value<String?>? note,
    Value<String>? source,
    Value<String?>? recurringRuleId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      amountMinor: amountMinor ?? this.amountMinor,
      categoryId: categoryId ?? this.categoryId,
      occurredAt: occurredAt ?? this.occurredAt,
      localDate: localDate ?? this.localDate,
      note: note ?? this.note,
      source: source ?? this.source,
      recurringRuleId: recurringRuleId ?? this.recurringRuleId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (recurringRuleId.present) {
      map['recurring_rule_id'] = Variable<String>(recurringRuleId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('categoryId: $categoryId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('localDate: $localDate, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('recurringRuleId: $recurringRuleId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstDayOfWeekMeta = const VerificationMeta(
    'firstDayOfWeek',
  );
  @override
  late final GeneratedColumn<int> firstDayOfWeek = GeneratedColumn<int>(
    'first_day_of_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(ThemeModeSetting.system),
  );
  static const VerificationMeta _lastExportAtMeta = const VerificationMeta(
    'lastExportAt',
  );
  @override
  late final GeneratedColumn<int> lastExportAt = GeneratedColumn<int>(
    'last_export_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalCardFoldedMeta = const VerificationMeta(
    'totalCardFolded',
  );
  @override
  late final GeneratedColumn<bool> totalCardFolded = GeneratedColumn<bool>(
    'total_card_folded',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("total_card_folded" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firstDayOfWeek,
    themeMode,
    lastExportAt,
    totalCardFolded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('first_day_of_week')) {
      context.handle(
        _firstDayOfWeekMeta,
        firstDayOfWeek.isAcceptableOrUnknown(
          data['first_day_of_week']!,
          _firstDayOfWeekMeta,
        ),
      );
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('last_export_at')) {
      context.handle(
        _lastExportAtMeta,
        lastExportAt.isAcceptableOrUnknown(
          data['last_export_at']!,
          _lastExportAtMeta,
        ),
      );
    }
    if (data.containsKey('total_card_folded')) {
      context.handle(
        _totalCardFoldedMeta,
        totalCardFolded.isAcceptableOrUnknown(
          data['total_card_folded']!,
          _totalCardFoldedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      firstDayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_day_of_week'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      lastExportAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_export_at'],
      ),
      totalCardFolded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}total_card_folded'],
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingsData extends DataClass implements Insertable<AppSettingsData> {
  final int id;

  /// ISO weekday: 1 = Monday ... 7 = Sunday.
  final int firstDayOfWeek;

  /// Appearance: one of [ThemeModeSetting].
  final String themeMode;

  /// Epoch milliseconds of the last successful export.
  final int? lastExportAt;

  /// Whether the ledger's total card is folded down to the month's total.
  /// Nullable, null meaning open, because a backup made before it has no
  /// such field and `fromJson` would refuse a missing non-null one.
  final bool? totalCardFolded;
  const AppSettingsData({
    required this.id,
    required this.firstDayOfWeek,
    required this.themeMode,
    this.lastExportAt,
    this.totalCardFolded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['first_day_of_week'] = Variable<int>(firstDayOfWeek);
    map['theme_mode'] = Variable<String>(themeMode);
    if (!nullToAbsent || lastExportAt != null) {
      map['last_export_at'] = Variable<int>(lastExportAt);
    }
    if (!nullToAbsent || totalCardFolded != null) {
      map['total_card_folded'] = Variable<bool>(totalCardFolded);
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      firstDayOfWeek: Value(firstDayOfWeek),
      themeMode: Value(themeMode),
      lastExportAt: lastExportAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastExportAt),
      totalCardFolded: totalCardFolded == null && nullToAbsent
          ? const Value.absent()
          : Value(totalCardFolded),
    );
  }

  factory AppSettingsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsData(
      id: serializer.fromJson<int>(json['id']),
      firstDayOfWeek: serializer.fromJson<int>(json['firstDayOfWeek']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      lastExportAt: serializer.fromJson<int?>(json['lastExportAt']),
      totalCardFolded: serializer.fromJson<bool?>(json['totalCardFolded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'firstDayOfWeek': serializer.toJson<int>(firstDayOfWeek),
      'themeMode': serializer.toJson<String>(themeMode),
      'lastExportAt': serializer.toJson<int?>(lastExportAt),
      'totalCardFolded': serializer.toJson<bool?>(totalCardFolded),
    };
  }

  AppSettingsData copyWith({
    int? id,
    int? firstDayOfWeek,
    String? themeMode,
    Value<int?> lastExportAt = const Value.absent(),
    Value<bool?> totalCardFolded = const Value.absent(),
  }) => AppSettingsData(
    id: id ?? this.id,
    firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
    themeMode: themeMode ?? this.themeMode,
    lastExportAt: lastExportAt.present ? lastExportAt.value : this.lastExportAt,
    totalCardFolded: totalCardFolded.present
        ? totalCardFolded.value
        : this.totalCardFolded,
  );
  AppSettingsData copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingsData(
      id: data.id.present ? data.id.value : this.id,
      firstDayOfWeek: data.firstDayOfWeek.present
          ? data.firstDayOfWeek.value
          : this.firstDayOfWeek,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      lastExportAt: data.lastExportAt.present
          ? data.lastExportAt.value
          : this.lastExportAt,
      totalCardFolded: data.totalCardFolded.present
          ? data.totalCardFolded.value
          : this.totalCardFolded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsData(')
          ..write('id: $id, ')
          ..write('firstDayOfWeek: $firstDayOfWeek, ')
          ..write('themeMode: $themeMode, ')
          ..write('lastExportAt: $lastExportAt, ')
          ..write('totalCardFolded: $totalCardFolded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, firstDayOfWeek, themeMode, lastExportAt, totalCardFolded);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsData &&
          other.id == this.id &&
          other.firstDayOfWeek == this.firstDayOfWeek &&
          other.themeMode == this.themeMode &&
          other.lastExportAt == this.lastExportAt &&
          other.totalCardFolded == this.totalCardFolded);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingsData> {
  final Value<int> id;
  final Value<int> firstDayOfWeek;
  final Value<String> themeMode;
  final Value<int?> lastExportAt;
  final Value<bool?> totalCardFolded;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.firstDayOfWeek = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.lastExportAt = const Value.absent(),
    this.totalCardFolded = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.firstDayOfWeek = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.lastExportAt = const Value.absent(),
    this.totalCardFolded = const Value.absent(),
  });
  static Insertable<AppSettingsData> custom({
    Expression<int>? id,
    Expression<int>? firstDayOfWeek,
    Expression<String>? themeMode,
    Expression<int>? lastExportAt,
    Expression<bool>? totalCardFolded,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstDayOfWeek != null) 'first_day_of_week': firstDayOfWeek,
      if (themeMode != null) 'theme_mode': themeMode,
      if (lastExportAt != null) 'last_export_at': lastExportAt,
      if (totalCardFolded != null) 'total_card_folded': totalCardFolded,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? firstDayOfWeek,
    Value<String>? themeMode,
    Value<int?>? lastExportAt,
    Value<bool?>? totalCardFolded,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      themeMode: themeMode ?? this.themeMode,
      lastExportAt: lastExportAt ?? this.lastExportAt,
      totalCardFolded: totalCardFolded ?? this.totalCardFolded,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (firstDayOfWeek.present) {
      map['first_day_of_week'] = Variable<int>(firstDayOfWeek.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (lastExportAt.present) {
      map['last_export_at'] = Variable<int>(lastExportAt.value);
    }
    if (totalCardFolded.present) {
      map['total_card_folded'] = Variable<bool>(totalCardFolded.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('firstDayOfWeek: $firstDayOfWeek, ')
          ..write('themeMode: $themeMode, ')
          ..write('lastExportAt: $lastExportAt, ')
          ..write('totalCardFolded: $totalCardFolded')
          ..write(')'))
        .toString();
  }
}

class $HiddenNotesTable extends HiddenNotes
    with TableInfo<$HiddenNotesTable, HiddenNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HiddenNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hiddenAtMeta = const VerificationMeta(
    'hiddenAt',
  );
  @override
  late final GeneratedColumn<int> hiddenAt = GeneratedColumn<int>(
    'hidden_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [categoryId, note, hiddenAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hidden_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<HiddenNoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('hidden_at')) {
      context.handle(
        _hiddenAtMeta,
        hiddenAt.isAcceptableOrUnknown(data['hidden_at']!, _hiddenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_hiddenAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {categoryId, note};
  @override
  HiddenNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HiddenNoteRow(
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      hiddenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hidden_at'],
      )!,
    );
  }

  @override
  $HiddenNotesTable createAlias(String alias) {
    return $HiddenNotesTable(attachedDatabase, alias);
  }
}

class HiddenNoteRow extends DataClass implements Insertable<HiddenNoteRow> {
  final String categoryId;

  /// Exactly as stored, case included, as the chips match it.
  final String note;

  /// Epoch milliseconds, compared with an expense's `createdAt`.
  final int hiddenAt;
  const HiddenNoteRow({
    required this.categoryId,
    required this.note,
    required this.hiddenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category_id'] = Variable<String>(categoryId);
    map['note'] = Variable<String>(note);
    map['hidden_at'] = Variable<int>(hiddenAt);
    return map;
  }

  HiddenNotesCompanion toCompanion(bool nullToAbsent) {
    return HiddenNotesCompanion(
      categoryId: Value(categoryId),
      note: Value(note),
      hiddenAt: Value(hiddenAt),
    );
  }

  factory HiddenNoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HiddenNoteRow(
      categoryId: serializer.fromJson<String>(json['categoryId']),
      note: serializer.fromJson<String>(json['note']),
      hiddenAt: serializer.fromJson<int>(json['hiddenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'categoryId': serializer.toJson<String>(categoryId),
      'note': serializer.toJson<String>(note),
      'hiddenAt': serializer.toJson<int>(hiddenAt),
    };
  }

  HiddenNoteRow copyWith({String? categoryId, String? note, int? hiddenAt}) =>
      HiddenNoteRow(
        categoryId: categoryId ?? this.categoryId,
        note: note ?? this.note,
        hiddenAt: hiddenAt ?? this.hiddenAt,
      );
  HiddenNoteRow copyWithCompanion(HiddenNotesCompanion data) {
    return HiddenNoteRow(
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      note: data.note.present ? data.note.value : this.note,
      hiddenAt: data.hiddenAt.present ? data.hiddenAt.value : this.hiddenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HiddenNoteRow(')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('hiddenAt: $hiddenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(categoryId, note, hiddenAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HiddenNoteRow &&
          other.categoryId == this.categoryId &&
          other.note == this.note &&
          other.hiddenAt == this.hiddenAt);
}

class HiddenNotesCompanion extends UpdateCompanion<HiddenNoteRow> {
  final Value<String> categoryId;
  final Value<String> note;
  final Value<int> hiddenAt;
  final Value<int> rowid;
  const HiddenNotesCompanion({
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.hiddenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HiddenNotesCompanion.insert({
    required String categoryId,
    required String note,
    required int hiddenAt,
    this.rowid = const Value.absent(),
  }) : categoryId = Value(categoryId),
       note = Value(note),
       hiddenAt = Value(hiddenAt);
  static Insertable<HiddenNoteRow> custom({
    Expression<String>? categoryId,
    Expression<String>? note,
    Expression<int>? hiddenAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (categoryId != null) 'category_id': categoryId,
      if (note != null) 'note': note,
      if (hiddenAt != null) 'hidden_at': hiddenAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HiddenNotesCompanion copyWith({
    Value<String>? categoryId,
    Value<String>? note,
    Value<int>? hiddenAt,
    Value<int>? rowid,
  }) {
    return HiddenNotesCompanion(
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      hiddenAt: hiddenAt ?? this.hiddenAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (hiddenAt.present) {
      map['hidden_at'] = Variable<int>(hiddenAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HiddenNotesCompanion(')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('hiddenAt: $hiddenAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LearnedNotesTable extends LearnedNotes
    with TableInfo<$LearnedNotesTable, LearnedNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearnedNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _shopMeta = const VerificationMeta('shop');
  @override
  late final GeneratedColumn<String> shop = GeneratedColumn<String>(
    'shop',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [shop, amountMinor, note, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learned_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<LearnedNoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('shop')) {
      context.handle(
        _shopMeta,
        shop.isAcceptableOrUnknown(data['shop']!, _shopMeta),
      );
    } else if (isInserting) {
      context.missing(_shopMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {shop, amountMinor};
  @override
  LearnedNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearnedNoteRow(
      shop: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LearnedNotesTable createAlias(String alias) {
    return $LearnedNotesTable(attachedDatabase, alias);
  }
}

class LearnedNoteRow extends DataClass implements Insertable<LearnedNoteRow> {
  /// The shop as read, in its `shopKey` form.
  final String shop;
  final int amountMinor;
  final String note;

  /// Epoch milliseconds of the save that taught it.
  final int updatedAt;
  const LearnedNoteRow({
    required this.shop,
    required this.amountMinor,
    required this.note,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['shop'] = Variable<String>(shop);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['note'] = Variable<String>(note);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  LearnedNotesCompanion toCompanion(bool nullToAbsent) {
    return LearnedNotesCompanion(
      shop: Value(shop),
      amountMinor: Value(amountMinor),
      note: Value(note),
      updatedAt: Value(updatedAt),
    );
  }

  factory LearnedNoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearnedNoteRow(
      shop: serializer.fromJson<String>(json['shop']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      note: serializer.fromJson<String>(json['note']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'shop': serializer.toJson<String>(shop),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'note': serializer.toJson<String>(note),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  LearnedNoteRow copyWith({
    String? shop,
    int? amountMinor,
    String? note,
    int? updatedAt,
  }) => LearnedNoteRow(
    shop: shop ?? this.shop,
    amountMinor: amountMinor ?? this.amountMinor,
    note: note ?? this.note,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LearnedNoteRow copyWithCompanion(LearnedNotesCompanion data) {
    return LearnedNoteRow(
      shop: data.shop.present ? data.shop.value : this.shop,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      note: data.note.present ? data.note.value : this.note,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearnedNoteRow(')
          ..write('shop: $shop, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(shop, amountMinor, note, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearnedNoteRow &&
          other.shop == this.shop &&
          other.amountMinor == this.amountMinor &&
          other.note == this.note &&
          other.updatedAt == this.updatedAt);
}

class LearnedNotesCompanion extends UpdateCompanion<LearnedNoteRow> {
  final Value<String> shop;
  final Value<int> amountMinor;
  final Value<String> note;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const LearnedNotesCompanion({
    this.shop = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LearnedNotesCompanion.insert({
    required String shop,
    required int amountMinor,
    required String note,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : shop = Value(shop),
       amountMinor = Value(amountMinor),
       note = Value(note),
       updatedAt = Value(updatedAt);
  static Insertable<LearnedNoteRow> custom({
    Expression<String>? shop,
    Expression<int>? amountMinor,
    Expression<String>? note,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (shop != null) 'shop': shop,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (note != null) 'note': note,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LearnedNotesCompanion copyWith({
    Value<String>? shop,
    Value<int>? amountMinor,
    Value<String>? note,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return LearnedNotesCompanion(
      shop: shop ?? this.shop,
      amountMinor: amountMinor ?? this.amountMinor,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (shop.present) {
      map['shop'] = Variable<String>(shop.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearnedNotesCompanion(')
          ..write('shop: $shop, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReceiptKindsTable extends ReceiptKinds
    with TableInfo<$ReceiptKindsTable, ReceiptKindRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptKindsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _labelsMeta = const VerificationMeta('labels');
  @override
  late final GeneratedColumn<String> labels = GeneratedColumn<String>(
    'labels',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, labels, name, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipt_kinds';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReceiptKindRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('labels')) {
      context.handle(
        _labelsMeta,
        labels.isAcceptableOrUnknown(data['labels']!, _labelsMeta),
      );
    } else if (isInserting) {
      context.missing(_labelsMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReceiptKindRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReceiptKindRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      labels: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}labels'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ReceiptKindsTable createAlias(String alias) {
    return $ReceiptKindsTable(attachedDatabase, alias);
  }
}

class ReceiptKindRow extends DataClass implements Insertable<ReceiptKindRow> {
  final int id;

  /// The page's labels, one per line (see `parseReceipt`).
  final String labels;
  final String name;

  /// Epoch milliseconds of the last save that named it.
  final int updatedAt;
  const ReceiptKindRow({
    required this.id,
    required this.labels,
    required this.name,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['labels'] = Variable<String>(labels);
    map['name'] = Variable<String>(name);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ReceiptKindsCompanion toCompanion(bool nullToAbsent) {
    return ReceiptKindsCompanion(
      id: Value(id),
      labels: Value(labels),
      name: Value(name),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReceiptKindRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReceiptKindRow(
      id: serializer.fromJson<int>(json['id']),
      labels: serializer.fromJson<String>(json['labels']),
      name: serializer.fromJson<String>(json['name']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'labels': serializer.toJson<String>(labels),
      'name': serializer.toJson<String>(name),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ReceiptKindRow copyWith({
    int? id,
    String? labels,
    String? name,
    int? updatedAt,
  }) => ReceiptKindRow(
    id: id ?? this.id,
    labels: labels ?? this.labels,
    name: name ?? this.name,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReceiptKindRow copyWithCompanion(ReceiptKindsCompanion data) {
    return ReceiptKindRow(
      id: data.id.present ? data.id.value : this.id,
      labels: data.labels.present ? data.labels.value : this.labels,
      name: data.name.present ? data.name.value : this.name,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptKindRow(')
          ..write('id: $id, ')
          ..write('labels: $labels, ')
          ..write('name: $name, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, labels, name, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReceiptKindRow &&
          other.id == this.id &&
          other.labels == this.labels &&
          other.name == this.name &&
          other.updatedAt == this.updatedAt);
}

class ReceiptKindsCompanion extends UpdateCompanion<ReceiptKindRow> {
  final Value<int> id;
  final Value<String> labels;
  final Value<String> name;
  final Value<int> updatedAt;
  const ReceiptKindsCompanion({
    this.id = const Value.absent(),
    this.labels = const Value.absent(),
    this.name = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ReceiptKindsCompanion.insert({
    this.id = const Value.absent(),
    required String labels,
    required String name,
    required int updatedAt,
  }) : labels = Value(labels),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<ReceiptKindRow> custom({
    Expression<int>? id,
    Expression<String>? labels,
    Expression<String>? name,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (labels != null) 'labels': labels,
      if (name != null) 'name': name,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ReceiptKindsCompanion copyWith({
    Value<int>? id,
    Value<String>? labels,
    Value<String>? name,
    Value<int>? updatedAt,
  }) {
    return ReceiptKindsCompanion(
      id: id ?? this.id,
      labels: labels ?? this.labels,
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (labels.present) {
      map['labels'] = Variable<String>(labels.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptKindsCompanion(')
          ..write('id: $id, ')
          ..write('labels: $labels, ')
          ..write('name: $name, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SplitGroupsTable extends SplitGroups
    with TableInfo<$SplitGroupsTable, SplitGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SplitGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    isArchived,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'split_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<SplitGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SplitGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SplitGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SplitGroupsTable createAlias(String alias) {
    return $SplitGroupsTable(attachedDatabase, alias);
  }
}

class SplitGroup extends DataClass implements Insertable<SplitGroup> {
  final String id;
  final String name;
  final bool isArchived;
  final int sortOrder;

  /// Epoch milliseconds.
  final int createdAt;
  const SplitGroup({
    required this.id,
    required this.name,
    required this.isArchived,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_archived'] = Variable<bool>(isArchived);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SplitGroupsCompanion toCompanion(bool nullToAbsent) {
    return SplitGroupsCompanion(
      id: Value(id),
      name: Value(name),
      isArchived: Value(isArchived),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory SplitGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SplitGroup(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isArchived': serializer.toJson<bool>(isArchived),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SplitGroup copyWith({
    String? id,
    String? name,
    bool? isArchived,
    int? sortOrder,
    int? createdAt,
  }) => SplitGroup(
    id: id ?? this.id,
    name: name ?? this.name,
    isArchived: isArchived ?? this.isArchived,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  SplitGroup copyWithCompanion(SplitGroupsCompanion data) {
    return SplitGroup(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SplitGroup(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isArchived: $isArchived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isArchived, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SplitGroup &&
          other.id == this.id &&
          other.name == this.name &&
          other.isArchived == this.isArchived &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class SplitGroupsCompanion extends UpdateCompanion<SplitGroup> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isArchived;
  final Value<int> sortOrder;
  final Value<int> createdAt;
  final Value<int> rowid;
  const SplitGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SplitGroupsCompanion.insert({
    required String id,
    required String name,
    this.isArchived = const Value.absent(),
    required int sortOrder,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sortOrder = Value(sortOrder),
       createdAt = Value(createdAt);
  static Insertable<SplitGroup> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isArchived,
    Expression<int>? sortOrder,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isArchived != null) 'is_archived': isArchived,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SplitGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? isArchived,
    Value<int>? sortOrder,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return SplitGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SplitGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isArchived: $isArchived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SplitPeopleTable extends SplitPeople
    with TableInfo<$SplitPeopleTable, SplitPerson> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SplitPeopleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES split_groups (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isMeMeta = const VerificationMeta('isMe');
  @override
  late final GeneratedColumn<bool> isMe = GeneratedColumn<bool>(
    'is_me',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_me" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, groupId, name, isMe, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'split_people';
  @override
  VerificationContext validateIntegrity(
    Insertable<SplitPerson> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_me')) {
      context.handle(
        _isMeMeta,
        isMe.isAcceptableOrUnknown(data['is_me']!, _isMeMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SplitPerson map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SplitPerson(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isMe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_me'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $SplitPeopleTable createAlias(String alias) {
    return $SplitPeopleTable(attachedDatabase, alias);
  }
}

class SplitPerson extends DataClass implements Insertable<SplitPerson> {
  final String id;
  final String groupId;
  final String name;

  /// Jack himself: first in every group and never removed.
  final bool isMe;

  /// The group's order: the leftover sen and ties in who pays whom go by
  /// it.
  final int sortOrder;
  const SplitPerson({
    required this.id,
    required this.groupId,
    required this.name,
    required this.isMe,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['name'] = Variable<String>(name);
    map['is_me'] = Variable<bool>(isMe);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  SplitPeopleCompanion toCompanion(bool nullToAbsent) {
    return SplitPeopleCompanion(
      id: Value(id),
      groupId: Value(groupId),
      name: Value(name),
      isMe: Value(isMe),
      sortOrder: Value(sortOrder),
    );
  }

  factory SplitPerson.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SplitPerson(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      name: serializer.fromJson<String>(json['name']),
      isMe: serializer.fromJson<bool>(json['isMe']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'name': serializer.toJson<String>(name),
      'isMe': serializer.toJson<bool>(isMe),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  SplitPerson copyWith({
    String? id,
    String? groupId,
    String? name,
    bool? isMe,
    int? sortOrder,
  }) => SplitPerson(
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    name: name ?? this.name,
    isMe: isMe ?? this.isMe,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  SplitPerson copyWithCompanion(SplitPeopleCompanion data) {
    return SplitPerson(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      name: data.name.present ? data.name.value : this.name,
      isMe: data.isMe.present ? data.isMe.value : this.isMe,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SplitPerson(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('isMe: $isMe, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, groupId, name, isMe, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SplitPerson &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.name == this.name &&
          other.isMe == this.isMe &&
          other.sortOrder == this.sortOrder);
}

class SplitPeopleCompanion extends UpdateCompanion<SplitPerson> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> name;
  final Value<bool> isMe;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const SplitPeopleCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.name = const Value.absent(),
    this.isMe = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SplitPeopleCompanion.insert({
    required String id,
    required String groupId,
    required String name,
    this.isMe = const Value.absent(),
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       groupId = Value(groupId),
       name = Value(name),
       sortOrder = Value(sortOrder);
  static Insertable<SplitPerson> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? name,
    Expression<bool>? isMe,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (name != null) 'name': name,
      if (isMe != null) 'is_me': isMe,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SplitPeopleCompanion copyWith({
    Value<String>? id,
    Value<String>? groupId,
    Value<String>? name,
    Value<bool>? isMe,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return SplitPeopleCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      isMe: isMe ?? this.isMe,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isMe.present) {
      map['is_me'] = Variable<bool>(isMe.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SplitPeopleCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('isMe: $isMe, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SplitEntriesTable extends SplitEntries
    with TableInfo<$SplitEntriesTable, SplitEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SplitEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES split_groups (id)',
    ),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payerIdMeta = const VerificationMeta(
    'payerId',
  );
  @override
  late final GeneratedColumn<String> payerId = GeneratedColumn<String>(
    'payer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES split_people (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupId,
    amountMinor,
    categoryId,
    note,
    occurredAt,
    localDate,
    payerId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'split_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SplitEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('payer_id')) {
      context.handle(
        _payerIdMeta,
        payerId.isAcceptableOrUnknown(data['payer_id']!, _payerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_payerIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SplitEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SplitEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      payerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payer_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SplitEntriesTable createAlias(String alias) {
    return $SplitEntriesTable(attachedDatabase, alias);
  }
}

class SplitEntry extends DataClass implements Insertable<SplitEntry> {
  final String id;
  final String groupId;

  /// Sen. Never a double.
  final int amountMinor;
  final String categoryId;
  final String? note;

  /// Epoch milliseconds.
  final int occurredAt;

  /// `YYYY-MM-DD` in device local time, written from [occurredAt].
  final String localDate;
  final String payerId;
  final int createdAt;
  final int updatedAt;
  const SplitEntry({
    required this.id,
    required this.groupId,
    required this.amountMinor,
    required this.categoryId,
    this.note,
    required this.occurredAt,
    required this.localDate,
    required this.payerId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['occurred_at'] = Variable<int>(occurredAt);
    map['local_date'] = Variable<String>(localDate);
    map['payer_id'] = Variable<String>(payerId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SplitEntriesCompanion toCompanion(bool nullToAbsent) {
    return SplitEntriesCompanion(
      id: Value(id),
      groupId: Value(groupId),
      amountMinor: Value(amountMinor),
      categoryId: Value(categoryId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      occurredAt: Value(occurredAt),
      localDate: Value(localDate),
      payerId: Value(payerId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SplitEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SplitEntry(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      note: serializer.fromJson<String?>(json['note']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
      localDate: serializer.fromJson<String>(json['localDate']),
      payerId: serializer.fromJson<String>(json['payerId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'categoryId': serializer.toJson<String>(categoryId),
      'note': serializer.toJson<String?>(note),
      'occurredAt': serializer.toJson<int>(occurredAt),
      'localDate': serializer.toJson<String>(localDate),
      'payerId': serializer.toJson<String>(payerId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SplitEntry copyWith({
    String? id,
    String? groupId,
    int? amountMinor,
    String? categoryId,
    Value<String?> note = const Value.absent(),
    int? occurredAt,
    String? localDate,
    String? payerId,
    int? createdAt,
    int? updatedAt,
  }) => SplitEntry(
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    amountMinor: amountMinor ?? this.amountMinor,
    categoryId: categoryId ?? this.categoryId,
    note: note.present ? note.value : this.note,
    occurredAt: occurredAt ?? this.occurredAt,
    localDate: localDate ?? this.localDate,
    payerId: payerId ?? this.payerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SplitEntry copyWithCompanion(SplitEntriesCompanion data) {
    return SplitEntry(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      note: data.note.present ? data.note.value : this.note,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      payerId: data.payerId.present ? data.payerId.value : this.payerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SplitEntry(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('localDate: $localDate, ')
          ..write('payerId: $payerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    groupId,
    amountMinor,
    categoryId,
    note,
    occurredAt,
    localDate,
    payerId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SplitEntry &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.amountMinor == this.amountMinor &&
          other.categoryId == this.categoryId &&
          other.note == this.note &&
          other.occurredAt == this.occurredAt &&
          other.localDate == this.localDate &&
          other.payerId == this.payerId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SplitEntriesCompanion extends UpdateCompanion<SplitEntry> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<int> amountMinor;
  final Value<String> categoryId;
  final Value<String?> note;
  final Value<int> occurredAt;
  final Value<String> localDate;
  final Value<String> payerId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const SplitEntriesCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.localDate = const Value.absent(),
    this.payerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SplitEntriesCompanion.insert({
    required String id,
    required String groupId,
    required int amountMinor,
    required String categoryId,
    this.note = const Value.absent(),
    required int occurredAt,
    required String localDate,
    required String payerId,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       groupId = Value(groupId),
       amountMinor = Value(amountMinor),
       categoryId = Value(categoryId),
       occurredAt = Value(occurredAt),
       localDate = Value(localDate),
       payerId = Value(payerId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SplitEntry> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<int>? amountMinor,
    Expression<String>? categoryId,
    Expression<String>? note,
    Expression<int>? occurredAt,
    Expression<String>? localDate,
    Expression<String>? payerId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (categoryId != null) 'category_id': categoryId,
      if (note != null) 'note': note,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (localDate != null) 'local_date': localDate,
      if (payerId != null) 'payer_id': payerId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SplitEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? groupId,
    Value<int>? amountMinor,
    Value<String>? categoryId,
    Value<String?>? note,
    Value<int>? occurredAt,
    Value<String>? localDate,
    Value<String>? payerId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return SplitEntriesCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      amountMinor: amountMinor ?? this.amountMinor,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      occurredAt: occurredAt ?? this.occurredAt,
      localDate: localDate ?? this.localDate,
      payerId: payerId ?? this.payerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (payerId.present) {
      map['payer_id'] = Variable<String>(payerId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SplitEntriesCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('localDate: $localDate, ')
          ..write('payerId: $payerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SplitSharesTable extends SplitShares
    with TableInfo<$SplitSharesTable, SplitShare> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SplitSharesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES split_entries (id)',
    ),
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES split_people (id)',
    ),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [entryId, personId, amountMinor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'split_shares';
  @override
  VerificationContext validateIntegrity(
    Insertable<SplitShare> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryId, personId};
  @override
  SplitShare map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SplitShare(
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
    );
  }

  @override
  $SplitSharesTable createAlias(String alias) {
    return $SplitSharesTable(attachedDatabase, alias);
  }
}

class SplitShare extends DataClass implements Insertable<SplitShare> {
  final String entryId;
  final String personId;

  /// Sen. An entry's shares add up to its amount.
  final int amountMinor;
  const SplitShare({
    required this.entryId,
    required this.personId,
    required this.amountMinor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_id'] = Variable<String>(entryId);
    map['person_id'] = Variable<String>(personId);
    map['amount_minor'] = Variable<int>(amountMinor);
    return map;
  }

  SplitSharesCompanion toCompanion(bool nullToAbsent) {
    return SplitSharesCompanion(
      entryId: Value(entryId),
      personId: Value(personId),
      amountMinor: Value(amountMinor),
    );
  }

  factory SplitShare.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SplitShare(
      entryId: serializer.fromJson<String>(json['entryId']),
      personId: serializer.fromJson<String>(json['personId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entryId': serializer.toJson<String>(entryId),
      'personId': serializer.toJson<String>(personId),
      'amountMinor': serializer.toJson<int>(amountMinor),
    };
  }

  SplitShare copyWith({String? entryId, String? personId, int? amountMinor}) =>
      SplitShare(
        entryId: entryId ?? this.entryId,
        personId: personId ?? this.personId,
        amountMinor: amountMinor ?? this.amountMinor,
      );
  SplitShare copyWithCompanion(SplitSharesCompanion data) {
    return SplitShare(
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      personId: data.personId.present ? data.personId.value : this.personId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SplitShare(')
          ..write('entryId: $entryId, ')
          ..write('personId: $personId, ')
          ..write('amountMinor: $amountMinor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entryId, personId, amountMinor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SplitShare &&
          other.entryId == this.entryId &&
          other.personId == this.personId &&
          other.amountMinor == this.amountMinor);
}

class SplitSharesCompanion extends UpdateCompanion<SplitShare> {
  final Value<String> entryId;
  final Value<String> personId;
  final Value<int> amountMinor;
  final Value<int> rowid;
  const SplitSharesCompanion({
    this.entryId = const Value.absent(),
    this.personId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SplitSharesCompanion.insert({
    required String entryId,
    required String personId,
    required int amountMinor,
    this.rowid = const Value.absent(),
  }) : entryId = Value(entryId),
       personId = Value(personId),
       amountMinor = Value(amountMinor);
  static Insertable<SplitShare> custom({
    Expression<String>? entryId,
    Expression<String>? personId,
    Expression<int>? amountMinor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entryId != null) 'entry_id': entryId,
      if (personId != null) 'person_id': personId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SplitSharesCompanion copyWith({
    Value<String>? entryId,
    Value<String>? personId,
    Value<int>? amountMinor,
    Value<int>? rowid,
  }) {
    return SplitSharesCompanion(
      entryId: entryId ?? this.entryId,
      personId: personId ?? this.personId,
      amountMinor: amountMinor ?? this.amountMinor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SplitSharesCompanion(')
          ..write('entryId: $entryId, ')
          ..write('personId: $personId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $RecurringRulesTable recurringRules = $RecurringRulesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $HiddenNotesTable hiddenNotes = $HiddenNotesTable(this);
  late final $LearnedNotesTable learnedNotes = $LearnedNotesTable(this);
  late final $ReceiptKindsTable receiptKinds = $ReceiptKindsTable(this);
  late final $SplitGroupsTable splitGroups = $SplitGroupsTable(this);
  late final $SplitPeopleTable splitPeople = $SplitPeopleTable(this);
  late final $SplitEntriesTable splitEntries = $SplitEntriesTable(this);
  late final $SplitSharesTable splitShares = $SplitSharesTable(this);
  late final CategoryDao categoryDao = CategoryDao(this as AppDatabase);
  late final TransactionDao transactionDao = TransactionDao(
    this as AppDatabase,
  );
  late final RecurringDao recurringDao = RecurringDao(this as AppDatabase);
  late final AnalysisDao analysisDao = AnalysisDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final HiddenNoteDao hiddenNoteDao = HiddenNoteDao(this as AppDatabase);
  late final LearnedNoteDao learnedNoteDao = LearnedNoteDao(
    this as AppDatabase,
  );
  late final ReceiptKindDao receiptKindDao = ReceiptKindDao(
    this as AppDatabase,
  );
  late final SplitDao splitDao = SplitDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    recurringRules,
    transactions,
    appSettings,
    hiddenNotes,
    learnedNotes,
    receiptKinds,
    splitGroups,
    splitPeople,
    splitEntries,
    splitShares,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recurring_rules',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      required String iconKey,
      required String colorHex,
      required int sortOrder,
      Value<bool> isArchived,
      Value<bool> isDefault,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> iconKey,
      Value<String> colorHex,
      Value<int> sortOrder,
      Value<bool> isArchived,
      Value<bool> isDefault,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, ExpenseCategory> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecurringRulesTable, List<RecurringRule>>
  _recurringRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recurringRules,
    aliasName: $_aliasNameGenerator(
      db.categories.id,
      db.recurringRules.categoryId,
    ),
  );

  $$RecurringRulesTableProcessedTableManager get recurringRulesRefs {
    final manager = $$RecurringRulesTableTableManager(
      $_db,
      $_db.recurringRules,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_recurringRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Expense>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: $_aliasNameGenerator(
      db.categories.id,
      db.transactions.categoryId,
    ),
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SplitEntriesTable, List<SplitEntry>>
  _splitEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.splitEntries,
    aliasName: $_aliasNameGenerator(
      db.categories.id,
      db.splitEntries.categoryId,
    ),
  );

  $$SplitEntriesTableProcessedTableManager get splitEntriesRefs {
    final manager = $$SplitEntriesTableTableManager(
      $_db,
      $_db.splitEntries,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_splitEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> recurringRulesRefs(
    Expression<bool> Function($$RecurringRulesTableFilterComposer f) f,
  ) {
    final $$RecurringRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableFilterComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> splitEntriesRefs(
    Expression<bool> Function($$SplitEntriesTableFilterComposer f) f,
  ) {
    final $$SplitEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splitEntries,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitEntriesTableFilterComposer(
            $db: $db,
            $table: $db.splitEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> recurringRulesRefs<T extends Object>(
    Expression<T> Function($$RecurringRulesTableAnnotationComposer a) f,
  ) {
    final $$RecurringRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> splitEntriesRefs<T extends Object>(
    Expression<T> Function($$SplitEntriesTableAnnotationComposer a) f,
  ) {
    final $$SplitEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splitEntries,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.splitEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          ExpenseCategory,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (ExpenseCategory, $$CategoriesTableReferences),
          ExpenseCategory,
          PrefetchHooks Function({
            bool recurringRulesRefs,
            bool transactionsRefs,
            bool splitEntriesRefs,
          })
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                iconKey: iconKey,
                colorHex: colorHex,
                sortOrder: sortOrder,
                isArchived: isArchived,
                isDefault: isDefault,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String iconKey,
                required String colorHex,
                required int sortOrder,
                Value<bool> isArchived = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                iconKey: iconKey,
                colorHex: colorHex,
                sortOrder: sortOrder,
                isArchived: isArchived,
                isDefault: isDefault,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                recurringRulesRefs = false,
                transactionsRefs = false,
                splitEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (recurringRulesRefs) db.recurringRules,
                    if (transactionsRefs) db.transactions,
                    if (splitEntriesRefs) db.splitEntries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (recurringRulesRefs)
                        await $_getPrefetchedData<
                          ExpenseCategory,
                          $CategoriesTable,
                          RecurringRule
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._recurringRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          ExpenseCategory,
                          $CategoriesTable,
                          Expense
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (splitEntriesRefs)
                        await $_getPrefetchedData<
                          ExpenseCategory,
                          $CategoriesTable,
                          SplitEntry
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._splitEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).splitEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      ExpenseCategory,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (ExpenseCategory, $$CategoriesTableReferences),
      ExpenseCategory,
      PrefetchHooks Function({
        bool recurringRulesRefs,
        bool transactionsRefs,
        bool splitEntriesRefs,
      })
    >;
typedef $$RecurringRulesTableCreateCompanionBuilder =
    RecurringRulesCompanion Function({
      required String id,
      required int amountMinor,
      required String categoryId,
      Value<String?> note,
      required int dayOfMonth,
      required String startMonth,
      Value<String?> endMonth,
      Value<bool> isActive,
      Value<String?> lastGeneratedMonth,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$RecurringRulesTableUpdateCompanionBuilder =
    RecurringRulesCompanion Function({
      Value<String> id,
      Value<int> amountMinor,
      Value<String> categoryId,
      Value<String?> note,
      Value<int> dayOfMonth,
      Value<String> startMonth,
      Value<String?> endMonth,
      Value<bool> isActive,
      Value<String?> lastGeneratedMonth,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$RecurringRulesTableReferences
    extends BaseReferences<_$AppDatabase, $RecurringRulesTable, RecurringRule> {
  $$RecurringRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.recurringRules.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Expense>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: $_aliasNameGenerator(
      db.recurringRules.id,
      db.transactions.recurringRuleId,
    ),
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter(
          (f) => f.recurringRuleId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecurringRulesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endMonth => $composableBuilder(
    column: $table.endMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastGeneratedMonth => $composableBuilder(
    column: $table.lastGeneratedMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.recurringRuleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endMonth => $composableBuilder(
    column: $table.endMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastGeneratedMonth => $composableBuilder(
    column: $table.lastGeneratedMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endMonth =>
      $composableBuilder(column: $table.endMonth, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get lastGeneratedMonth => $composableBuilder(
    column: $table.lastGeneratedMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.recurringRuleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringRulesTable,
          RecurringRule,
          $$RecurringRulesTableFilterComposer,
          $$RecurringRulesTableOrderingComposer,
          $$RecurringRulesTableAnnotationComposer,
          $$RecurringRulesTableCreateCompanionBuilder,
          $$RecurringRulesTableUpdateCompanionBuilder,
          (RecurringRule, $$RecurringRulesTableReferences),
          RecurringRule,
          PrefetchHooks Function({bool categoryId, bool transactionsRefs})
        > {
  $$RecurringRulesTableTableManager(
    _$AppDatabase db,
    $RecurringRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> dayOfMonth = const Value.absent(),
                Value<String> startMonth = const Value.absent(),
                Value<String?> endMonth = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> lastGeneratedMonth = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringRulesCompanion(
                id: id,
                amountMinor: amountMinor,
                categoryId: categoryId,
                note: note,
                dayOfMonth: dayOfMonth,
                startMonth: startMonth,
                endMonth: endMonth,
                isActive: isActive,
                lastGeneratedMonth: lastGeneratedMonth,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int amountMinor,
                required String categoryId,
                Value<String?> note = const Value.absent(),
                required int dayOfMonth,
                required String startMonth,
                Value<String?> endMonth = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> lastGeneratedMonth = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RecurringRulesCompanion.insert(
                id: id,
                amountMinor: amountMinor,
                categoryId: categoryId,
                note: note,
                dayOfMonth: dayOfMonth,
                startMonth: startMonth,
                endMonth: endMonth,
                isActive: isActive,
                lastGeneratedMonth: lastGeneratedMonth,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecurringRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({categoryId = false, transactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$RecurringRulesTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$RecurringRulesTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          RecurringRule,
                          $RecurringRulesTable,
                          Expense
                        >(
                          currentTable: table,
                          referencedTable: $$RecurringRulesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecurringRulesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recurringRuleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RecurringRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringRulesTable,
      RecurringRule,
      $$RecurringRulesTableFilterComposer,
      $$RecurringRulesTableOrderingComposer,
      $$RecurringRulesTableAnnotationComposer,
      $$RecurringRulesTableCreateCompanionBuilder,
      $$RecurringRulesTableUpdateCompanionBuilder,
      (RecurringRule, $$RecurringRulesTableReferences),
      RecurringRule,
      PrefetchHooks Function({bool categoryId, bool transactionsRefs})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required int amountMinor,
      required String categoryId,
      required int occurredAt,
      required String localDate,
      Value<String?> note,
      required String source,
      Value<String?> recurringRuleId,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<int> amountMinor,
      Value<String> categoryId,
      Value<int> occurredAt,
      Value<String> localDate,
      Value<String?> note,
      Value<String> source,
      Value<String?> recurringRuleId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Expense> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.transactions.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RecurringRulesTable _recurringRuleIdTable(_$AppDatabase db) =>
      db.recurringRules.createAlias(
        $_aliasNameGenerator(
          db.transactions.recurringRuleId,
          db.recurringRules.id,
        ),
      );

  $$RecurringRulesTableProcessedTableManager? get recurringRuleId {
    final $_column = $_itemColumn<String>('recurring_rule_id');
    if ($_column == null) return null;
    final manager = $$RecurringRulesTableTableManager(
      $_db,
      $_db.recurringRules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recurringRuleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringRulesTableFilterComposer get recurringRuleId {
    final $$RecurringRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recurringRuleId,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableFilterComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringRulesTableOrderingComposer get recurringRuleId {
    final $$RecurringRulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recurringRuleId,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableOrderingComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringRulesTableAnnotationComposer get recurringRuleId {
    final $$RecurringRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recurringRuleId,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Expense,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (Expense, $$TransactionsTableReferences),
          Expense,
          PrefetchHooks Function({bool categoryId, bool recurringRuleId})
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> recurringRuleId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                amountMinor: amountMinor,
                categoryId: categoryId,
                occurredAt: occurredAt,
                localDate: localDate,
                note: note,
                source: source,
                recurringRuleId: recurringRuleId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int amountMinor,
                required String categoryId,
                required int occurredAt,
                required String localDate,
                Value<String?> note = const Value.absent(),
                required String source,
                Value<String?> recurringRuleId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                amountMinor: amountMinor,
                categoryId: categoryId,
                occurredAt: occurredAt,
                localDate: localDate,
                note: note,
                source: source,
                recurringRuleId: recurringRuleId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({categoryId = false, recurringRuleId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (recurringRuleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.recurringRuleId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._recurringRuleIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._recurringRuleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Expense,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Expense, $$TransactionsTableReferences),
      Expense,
      PrefetchHooks Function({bool categoryId, bool recurringRuleId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<int> firstDayOfWeek,
      Value<String> themeMode,
      Value<int?> lastExportAt,
      Value<bool?> totalCardFolded,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<int> firstDayOfWeek,
      Value<String> themeMode,
      Value<int?> lastExportAt,
      Value<bool?> totalCardFolded,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstDayOfWeek => $composableBuilder(
    column: $table.firstDayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastExportAt => $composableBuilder(
    column: $table.lastExportAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get totalCardFolded => $composableBuilder(
    column: $table.totalCardFolded,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstDayOfWeek => $composableBuilder(
    column: $table.firstDayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastExportAt => $composableBuilder(
    column: $table.lastExportAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get totalCardFolded => $composableBuilder(
    column: $table.totalCardFolded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get firstDayOfWeek => $composableBuilder(
    column: $table.firstDayOfWeek,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<int> get lastExportAt => $composableBuilder(
    column: $table.lastExportAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get totalCardFolded => $composableBuilder(
    column: $table.totalCardFolded,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingsData,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingsData,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsData>,
          ),
          AppSettingsData,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> firstDayOfWeek = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<int?> lastExportAt = const Value.absent(),
                Value<bool?> totalCardFolded = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                firstDayOfWeek: firstDayOfWeek,
                themeMode: themeMode,
                lastExportAt: lastExportAt,
                totalCardFolded: totalCardFolded,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> firstDayOfWeek = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<int?> lastExportAt = const Value.absent(),
                Value<bool?> totalCardFolded = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                firstDayOfWeek: firstDayOfWeek,
                themeMode: themeMode,
                lastExportAt: lastExportAt,
                totalCardFolded: totalCardFolded,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingsData,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingsData,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsData>,
      ),
      AppSettingsData,
      PrefetchHooks Function()
    >;
typedef $$HiddenNotesTableCreateCompanionBuilder =
    HiddenNotesCompanion Function({
      required String categoryId,
      required String note,
      required int hiddenAt,
      Value<int> rowid,
    });
typedef $$HiddenNotesTableUpdateCompanionBuilder =
    HiddenNotesCompanion Function({
      Value<String> categoryId,
      Value<String> note,
      Value<int> hiddenAt,
      Value<int> rowid,
    });

class $$HiddenNotesTableFilterComposer
    extends Composer<_$AppDatabase, $HiddenNotesTable> {
  $$HiddenNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hiddenAt => $composableBuilder(
    column: $table.hiddenAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HiddenNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $HiddenNotesTable> {
  $$HiddenNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hiddenAt => $composableBuilder(
    column: $table.hiddenAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HiddenNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HiddenNotesTable> {
  $$HiddenNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get hiddenAt =>
      $composableBuilder(column: $table.hiddenAt, builder: (column) => column);
}

class $$HiddenNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HiddenNotesTable,
          HiddenNoteRow,
          $$HiddenNotesTableFilterComposer,
          $$HiddenNotesTableOrderingComposer,
          $$HiddenNotesTableAnnotationComposer,
          $$HiddenNotesTableCreateCompanionBuilder,
          $$HiddenNotesTableUpdateCompanionBuilder,
          (
            HiddenNoteRow,
            BaseReferences<_$AppDatabase, $HiddenNotesTable, HiddenNoteRow>,
          ),
          HiddenNoteRow,
          PrefetchHooks Function()
        > {
  $$HiddenNotesTableTableManager(_$AppDatabase db, $HiddenNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HiddenNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HiddenNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HiddenNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> categoryId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> hiddenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HiddenNotesCompanion(
                categoryId: categoryId,
                note: note,
                hiddenAt: hiddenAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String categoryId,
                required String note,
                required int hiddenAt,
                Value<int> rowid = const Value.absent(),
              }) => HiddenNotesCompanion.insert(
                categoryId: categoryId,
                note: note,
                hiddenAt: hiddenAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HiddenNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HiddenNotesTable,
      HiddenNoteRow,
      $$HiddenNotesTableFilterComposer,
      $$HiddenNotesTableOrderingComposer,
      $$HiddenNotesTableAnnotationComposer,
      $$HiddenNotesTableCreateCompanionBuilder,
      $$HiddenNotesTableUpdateCompanionBuilder,
      (
        HiddenNoteRow,
        BaseReferences<_$AppDatabase, $HiddenNotesTable, HiddenNoteRow>,
      ),
      HiddenNoteRow,
      PrefetchHooks Function()
    >;
typedef $$LearnedNotesTableCreateCompanionBuilder =
    LearnedNotesCompanion Function({
      required String shop,
      required int amountMinor,
      required String note,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$LearnedNotesTableUpdateCompanionBuilder =
    LearnedNotesCompanion Function({
      Value<String> shop,
      Value<int> amountMinor,
      Value<String> note,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$LearnedNotesTableFilterComposer
    extends Composer<_$AppDatabase, $LearnedNotesTable> {
  $$LearnedNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get shop => $composableBuilder(
    column: $table.shop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LearnedNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $LearnedNotesTable> {
  $$LearnedNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get shop => $composableBuilder(
    column: $table.shop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LearnedNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LearnedNotesTable> {
  $$LearnedNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get shop =>
      $composableBuilder(column: $table.shop, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LearnedNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LearnedNotesTable,
          LearnedNoteRow,
          $$LearnedNotesTableFilterComposer,
          $$LearnedNotesTableOrderingComposer,
          $$LearnedNotesTableAnnotationComposer,
          $$LearnedNotesTableCreateCompanionBuilder,
          $$LearnedNotesTableUpdateCompanionBuilder,
          (
            LearnedNoteRow,
            BaseReferences<_$AppDatabase, $LearnedNotesTable, LearnedNoteRow>,
          ),
          LearnedNoteRow,
          PrefetchHooks Function()
        > {
  $$LearnedNotesTableTableManager(_$AppDatabase db, $LearnedNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearnedNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LearnedNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LearnedNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> shop = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LearnedNotesCompanion(
                shop: shop,
                amountMinor: amountMinor,
                note: note,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String shop,
                required int amountMinor,
                required String note,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LearnedNotesCompanion.insert(
                shop: shop,
                amountMinor: amountMinor,
                note: note,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LearnedNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LearnedNotesTable,
      LearnedNoteRow,
      $$LearnedNotesTableFilterComposer,
      $$LearnedNotesTableOrderingComposer,
      $$LearnedNotesTableAnnotationComposer,
      $$LearnedNotesTableCreateCompanionBuilder,
      $$LearnedNotesTableUpdateCompanionBuilder,
      (
        LearnedNoteRow,
        BaseReferences<_$AppDatabase, $LearnedNotesTable, LearnedNoteRow>,
      ),
      LearnedNoteRow,
      PrefetchHooks Function()
    >;
typedef $$ReceiptKindsTableCreateCompanionBuilder =
    ReceiptKindsCompanion Function({
      Value<int> id,
      required String labels,
      required String name,
      required int updatedAt,
    });
typedef $$ReceiptKindsTableUpdateCompanionBuilder =
    ReceiptKindsCompanion Function({
      Value<int> id,
      Value<String> labels,
      Value<String> name,
      Value<int> updatedAt,
    });

class $$ReceiptKindsTableFilterComposer
    extends Composer<_$AppDatabase, $ReceiptKindsTable> {
  $$ReceiptKindsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReceiptKindsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceiptKindsTable> {
  $$ReceiptKindsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReceiptKindsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceiptKindsTable> {
  $$ReceiptKindsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get labels =>
      $composableBuilder(column: $table.labels, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ReceiptKindsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReceiptKindsTable,
          ReceiptKindRow,
          $$ReceiptKindsTableFilterComposer,
          $$ReceiptKindsTableOrderingComposer,
          $$ReceiptKindsTableAnnotationComposer,
          $$ReceiptKindsTableCreateCompanionBuilder,
          $$ReceiptKindsTableUpdateCompanionBuilder,
          (
            ReceiptKindRow,
            BaseReferences<_$AppDatabase, $ReceiptKindsTable, ReceiptKindRow>,
          ),
          ReceiptKindRow,
          PrefetchHooks Function()
        > {
  $$ReceiptKindsTableTableManager(_$AppDatabase db, $ReceiptKindsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptKindsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptKindsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptKindsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> labels = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => ReceiptKindsCompanion(
                id: id,
                labels: labels,
                name: name,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String labels,
                required String name,
                required int updatedAt,
              }) => ReceiptKindsCompanion.insert(
                id: id,
                labels: labels,
                name: name,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReceiptKindsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReceiptKindsTable,
      ReceiptKindRow,
      $$ReceiptKindsTableFilterComposer,
      $$ReceiptKindsTableOrderingComposer,
      $$ReceiptKindsTableAnnotationComposer,
      $$ReceiptKindsTableCreateCompanionBuilder,
      $$ReceiptKindsTableUpdateCompanionBuilder,
      (
        ReceiptKindRow,
        BaseReferences<_$AppDatabase, $ReceiptKindsTable, ReceiptKindRow>,
      ),
      ReceiptKindRow,
      PrefetchHooks Function()
    >;
typedef $$SplitGroupsTableCreateCompanionBuilder =
    SplitGroupsCompanion Function({
      required String id,
      required String name,
      Value<bool> isArchived,
      required int sortOrder,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$SplitGroupsTableUpdateCompanionBuilder =
    SplitGroupsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<bool> isArchived,
      Value<int> sortOrder,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$SplitGroupsTableReferences
    extends BaseReferences<_$AppDatabase, $SplitGroupsTable, SplitGroup> {
  $$SplitGroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SplitPeopleTable, List<SplitPerson>>
  _splitPeopleRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.splitPeople,
    aliasName: $_aliasNameGenerator(db.splitGroups.id, db.splitPeople.groupId),
  );

  $$SplitPeopleTableProcessedTableManager get splitPeopleRefs {
    final manager = $$SplitPeopleTableTableManager(
      $_db,
      $_db.splitPeople,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_splitPeopleRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SplitEntriesTable, List<SplitEntry>>
  _splitEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.splitEntries,
    aliasName: $_aliasNameGenerator(db.splitGroups.id, db.splitEntries.groupId),
  );

  $$SplitEntriesTableProcessedTableManager get splitEntriesRefs {
    final manager = $$SplitEntriesTableTableManager(
      $_db,
      $_db.splitEntries,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_splitEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SplitGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $SplitGroupsTable> {
  $$SplitGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> splitPeopleRefs(
    Expression<bool> Function($$SplitPeopleTableFilterComposer f) f,
  ) {
    final $$SplitPeopleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splitPeople,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitPeopleTableFilterComposer(
            $db: $db,
            $table: $db.splitPeople,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> splitEntriesRefs(
    Expression<bool> Function($$SplitEntriesTableFilterComposer f) f,
  ) {
    final $$SplitEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splitEntries,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitEntriesTableFilterComposer(
            $db: $db,
            $table: $db.splitEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SplitGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $SplitGroupsTable> {
  $$SplitGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SplitGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SplitGroupsTable> {
  $$SplitGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> splitPeopleRefs<T extends Object>(
    Expression<T> Function($$SplitPeopleTableAnnotationComposer a) f,
  ) {
    final $$SplitPeopleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splitPeople,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitPeopleTableAnnotationComposer(
            $db: $db,
            $table: $db.splitPeople,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> splitEntriesRefs<T extends Object>(
    Expression<T> Function($$SplitEntriesTableAnnotationComposer a) f,
  ) {
    final $$SplitEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splitEntries,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.splitEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SplitGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SplitGroupsTable,
          SplitGroup,
          $$SplitGroupsTableFilterComposer,
          $$SplitGroupsTableOrderingComposer,
          $$SplitGroupsTableAnnotationComposer,
          $$SplitGroupsTableCreateCompanionBuilder,
          $$SplitGroupsTableUpdateCompanionBuilder,
          (SplitGroup, $$SplitGroupsTableReferences),
          SplitGroup,
          PrefetchHooks Function({bool splitPeopleRefs, bool splitEntriesRefs})
        > {
  $$SplitGroupsTableTableManager(_$AppDatabase db, $SplitGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SplitGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SplitGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SplitGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SplitGroupsCompanion(
                id: id,
                name: name,
                isArchived: isArchived,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<bool> isArchived = const Value.absent(),
                required int sortOrder,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SplitGroupsCompanion.insert(
                id: id,
                name: name,
                isArchived: isArchived,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SplitGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({splitPeopleRefs = false, splitEntriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (splitPeopleRefs) db.splitPeople,
                    if (splitEntriesRefs) db.splitEntries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (splitPeopleRefs)
                        await $_getPrefetchedData<
                          SplitGroup,
                          $SplitGroupsTable,
                          SplitPerson
                        >(
                          currentTable: table,
                          referencedTable: $$SplitGroupsTableReferences
                              ._splitPeopleRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SplitGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).splitPeopleRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (splitEntriesRefs)
                        await $_getPrefetchedData<
                          SplitGroup,
                          $SplitGroupsTable,
                          SplitEntry
                        >(
                          currentTable: table,
                          referencedTable: $$SplitGroupsTableReferences
                              ._splitEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SplitGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).splitEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SplitGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SplitGroupsTable,
      SplitGroup,
      $$SplitGroupsTableFilterComposer,
      $$SplitGroupsTableOrderingComposer,
      $$SplitGroupsTableAnnotationComposer,
      $$SplitGroupsTableCreateCompanionBuilder,
      $$SplitGroupsTableUpdateCompanionBuilder,
      (SplitGroup, $$SplitGroupsTableReferences),
      SplitGroup,
      PrefetchHooks Function({bool splitPeopleRefs, bool splitEntriesRefs})
    >;
typedef $$SplitPeopleTableCreateCompanionBuilder =
    SplitPeopleCompanion Function({
      required String id,
      required String groupId,
      required String name,
      Value<bool> isMe,
      required int sortOrder,
      Value<int> rowid,
    });
typedef $$SplitPeopleTableUpdateCompanionBuilder =
    SplitPeopleCompanion Function({
      Value<String> id,
      Value<String> groupId,
      Value<String> name,
      Value<bool> isMe,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$SplitPeopleTableReferences
    extends BaseReferences<_$AppDatabase, $SplitPeopleTable, SplitPerson> {
  $$SplitPeopleTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SplitGroupsTable _groupIdTable(_$AppDatabase db) =>
      db.splitGroups.createAlias(
        $_aliasNameGenerator(db.splitPeople.groupId, db.splitGroups.id),
      );

  $$SplitGroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$SplitGroupsTableTableManager(
      $_db,
      $_db.splitGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SplitEntriesTable, List<SplitEntry>>
  _splitEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.splitEntries,
    aliasName: $_aliasNameGenerator(db.splitPeople.id, db.splitEntries.payerId),
  );

  $$SplitEntriesTableProcessedTableManager get splitEntriesRefs {
    final manager = $$SplitEntriesTableTableManager(
      $_db,
      $_db.splitEntries,
    ).filter((f) => f.payerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_splitEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SplitSharesTable, List<SplitShare>>
  _splitSharesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.splitShares,
    aliasName: $_aliasNameGenerator(db.splitPeople.id, db.splitShares.personId),
  );

  $$SplitSharesTableProcessedTableManager get splitSharesRefs {
    final manager = $$SplitSharesTableTableManager(
      $_db,
      $_db.splitShares,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_splitSharesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SplitPeopleTableFilterComposer
    extends Composer<_$AppDatabase, $SplitPeopleTable> {
  $$SplitPeopleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMe => $composableBuilder(
    column: $table.isMe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$SplitGroupsTableFilterComposer get groupId {
    final $$SplitGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.splitGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitGroupsTableFilterComposer(
            $db: $db,
            $table: $db.splitGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> splitEntriesRefs(
    Expression<bool> Function($$SplitEntriesTableFilterComposer f) f,
  ) {
    final $$SplitEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splitEntries,
      getReferencedColumn: (t) => t.payerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitEntriesTableFilterComposer(
            $db: $db,
            $table: $db.splitEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> splitSharesRefs(
    Expression<bool> Function($$SplitSharesTableFilterComposer f) f,
  ) {
    final $$SplitSharesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splitShares,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitSharesTableFilterComposer(
            $db: $db,
            $table: $db.splitShares,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SplitPeopleTableOrderingComposer
    extends Composer<_$AppDatabase, $SplitPeopleTable> {
  $$SplitPeopleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMe => $composableBuilder(
    column: $table.isMe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$SplitGroupsTableOrderingComposer get groupId {
    final $$SplitGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.splitGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.splitGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SplitPeopleTableAnnotationComposer
    extends Composer<_$AppDatabase, $SplitPeopleTable> {
  $$SplitPeopleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isMe =>
      $composableBuilder(column: $table.isMe, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$SplitGroupsTableAnnotationComposer get groupId {
    final $$SplitGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.splitGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.splitGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> splitEntriesRefs<T extends Object>(
    Expression<T> Function($$SplitEntriesTableAnnotationComposer a) f,
  ) {
    final $$SplitEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splitEntries,
      getReferencedColumn: (t) => t.payerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.splitEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> splitSharesRefs<T extends Object>(
    Expression<T> Function($$SplitSharesTableAnnotationComposer a) f,
  ) {
    final $$SplitSharesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splitShares,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitSharesTableAnnotationComposer(
            $db: $db,
            $table: $db.splitShares,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SplitPeopleTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SplitPeopleTable,
          SplitPerson,
          $$SplitPeopleTableFilterComposer,
          $$SplitPeopleTableOrderingComposer,
          $$SplitPeopleTableAnnotationComposer,
          $$SplitPeopleTableCreateCompanionBuilder,
          $$SplitPeopleTableUpdateCompanionBuilder,
          (SplitPerson, $$SplitPeopleTableReferences),
          SplitPerson,
          PrefetchHooks Function({
            bool groupId,
            bool splitEntriesRefs,
            bool splitSharesRefs,
          })
        > {
  $$SplitPeopleTableTableManager(_$AppDatabase db, $SplitPeopleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SplitPeopleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SplitPeopleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SplitPeopleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isMe = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SplitPeopleCompanion(
                id: id,
                groupId: groupId,
                name: name,
                isMe: isMe,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String groupId,
                required String name,
                Value<bool> isMe = const Value.absent(),
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => SplitPeopleCompanion.insert(
                id: id,
                groupId: groupId,
                name: name,
                isMe: isMe,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SplitPeopleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                groupId = false,
                splitEntriesRefs = false,
                splitSharesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (splitEntriesRefs) db.splitEntries,
                    if (splitSharesRefs) db.splitShares,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (groupId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.groupId,
                                    referencedTable:
                                        $$SplitPeopleTableReferences
                                            ._groupIdTable(db),
                                    referencedColumn:
                                        $$SplitPeopleTableReferences
                                            ._groupIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (splitEntriesRefs)
                        await $_getPrefetchedData<
                          SplitPerson,
                          $SplitPeopleTable,
                          SplitEntry
                        >(
                          currentTable: table,
                          referencedTable: $$SplitPeopleTableReferences
                              ._splitEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SplitPeopleTableReferences(
                                db,
                                table,
                                p0,
                              ).splitEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.payerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (splitSharesRefs)
                        await $_getPrefetchedData<
                          SplitPerson,
                          $SplitPeopleTable,
                          SplitShare
                        >(
                          currentTable: table,
                          referencedTable: $$SplitPeopleTableReferences
                              ._splitSharesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SplitPeopleTableReferences(
                                db,
                                table,
                                p0,
                              ).splitSharesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SplitPeopleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SplitPeopleTable,
      SplitPerson,
      $$SplitPeopleTableFilterComposer,
      $$SplitPeopleTableOrderingComposer,
      $$SplitPeopleTableAnnotationComposer,
      $$SplitPeopleTableCreateCompanionBuilder,
      $$SplitPeopleTableUpdateCompanionBuilder,
      (SplitPerson, $$SplitPeopleTableReferences),
      SplitPerson,
      PrefetchHooks Function({
        bool groupId,
        bool splitEntriesRefs,
        bool splitSharesRefs,
      })
    >;
typedef $$SplitEntriesTableCreateCompanionBuilder =
    SplitEntriesCompanion Function({
      required String id,
      required String groupId,
      required int amountMinor,
      required String categoryId,
      Value<String?> note,
      required int occurredAt,
      required String localDate,
      required String payerId,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$SplitEntriesTableUpdateCompanionBuilder =
    SplitEntriesCompanion Function({
      Value<String> id,
      Value<String> groupId,
      Value<int> amountMinor,
      Value<String> categoryId,
      Value<String?> note,
      Value<int> occurredAt,
      Value<String> localDate,
      Value<String> payerId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$SplitEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $SplitEntriesTable, SplitEntry> {
  $$SplitEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SplitGroupsTable _groupIdTable(_$AppDatabase db) =>
      db.splitGroups.createAlias(
        $_aliasNameGenerator(db.splitEntries.groupId, db.splitGroups.id),
      );

  $$SplitGroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$SplitGroupsTableTableManager(
      $_db,
      $_db.splitGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.splitEntries.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SplitPeopleTable _payerIdTable(_$AppDatabase db) =>
      db.splitPeople.createAlias(
        $_aliasNameGenerator(db.splitEntries.payerId, db.splitPeople.id),
      );

  $$SplitPeopleTableProcessedTableManager get payerId {
    final $_column = $_itemColumn<String>('payer_id')!;

    final manager = $$SplitPeopleTableTableManager(
      $_db,
      $_db.splitPeople,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_payerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SplitSharesTable, List<SplitShare>>
  _splitSharesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.splitShares,
    aliasName: $_aliasNameGenerator(db.splitEntries.id, db.splitShares.entryId),
  );

  $$SplitSharesTableProcessedTableManager get splitSharesRefs {
    final manager = $$SplitSharesTableTableManager(
      $_db,
      $_db.splitShares,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_splitSharesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SplitEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SplitEntriesTable> {
  $$SplitEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SplitGroupsTableFilterComposer get groupId {
    final $$SplitGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.splitGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitGroupsTableFilterComposer(
            $db: $db,
            $table: $db.splitGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SplitPeopleTableFilterComposer get payerId {
    final $$SplitPeopleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.payerId,
      referencedTable: $db.splitPeople,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitPeopleTableFilterComposer(
            $db: $db,
            $table: $db.splitPeople,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> splitSharesRefs(
    Expression<bool> Function($$SplitSharesTableFilterComposer f) f,
  ) {
    final $$SplitSharesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splitShares,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitSharesTableFilterComposer(
            $db: $db,
            $table: $db.splitShares,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SplitEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SplitEntriesTable> {
  $$SplitEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SplitGroupsTableOrderingComposer get groupId {
    final $$SplitGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.splitGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.splitGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SplitPeopleTableOrderingComposer get payerId {
    final $$SplitPeopleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.payerId,
      referencedTable: $db.splitPeople,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitPeopleTableOrderingComposer(
            $db: $db,
            $table: $db.splitPeople,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SplitEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SplitEntriesTable> {
  $$SplitEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SplitGroupsTableAnnotationComposer get groupId {
    final $$SplitGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.splitGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.splitGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SplitPeopleTableAnnotationComposer get payerId {
    final $$SplitPeopleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.payerId,
      referencedTable: $db.splitPeople,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitPeopleTableAnnotationComposer(
            $db: $db,
            $table: $db.splitPeople,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> splitSharesRefs<T extends Object>(
    Expression<T> Function($$SplitSharesTableAnnotationComposer a) f,
  ) {
    final $$SplitSharesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splitShares,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitSharesTableAnnotationComposer(
            $db: $db,
            $table: $db.splitShares,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SplitEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SplitEntriesTable,
          SplitEntry,
          $$SplitEntriesTableFilterComposer,
          $$SplitEntriesTableOrderingComposer,
          $$SplitEntriesTableAnnotationComposer,
          $$SplitEntriesTableCreateCompanionBuilder,
          $$SplitEntriesTableUpdateCompanionBuilder,
          (SplitEntry, $$SplitEntriesTableReferences),
          SplitEntry,
          PrefetchHooks Function({
            bool groupId,
            bool categoryId,
            bool payerId,
            bool splitSharesRefs,
          })
        > {
  $$SplitEntriesTableTableManager(_$AppDatabase db, $SplitEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SplitEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SplitEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SplitEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<String> payerId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SplitEntriesCompanion(
                id: id,
                groupId: groupId,
                amountMinor: amountMinor,
                categoryId: categoryId,
                note: note,
                occurredAt: occurredAt,
                localDate: localDate,
                payerId: payerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String groupId,
                required int amountMinor,
                required String categoryId,
                Value<String?> note = const Value.absent(),
                required int occurredAt,
                required String localDate,
                required String payerId,
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SplitEntriesCompanion.insert(
                id: id,
                groupId: groupId,
                amountMinor: amountMinor,
                categoryId: categoryId,
                note: note,
                occurredAt: occurredAt,
                localDate: localDate,
                payerId: payerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SplitEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                groupId = false,
                categoryId = false,
                payerId = false,
                splitSharesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (splitSharesRefs) db.splitShares,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (groupId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.groupId,
                                    referencedTable:
                                        $$SplitEntriesTableReferences
                                            ._groupIdTable(db),
                                    referencedColumn:
                                        $$SplitEntriesTableReferences
                                            ._groupIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$SplitEntriesTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$SplitEntriesTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (payerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.payerId,
                                    referencedTable:
                                        $$SplitEntriesTableReferences
                                            ._payerIdTable(db),
                                    referencedColumn:
                                        $$SplitEntriesTableReferences
                                            ._payerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (splitSharesRefs)
                        await $_getPrefetchedData<
                          SplitEntry,
                          $SplitEntriesTable,
                          SplitShare
                        >(
                          currentTable: table,
                          referencedTable: $$SplitEntriesTableReferences
                              ._splitSharesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SplitEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).splitSharesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SplitEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SplitEntriesTable,
      SplitEntry,
      $$SplitEntriesTableFilterComposer,
      $$SplitEntriesTableOrderingComposer,
      $$SplitEntriesTableAnnotationComposer,
      $$SplitEntriesTableCreateCompanionBuilder,
      $$SplitEntriesTableUpdateCompanionBuilder,
      (SplitEntry, $$SplitEntriesTableReferences),
      SplitEntry,
      PrefetchHooks Function({
        bool groupId,
        bool categoryId,
        bool payerId,
        bool splitSharesRefs,
      })
    >;
typedef $$SplitSharesTableCreateCompanionBuilder =
    SplitSharesCompanion Function({
      required String entryId,
      required String personId,
      required int amountMinor,
      Value<int> rowid,
    });
typedef $$SplitSharesTableUpdateCompanionBuilder =
    SplitSharesCompanion Function({
      Value<String> entryId,
      Value<String> personId,
      Value<int> amountMinor,
      Value<int> rowid,
    });

final class $$SplitSharesTableReferences
    extends BaseReferences<_$AppDatabase, $SplitSharesTable, SplitShare> {
  $$SplitSharesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SplitEntriesTable _entryIdTable(_$AppDatabase db) =>
      db.splitEntries.createAlias(
        $_aliasNameGenerator(db.splitShares.entryId, db.splitEntries.id),
      );

  $$SplitEntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<String>('entry_id')!;

    final manager = $$SplitEntriesTableTableManager(
      $_db,
      $_db.splitEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SplitPeopleTable _personIdTable(_$AppDatabase db) =>
      db.splitPeople.createAlias(
        $_aliasNameGenerator(db.splitShares.personId, db.splitPeople.id),
      );

  $$SplitPeopleTableProcessedTableManager get personId {
    final $_column = $_itemColumn<String>('person_id')!;

    final manager = $$SplitPeopleTableTableManager(
      $_db,
      $_db.splitPeople,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SplitSharesTableFilterComposer
    extends Composer<_$AppDatabase, $SplitSharesTable> {
  $$SplitSharesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  $$SplitEntriesTableFilterComposer get entryId {
    final $$SplitEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.splitEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitEntriesTableFilterComposer(
            $db: $db,
            $table: $db.splitEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SplitPeopleTableFilterComposer get personId {
    final $$SplitPeopleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.splitPeople,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitPeopleTableFilterComposer(
            $db: $db,
            $table: $db.splitPeople,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SplitSharesTableOrderingComposer
    extends Composer<_$AppDatabase, $SplitSharesTable> {
  $$SplitSharesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  $$SplitEntriesTableOrderingComposer get entryId {
    final $$SplitEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.splitEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.splitEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SplitPeopleTableOrderingComposer get personId {
    final $$SplitPeopleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.splitPeople,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitPeopleTableOrderingComposer(
            $db: $db,
            $table: $db.splitPeople,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SplitSharesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SplitSharesTable> {
  $$SplitSharesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  $$SplitEntriesTableAnnotationComposer get entryId {
    final $$SplitEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.splitEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.splitEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SplitPeopleTableAnnotationComposer get personId {
    final $$SplitPeopleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.splitPeople,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitPeopleTableAnnotationComposer(
            $db: $db,
            $table: $db.splitPeople,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SplitSharesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SplitSharesTable,
          SplitShare,
          $$SplitSharesTableFilterComposer,
          $$SplitSharesTableOrderingComposer,
          $$SplitSharesTableAnnotationComposer,
          $$SplitSharesTableCreateCompanionBuilder,
          $$SplitSharesTableUpdateCompanionBuilder,
          (SplitShare, $$SplitSharesTableReferences),
          SplitShare,
          PrefetchHooks Function({bool entryId, bool personId})
        > {
  $$SplitSharesTableTableManager(_$AppDatabase db, $SplitSharesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SplitSharesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SplitSharesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SplitSharesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entryId = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SplitSharesCompanion(
                entryId: entryId,
                personId: personId,
                amountMinor: amountMinor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entryId,
                required String personId,
                required int amountMinor,
                Value<int> rowid = const Value.absent(),
              }) => SplitSharesCompanion.insert(
                entryId: entryId,
                personId: personId,
                amountMinor: amountMinor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SplitSharesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false, personId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entryId,
                                referencedTable: $$SplitSharesTableReferences
                                    ._entryIdTable(db),
                                referencedColumn: $$SplitSharesTableReferences
                                    ._entryIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (personId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.personId,
                                referencedTable: $$SplitSharesTableReferences
                                    ._personIdTable(db),
                                referencedColumn: $$SplitSharesTableReferences
                                    ._personIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SplitSharesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SplitSharesTable,
      SplitShare,
      $$SplitSharesTableFilterComposer,
      $$SplitSharesTableOrderingComposer,
      $$SplitSharesTableAnnotationComposer,
      $$SplitSharesTableCreateCompanionBuilder,
      $$SplitSharesTableUpdateCompanionBuilder,
      (SplitShare, $$SplitSharesTableReferences),
      SplitShare,
      PrefetchHooks Function({bool entryId, bool personId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$RecurringRulesTableTableManager get recurringRules =>
      $$RecurringRulesTableTableManager(_db, _db.recurringRules);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$HiddenNotesTableTableManager get hiddenNotes =>
      $$HiddenNotesTableTableManager(_db, _db.hiddenNotes);
  $$LearnedNotesTableTableManager get learnedNotes =>
      $$LearnedNotesTableTableManager(_db, _db.learnedNotes);
  $$ReceiptKindsTableTableManager get receiptKinds =>
      $$ReceiptKindsTableTableManager(_db, _db.receiptKinds);
  $$SplitGroupsTableTableManager get splitGroups =>
      $$SplitGroupsTableTableManager(_db, _db.splitGroups);
  $$SplitPeopleTableTableManager get splitPeople =>
      $$SplitPeopleTableTableManager(_db, _db.splitPeople);
  $$SplitEntriesTableTableManager get splitEntries =>
      $$SplitEntriesTableTableManager(_db, _db.splitEntries);
  $$SplitSharesTableTableManager get splitShares =>
      $$SplitSharesTableTableManager(_db, _db.splitShares);
}
