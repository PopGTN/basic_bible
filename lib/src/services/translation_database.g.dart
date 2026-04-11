// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_database.dart';

// ignore_for_file: type=lint
class $TBooksTable extends TBooks with TableInfo<$TBooksTable, TBookEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TBooksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _shortNameMeta = const VerificationMeta(
    'shortName',
  );
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
    'short_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookNumberMeta = const VerificationMeta(
    'bookNumber',
  );
  @override
  late final GeneratedColumn<int> bookNumber = GeneratedColumn<int>(
    'book_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookTypeMeta = const VerificationMeta(
    'bookType',
  );
  @override
  late final GeneratedColumn<int> bookType = GeneratedColumn<int>(
    'book_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<BibleTocLabel>?, String>
  tocLabels = GeneratedColumn<String>(
    'toc_labels',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<List<BibleTocLabel>?>($TBooksTable.$convertertocLabelsn);
  @override
  late final GeneratedColumnWithTypeConverter<List<BibleDocumentBlock>?, String>
  introductionBlocks =
      GeneratedColumn<String>(
        'introduction_blocks',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<BibleDocumentBlock>?>(
        $TBooksTable.$converterintroductionBlocksn,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    shortName,
    bookNumber,
    bookType,
    tocLabels,
    introductionBlocks,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<TBookEntry> instance, {
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
    if (data.containsKey('short_name')) {
      context.handle(
        _shortNameMeta,
        shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta),
      );
    } else if (isInserting) {
      context.missing(_shortNameMeta);
    }
    if (data.containsKey('book_number')) {
      context.handle(
        _bookNumberMeta,
        bookNumber.isAcceptableOrUnknown(data['book_number']!, _bookNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_bookNumberMeta);
    }
    if (data.containsKey('book_type')) {
      context.handle(
        _bookTypeMeta,
        bookType.isAcceptableOrUnknown(data['book_type']!, _bookTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_bookTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TBookEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TBookEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      shortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_name'],
      )!,
      bookNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_number'],
      )!,
      bookType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_type'],
      )!,
      tocLabels: $TBooksTable.$convertertocLabelsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}toc_labels'],
        ),
      ),
      introductionBlocks: $TBooksTable.$converterintroductionBlocksn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}introduction_blocks'],
        ),
      ),
    );
  }

  @override
  $TBooksTable createAlias(String alias) {
    return $TBooksTable(attachedDatabase, alias);
  }

  static TypeConverter<List<BibleTocLabel>, String> $convertertocLabels =
      const BibleTocLabelListConverter();
  static TypeConverter<List<BibleTocLabel>?, String?> $convertertocLabelsn =
      NullAwareTypeConverter.wrap($convertertocLabels);
  static TypeConverter<List<BibleDocumentBlock>, String>
  $converterintroductionBlocks = const BibleDocumentBlockListConverter();
  static TypeConverter<List<BibleDocumentBlock>?, String?>
  $converterintroductionBlocksn = NullAwareTypeConverter.wrap(
    $converterintroductionBlocks,
  );
}

class TBookEntry extends DataClass implements Insertable<TBookEntry> {
  /// 3-letter uppercase book code, e.g. 'GEN'.
  final String id;
  final String name;
  final String shortName;
  final int bookNumber;
  final int bookType;
  final List<BibleTocLabel>? tocLabels;
  final List<BibleDocumentBlock>? introductionBlocks;
  const TBookEntry({
    required this.id,
    required this.name,
    required this.shortName,
    required this.bookNumber,
    required this.bookType,
    this.tocLabels,
    this.introductionBlocks,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['short_name'] = Variable<String>(shortName);
    map['book_number'] = Variable<int>(bookNumber);
    map['book_type'] = Variable<int>(bookType);
    if (!nullToAbsent || tocLabels != null) {
      map['toc_labels'] = Variable<String>(
        $TBooksTable.$convertertocLabelsn.toSql(tocLabels),
      );
    }
    if (!nullToAbsent || introductionBlocks != null) {
      map['introduction_blocks'] = Variable<String>(
        $TBooksTable.$converterintroductionBlocksn.toSql(introductionBlocks),
      );
    }
    return map;
  }

  TBooksCompanion toCompanion(bool nullToAbsent) {
    return TBooksCompanion(
      id: Value(id),
      name: Value(name),
      shortName: Value(shortName),
      bookNumber: Value(bookNumber),
      bookType: Value(bookType),
      tocLabels: tocLabels == null && nullToAbsent
          ? const Value.absent()
          : Value(tocLabels),
      introductionBlocks: introductionBlocks == null && nullToAbsent
          ? const Value.absent()
          : Value(introductionBlocks),
    );
  }

  factory TBookEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TBookEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      shortName: serializer.fromJson<String>(json['shortName']),
      bookNumber: serializer.fromJson<int>(json['bookNumber']),
      bookType: serializer.fromJson<int>(json['bookType']),
      tocLabels: serializer.fromJson<List<BibleTocLabel>?>(json['tocLabels']),
      introductionBlocks: serializer.fromJson<List<BibleDocumentBlock>?>(
        json['introductionBlocks'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'shortName': serializer.toJson<String>(shortName),
      'bookNumber': serializer.toJson<int>(bookNumber),
      'bookType': serializer.toJson<int>(bookType),
      'tocLabels': serializer.toJson<List<BibleTocLabel>?>(tocLabels),
      'introductionBlocks': serializer.toJson<List<BibleDocumentBlock>?>(
        introductionBlocks,
      ),
    };
  }

  TBookEntry copyWith({
    String? id,
    String? name,
    String? shortName,
    int? bookNumber,
    int? bookType,
    Value<List<BibleTocLabel>?> tocLabels = const Value.absent(),
    Value<List<BibleDocumentBlock>?> introductionBlocks = const Value.absent(),
  }) => TBookEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    shortName: shortName ?? this.shortName,
    bookNumber: bookNumber ?? this.bookNumber,
    bookType: bookType ?? this.bookType,
    tocLabels: tocLabels.present ? tocLabels.value : this.tocLabels,
    introductionBlocks: introductionBlocks.present
        ? introductionBlocks.value
        : this.introductionBlocks,
  );
  TBookEntry copyWithCompanion(TBooksCompanion data) {
    return TBookEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
      bookNumber: data.bookNumber.present
          ? data.bookNumber.value
          : this.bookNumber,
      bookType: data.bookType.present ? data.bookType.value : this.bookType,
      tocLabels: data.tocLabels.present ? data.tocLabels.value : this.tocLabels,
      introductionBlocks: data.introductionBlocks.present
          ? data.introductionBlocks.value
          : this.introductionBlocks,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TBookEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('bookNumber: $bookNumber, ')
          ..write('bookType: $bookType, ')
          ..write('tocLabels: $tocLabels, ')
          ..write('introductionBlocks: $introductionBlocks')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    shortName,
    bookNumber,
    bookType,
    tocLabels,
    introductionBlocks,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TBookEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.shortName == this.shortName &&
          other.bookNumber == this.bookNumber &&
          other.bookType == this.bookType &&
          other.tocLabels == this.tocLabels &&
          other.introductionBlocks == this.introductionBlocks);
}

class TBooksCompanion extends UpdateCompanion<TBookEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> shortName;
  final Value<int> bookNumber;
  final Value<int> bookType;
  final Value<List<BibleTocLabel>?> tocLabels;
  final Value<List<BibleDocumentBlock>?> introductionBlocks;
  final Value<int> rowid;
  const TBooksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.shortName = const Value.absent(),
    this.bookNumber = const Value.absent(),
    this.bookType = const Value.absent(),
    this.tocLabels = const Value.absent(),
    this.introductionBlocks = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TBooksCompanion.insert({
    required String id,
    required String name,
    required String shortName,
    required int bookNumber,
    required int bookType,
    this.tocLabels = const Value.absent(),
    this.introductionBlocks = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       shortName = Value(shortName),
       bookNumber = Value(bookNumber),
       bookType = Value(bookType);
  static Insertable<TBookEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? shortName,
    Expression<int>? bookNumber,
    Expression<int>? bookType,
    Expression<String>? tocLabels,
    Expression<String>? introductionBlocks,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (shortName != null) 'short_name': shortName,
      if (bookNumber != null) 'book_number': bookNumber,
      if (bookType != null) 'book_type': bookType,
      if (tocLabels != null) 'toc_labels': tocLabels,
      if (introductionBlocks != null) 'introduction_blocks': introductionBlocks,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TBooksCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? shortName,
    Value<int>? bookNumber,
    Value<int>? bookType,
    Value<List<BibleTocLabel>?>? tocLabels,
    Value<List<BibleDocumentBlock>?>? introductionBlocks,
    Value<int>? rowid,
  }) {
    return TBooksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      bookNumber: bookNumber ?? this.bookNumber,
      bookType: bookType ?? this.bookType,
      tocLabels: tocLabels ?? this.tocLabels,
      introductionBlocks: introductionBlocks ?? this.introductionBlocks,
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
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (bookNumber.present) {
      map['book_number'] = Variable<int>(bookNumber.value);
    }
    if (bookType.present) {
      map['book_type'] = Variable<int>(bookType.value);
    }
    if (tocLabels.present) {
      map['toc_labels'] = Variable<String>(
        $TBooksTable.$convertertocLabelsn.toSql(tocLabels.value),
      );
    }
    if (introductionBlocks.present) {
      map['introduction_blocks'] = Variable<String>(
        $TBooksTable.$converterintroductionBlocksn.toSql(
          introductionBlocks.value,
        ),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TBooksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('bookNumber: $bookNumber, ')
          ..write('bookType: $bookType, ')
          ..write('tocLabels: $tocLabels, ')
          ..write('introductionBlocks: $introductionBlocks, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TChaptersTable extends TChapters
    with TableInfo<$TChaptersTable, TChapterEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TChaptersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES t_books (id)',
    ),
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<BibleDocumentBlock>?, String>
  blocks = GeneratedColumn<String>(
    'blocks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<List<BibleDocumentBlock>?>($TChaptersTable.$converterblocksn);
  @override
  List<GeneratedColumn> get $columns => [id, bookId, number, blocks];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<TChapterEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {bookId, number},
  ];
  @override
  TChapterEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TChapterEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      blocks: $TChaptersTable.$converterblocksn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}blocks'],
        ),
      ),
    );
  }

  @override
  $TChaptersTable createAlias(String alias) {
    return $TChaptersTable(attachedDatabase, alias);
  }

  static TypeConverter<List<BibleDocumentBlock>, String> $converterblocks =
      const BibleDocumentBlockListConverter();
  static TypeConverter<List<BibleDocumentBlock>?, String?> $converterblocksn =
      NullAwareTypeConverter.wrap($converterblocks);
}

class TChapterEntry extends DataClass implements Insertable<TChapterEntry> {
  final int id;
  final String bookId;
  final int number;
  final List<BibleDocumentBlock>? blocks;
  const TChapterEntry({
    required this.id,
    required this.bookId,
    required this.number,
    this.blocks,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<String>(bookId);
    map['number'] = Variable<int>(number);
    if (!nullToAbsent || blocks != null) {
      map['blocks'] = Variable<String>(
        $TChaptersTable.$converterblocksn.toSql(blocks),
      );
    }
    return map;
  }

  TChaptersCompanion toCompanion(bool nullToAbsent) {
    return TChaptersCompanion(
      id: Value(id),
      bookId: Value(bookId),
      number: Value(number),
      blocks: blocks == null && nullToAbsent
          ? const Value.absent()
          : Value(blocks),
    );
  }

  factory TChapterEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TChapterEntry(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      number: serializer.fromJson<int>(json['number']),
      blocks: serializer.fromJson<List<BibleDocumentBlock>?>(json['blocks']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<String>(bookId),
      'number': serializer.toJson<int>(number),
      'blocks': serializer.toJson<List<BibleDocumentBlock>?>(blocks),
    };
  }

  TChapterEntry copyWith({
    int? id,
    String? bookId,
    int? number,
    Value<List<BibleDocumentBlock>?> blocks = const Value.absent(),
  }) => TChapterEntry(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    number: number ?? this.number,
    blocks: blocks.present ? blocks.value : this.blocks,
  );
  TChapterEntry copyWithCompanion(TChaptersCompanion data) {
    return TChapterEntry(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      number: data.number.present ? data.number.value : this.number,
      blocks: data.blocks.present ? data.blocks.value : this.blocks,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TChapterEntry(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('number: $number, ')
          ..write('blocks: $blocks')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, number, blocks);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TChapterEntry &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.number == this.number &&
          other.blocks == this.blocks);
}

class TChaptersCompanion extends UpdateCompanion<TChapterEntry> {
  final Value<int> id;
  final Value<String> bookId;
  final Value<int> number;
  final Value<List<BibleDocumentBlock>?> blocks;
  const TChaptersCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.number = const Value.absent(),
    this.blocks = const Value.absent(),
  });
  TChaptersCompanion.insert({
    this.id = const Value.absent(),
    required String bookId,
    required int number,
    this.blocks = const Value.absent(),
  }) : bookId = Value(bookId),
       number = Value(number);
  static Insertable<TChapterEntry> custom({
    Expression<int>? id,
    Expression<String>? bookId,
    Expression<int>? number,
    Expression<String>? blocks,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (number != null) 'number': number,
      if (blocks != null) 'blocks': blocks,
    });
  }

  TChaptersCompanion copyWith({
    Value<int>? id,
    Value<String>? bookId,
    Value<int>? number,
    Value<List<BibleDocumentBlock>?>? blocks,
  }) {
    return TChaptersCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      number: number ?? this.number,
      blocks: blocks ?? this.blocks,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (blocks.present) {
      map['blocks'] = Variable<String>(
        $TChaptersTable.$converterblocksn.toSql(blocks.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TChaptersCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('number: $number, ')
          ..write('blocks: $blocks')
          ..write(')'))
        .toString();
  }
}

class $TVersesTable extends TVerses with TableInfo<$TVersesTable, TVerseEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TVersesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES t_chapters (id)',
    ),
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseTextMeta = const VerificationMeta(
    'verseText',
  );
  @override
  late final GeneratedColumn<String> verseText = GeneratedColumn<String>(
    'verse_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> notes =
      GeneratedColumn<String>(
        'notes',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>($TVersesTable.$converternotesn);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String>
  references = GeneratedColumn<String>(
    'references',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<List<String>?>($TVersesTable.$converterreferencesn);
  @override
  late final GeneratedColumnWithTypeConverter<List<BibleVerseSpan>?, String>
  spans = GeneratedColumn<String>(
    'spans',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<List<BibleVerseSpan>?>($TVersesTable.$converterspansn);
  @override
  late final GeneratedColumnWithTypeConverter<List<BibleFootnote>?, String>
  footnotes = GeneratedColumn<String>(
    'footnotes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<List<BibleFootnote>?>($TVersesTable.$converterfootnotesn);
  @override
  late final GeneratedColumnWithTypeConverter<
    List<BibleCrossReference>?,
    String
  >
  crossReferences =
      GeneratedColumn<String>(
        'cross_references',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<BibleCrossReference>?>(
        $TVersesTable.$convertercrossReferencesn,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chapterId,
    number,
    verseText,
    notes,
    references,
    spans,
    footnotes,
    crossReferences,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_verses';
  @override
  VerificationContext validateIntegrity(
    Insertable<TVerseEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('verse_text')) {
      context.handle(
        _verseTextMeta,
        verseText.isAcceptableOrUnknown(data['verse_text']!, _verseTextMeta),
      );
    } else if (isInserting) {
      context.missing(_verseTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {chapterId, number},
  ];
  @override
  TVerseEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TVerseEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      verseText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verse_text'],
      )!,
      notes: $TVersesTable.$converternotesn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}notes'],
        ),
      ),
      references: $TVersesTable.$converterreferencesn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}references'],
        ),
      ),
      spans: $TVersesTable.$converterspansn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}spans'],
        ),
      ),
      footnotes: $TVersesTable.$converterfootnotesn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}footnotes'],
        ),
      ),
      crossReferences: $TVersesTable.$convertercrossReferencesn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cross_references'],
        ),
      ),
    );
  }

  @override
  $TVersesTable createAlias(String alias) {
    return $TVersesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converternotes =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converternotesn =
      NullAwareTypeConverter.wrap($converternotes);
  static TypeConverter<List<String>, String> $converterreferences =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterreferencesn =
      NullAwareTypeConverter.wrap($converterreferences);
  static TypeConverter<List<BibleVerseSpan>, String> $converterspans =
      const BibleVerseSpanListConverter();
  static TypeConverter<List<BibleVerseSpan>?, String?> $converterspansn =
      NullAwareTypeConverter.wrap($converterspans);
  static TypeConverter<List<BibleFootnote>, String> $converterfootnotes =
      const BibleFootnoteListConverter();
  static TypeConverter<List<BibleFootnote>?, String?> $converterfootnotesn =
      NullAwareTypeConverter.wrap($converterfootnotes);
  static TypeConverter<List<BibleCrossReference>, String>
  $convertercrossReferences = const BibleCrossReferenceListConverter();
  static TypeConverter<List<BibleCrossReference>?, String?>
  $convertercrossReferencesn = NullAwareTypeConverter.wrap(
    $convertercrossReferences,
  );
}

class TVerseEntry extends DataClass implements Insertable<TVerseEntry> {
  final int id;
  final int chapterId;
  final int number;
  final String verseText;
  final List<String>? notes;
  final List<String>? references;
  final List<BibleVerseSpan>? spans;
  final List<BibleFootnote>? footnotes;
  final List<BibleCrossReference>? crossReferences;
  const TVerseEntry({
    required this.id,
    required this.chapterId,
    required this.number,
    required this.verseText,
    this.notes,
    this.references,
    this.spans,
    this.footnotes,
    this.crossReferences,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chapter_id'] = Variable<int>(chapterId);
    map['number'] = Variable<int>(number);
    map['verse_text'] = Variable<String>(verseText);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(
        $TVersesTable.$converternotesn.toSql(notes),
      );
    }
    if (!nullToAbsent || references != null) {
      map['references'] = Variable<String>(
        $TVersesTable.$converterreferencesn.toSql(references),
      );
    }
    if (!nullToAbsent || spans != null) {
      map['spans'] = Variable<String>(
        $TVersesTable.$converterspansn.toSql(spans),
      );
    }
    if (!nullToAbsent || footnotes != null) {
      map['footnotes'] = Variable<String>(
        $TVersesTable.$converterfootnotesn.toSql(footnotes),
      );
    }
    if (!nullToAbsent || crossReferences != null) {
      map['cross_references'] = Variable<String>(
        $TVersesTable.$convertercrossReferencesn.toSql(crossReferences),
      );
    }
    return map;
  }

  TVersesCompanion toCompanion(bool nullToAbsent) {
    return TVersesCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      number: Value(number),
      verseText: Value(verseText),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      references: references == null && nullToAbsent
          ? const Value.absent()
          : Value(references),
      spans: spans == null && nullToAbsent
          ? const Value.absent()
          : Value(spans),
      footnotes: footnotes == null && nullToAbsent
          ? const Value.absent()
          : Value(footnotes),
      crossReferences: crossReferences == null && nullToAbsent
          ? const Value.absent()
          : Value(crossReferences),
    );
  }

  factory TVerseEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TVerseEntry(
      id: serializer.fromJson<int>(json['id']),
      chapterId: serializer.fromJson<int>(json['chapterId']),
      number: serializer.fromJson<int>(json['number']),
      verseText: serializer.fromJson<String>(json['verseText']),
      notes: serializer.fromJson<List<String>?>(json['notes']),
      references: serializer.fromJson<List<String>?>(json['references']),
      spans: serializer.fromJson<List<BibleVerseSpan>?>(json['spans']),
      footnotes: serializer.fromJson<List<BibleFootnote>?>(json['footnotes']),
      crossReferences: serializer.fromJson<List<BibleCrossReference>?>(
        json['crossReferences'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chapterId': serializer.toJson<int>(chapterId),
      'number': serializer.toJson<int>(number),
      'verseText': serializer.toJson<String>(verseText),
      'notes': serializer.toJson<List<String>?>(notes),
      'references': serializer.toJson<List<String>?>(references),
      'spans': serializer.toJson<List<BibleVerseSpan>?>(spans),
      'footnotes': serializer.toJson<List<BibleFootnote>?>(footnotes),
      'crossReferences': serializer.toJson<List<BibleCrossReference>?>(
        crossReferences,
      ),
    };
  }

  TVerseEntry copyWith({
    int? id,
    int? chapterId,
    int? number,
    String? verseText,
    Value<List<String>?> notes = const Value.absent(),
    Value<List<String>?> references = const Value.absent(),
    Value<List<BibleVerseSpan>?> spans = const Value.absent(),
    Value<List<BibleFootnote>?> footnotes = const Value.absent(),
    Value<List<BibleCrossReference>?> crossReferences = const Value.absent(),
  }) => TVerseEntry(
    id: id ?? this.id,
    chapterId: chapterId ?? this.chapterId,
    number: number ?? this.number,
    verseText: verseText ?? this.verseText,
    notes: notes.present ? notes.value : this.notes,
    references: references.present ? references.value : this.references,
    spans: spans.present ? spans.value : this.spans,
    footnotes: footnotes.present ? footnotes.value : this.footnotes,
    crossReferences: crossReferences.present
        ? crossReferences.value
        : this.crossReferences,
  );
  TVerseEntry copyWithCompanion(TVersesCompanion data) {
    return TVerseEntry(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      number: data.number.present ? data.number.value : this.number,
      verseText: data.verseText.present ? data.verseText.value : this.verseText,
      notes: data.notes.present ? data.notes.value : this.notes,
      references: data.references.present
          ? data.references.value
          : this.references,
      spans: data.spans.present ? data.spans.value : this.spans,
      footnotes: data.footnotes.present ? data.footnotes.value : this.footnotes,
      crossReferences: data.crossReferences.present
          ? data.crossReferences.value
          : this.crossReferences,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TVerseEntry(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('number: $number, ')
          ..write('verseText: $verseText, ')
          ..write('notes: $notes, ')
          ..write('references: $references, ')
          ..write('spans: $spans, ')
          ..write('footnotes: $footnotes, ')
          ..write('crossReferences: $crossReferences')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chapterId,
    number,
    verseText,
    notes,
    references,
    spans,
    footnotes,
    crossReferences,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TVerseEntry &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.number == this.number &&
          other.verseText == this.verseText &&
          other.notes == this.notes &&
          other.references == this.references &&
          other.spans == this.spans &&
          other.footnotes == this.footnotes &&
          other.crossReferences == this.crossReferences);
}

class TVersesCompanion extends UpdateCompanion<TVerseEntry> {
  final Value<int> id;
  final Value<int> chapterId;
  final Value<int> number;
  final Value<String> verseText;
  final Value<List<String>?> notes;
  final Value<List<String>?> references;
  final Value<List<BibleVerseSpan>?> spans;
  final Value<List<BibleFootnote>?> footnotes;
  final Value<List<BibleCrossReference>?> crossReferences;
  const TVersesCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.number = const Value.absent(),
    this.verseText = const Value.absent(),
    this.notes = const Value.absent(),
    this.references = const Value.absent(),
    this.spans = const Value.absent(),
    this.footnotes = const Value.absent(),
    this.crossReferences = const Value.absent(),
  });
  TVersesCompanion.insert({
    this.id = const Value.absent(),
    required int chapterId,
    required int number,
    required String verseText,
    this.notes = const Value.absent(),
    this.references = const Value.absent(),
    this.spans = const Value.absent(),
    this.footnotes = const Value.absent(),
    this.crossReferences = const Value.absent(),
  }) : chapterId = Value(chapterId),
       number = Value(number),
       verseText = Value(verseText);
  static Insertable<TVerseEntry> custom({
    Expression<int>? id,
    Expression<int>? chapterId,
    Expression<int>? number,
    Expression<String>? verseText,
    Expression<String>? notes,
    Expression<String>? references,
    Expression<String>? spans,
    Expression<String>? footnotes,
    Expression<String>? crossReferences,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (number != null) 'number': number,
      if (verseText != null) 'verse_text': verseText,
      if (notes != null) 'notes': notes,
      if (references != null) 'references': references,
      if (spans != null) 'spans': spans,
      if (footnotes != null) 'footnotes': footnotes,
      if (crossReferences != null) 'cross_references': crossReferences,
    });
  }

  TVersesCompanion copyWith({
    Value<int>? id,
    Value<int>? chapterId,
    Value<int>? number,
    Value<String>? verseText,
    Value<List<String>?>? notes,
    Value<List<String>?>? references,
    Value<List<BibleVerseSpan>?>? spans,
    Value<List<BibleFootnote>?>? footnotes,
    Value<List<BibleCrossReference>?>? crossReferences,
  }) {
    return TVersesCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      number: number ?? this.number,
      verseText: verseText ?? this.verseText,
      notes: notes ?? this.notes,
      references: references ?? this.references,
      spans: spans ?? this.spans,
      footnotes: footnotes ?? this.footnotes,
      crossReferences: crossReferences ?? this.crossReferences,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (verseText.present) {
      map['verse_text'] = Variable<String>(verseText.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(
        $TVersesTable.$converternotesn.toSql(notes.value),
      );
    }
    if (references.present) {
      map['references'] = Variable<String>(
        $TVersesTable.$converterreferencesn.toSql(references.value),
      );
    }
    if (spans.present) {
      map['spans'] = Variable<String>(
        $TVersesTable.$converterspansn.toSql(spans.value),
      );
    }
    if (footnotes.present) {
      map['footnotes'] = Variable<String>(
        $TVersesTable.$converterfootnotesn.toSql(footnotes.value),
      );
    }
    if (crossReferences.present) {
      map['cross_references'] = Variable<String>(
        $TVersesTable.$convertercrossReferencesn.toSql(crossReferences.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TVersesCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('number: $number, ')
          ..write('verseText: $verseText, ')
          ..write('notes: $notes, ')
          ..write('references: $references, ')
          ..write('spans: $spans, ')
          ..write('footnotes: $footnotes, ')
          ..write('crossReferences: $crossReferences')
          ..write(')'))
        .toString();
  }
}

abstract class _$TranslationDatabase extends GeneratedDatabase {
  _$TranslationDatabase(QueryExecutor e) : super(e);
  $TranslationDatabaseManager get managers => $TranslationDatabaseManager(this);
  late final $TBooksTable tBooks = $TBooksTable(this);
  late final $TChaptersTable tChapters = $TChaptersTable(this);
  late final $TVersesTable tVerses = $TVersesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tBooks,
    tChapters,
    tVerses,
  ];
}

typedef $$TBooksTableCreateCompanionBuilder =
    TBooksCompanion Function({
      required String id,
      required String name,
      required String shortName,
      required int bookNumber,
      required int bookType,
      Value<List<BibleTocLabel>?> tocLabels,
      Value<List<BibleDocumentBlock>?> introductionBlocks,
      Value<int> rowid,
    });
typedef $$TBooksTableUpdateCompanionBuilder =
    TBooksCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> shortName,
      Value<int> bookNumber,
      Value<int> bookType,
      Value<List<BibleTocLabel>?> tocLabels,
      Value<List<BibleDocumentBlock>?> introductionBlocks,
      Value<int> rowid,
    });

final class $$TBooksTableReferences
    extends BaseReferences<_$TranslationDatabase, $TBooksTable, TBookEntry> {
  $$TBooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TChaptersTable, List<TChapterEntry>>
  _tChaptersRefsTable(_$TranslationDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.tChapters,
        aliasName: $_aliasNameGenerator(db.tBooks.id, db.tChapters.bookId),
      );

  $$TChaptersTableProcessedTableManager get tChaptersRefs {
    final manager = $$TChaptersTableTableManager(
      $_db,
      $_db.tChapters,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tChaptersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TBooksTableFilterComposer
    extends Composer<_$TranslationDatabase, $TBooksTable> {
  $$TBooksTableFilterComposer({
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

  ColumnFilters<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bookNumber => $composableBuilder(
    column: $table.bookNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bookType => $composableBuilder(
    column: $table.bookType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<BibleTocLabel>?,
    List<BibleTocLabel>,
    String
  >
  get tocLabels => $composableBuilder(
    column: $table.tocLabels,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<BibleDocumentBlock>?,
    List<BibleDocumentBlock>,
    String
  >
  get introductionBlocks => $composableBuilder(
    column: $table.introductionBlocks,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> tChaptersRefs(
    Expression<bool> Function($$TChaptersTableFilterComposer f) f,
  ) {
    final $$TChaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tChapters,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TChaptersTableFilterComposer(
            $db: $db,
            $table: $db.tChapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TBooksTableOrderingComposer
    extends Composer<_$TranslationDatabase, $TBooksTable> {
  $$TBooksTableOrderingComposer({
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

  ColumnOrderings<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bookNumber => $composableBuilder(
    column: $table.bookNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bookType => $composableBuilder(
    column: $table.bookType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tocLabels => $composableBuilder(
    column: $table.tocLabels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get introductionBlocks => $composableBuilder(
    column: $table.introductionBlocks,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TBooksTableAnnotationComposer
    extends Composer<_$TranslationDatabase, $TBooksTable> {
  $$TBooksTableAnnotationComposer({
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

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  GeneratedColumn<int> get bookNumber => $composableBuilder(
    column: $table.bookNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bookType =>
      $composableBuilder(column: $table.bookType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<BibleTocLabel>?, String>
  get tocLabels =>
      $composableBuilder(column: $table.tocLabels, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<BibleDocumentBlock>?, String>
  get introductionBlocks => $composableBuilder(
    column: $table.introductionBlocks,
    builder: (column) => column,
  );

  Expression<T> tChaptersRefs<T extends Object>(
    Expression<T> Function($$TChaptersTableAnnotationComposer a) f,
  ) {
    final $$TChaptersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tChapters,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TChaptersTableAnnotationComposer(
            $db: $db,
            $table: $db.tChapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TBooksTableTableManager
    extends
        RootTableManager<
          _$TranslationDatabase,
          $TBooksTable,
          TBookEntry,
          $$TBooksTableFilterComposer,
          $$TBooksTableOrderingComposer,
          $$TBooksTableAnnotationComposer,
          $$TBooksTableCreateCompanionBuilder,
          $$TBooksTableUpdateCompanionBuilder,
          (TBookEntry, $$TBooksTableReferences),
          TBookEntry,
          PrefetchHooks Function({bool tChaptersRefs})
        > {
  $$TBooksTableTableManager(_$TranslationDatabase db, $TBooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> shortName = const Value.absent(),
                Value<int> bookNumber = const Value.absent(),
                Value<int> bookType = const Value.absent(),
                Value<List<BibleTocLabel>?> tocLabels = const Value.absent(),
                Value<List<BibleDocumentBlock>?> introductionBlocks =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TBooksCompanion(
                id: id,
                name: name,
                shortName: shortName,
                bookNumber: bookNumber,
                bookType: bookType,
                tocLabels: tocLabels,
                introductionBlocks: introductionBlocks,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String shortName,
                required int bookNumber,
                required int bookType,
                Value<List<BibleTocLabel>?> tocLabels = const Value.absent(),
                Value<List<BibleDocumentBlock>?> introductionBlocks =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TBooksCompanion.insert(
                id: id,
                name: name,
                shortName: shortName,
                bookNumber: bookNumber,
                bookType: bookType,
                tocLabels: tocLabels,
                introductionBlocks: introductionBlocks,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TBooksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({tChaptersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tChaptersRefs) db.tChapters],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tChaptersRefs)
                    await $_getPrefetchedData<
                      TBookEntry,
                      $TBooksTable,
                      TChapterEntry
                    >(
                      currentTable: table,
                      referencedTable: $$TBooksTableReferences
                          ._tChaptersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TBooksTableReferences(db, table, p0).tChaptersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.bookId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TBooksTableProcessedTableManager =
    ProcessedTableManager<
      _$TranslationDatabase,
      $TBooksTable,
      TBookEntry,
      $$TBooksTableFilterComposer,
      $$TBooksTableOrderingComposer,
      $$TBooksTableAnnotationComposer,
      $$TBooksTableCreateCompanionBuilder,
      $$TBooksTableUpdateCompanionBuilder,
      (TBookEntry, $$TBooksTableReferences),
      TBookEntry,
      PrefetchHooks Function({bool tChaptersRefs})
    >;
typedef $$TChaptersTableCreateCompanionBuilder =
    TChaptersCompanion Function({
      Value<int> id,
      required String bookId,
      required int number,
      Value<List<BibleDocumentBlock>?> blocks,
    });
typedef $$TChaptersTableUpdateCompanionBuilder =
    TChaptersCompanion Function({
      Value<int> id,
      Value<String> bookId,
      Value<int> number,
      Value<List<BibleDocumentBlock>?> blocks,
    });

final class $$TChaptersTableReferences
    extends
        BaseReferences<_$TranslationDatabase, $TChaptersTable, TChapterEntry> {
  $$TChaptersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TBooksTable _bookIdTable(_$TranslationDatabase db) => db.tBooks
      .createAlias($_aliasNameGenerator(db.tChapters.bookId, db.tBooks.id));

  $$TBooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$TBooksTableTableManager(
      $_db,
      $_db.tBooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TVersesTable, List<TVerseEntry>>
  _tVersesRefsTable(_$TranslationDatabase db) => MultiTypedResultKey.fromTable(
    db.tVerses,
    aliasName: $_aliasNameGenerator(db.tChapters.id, db.tVerses.chapterId),
  );

  $$TVersesTableProcessedTableManager get tVersesRefs {
    final manager = $$TVersesTableTableManager(
      $_db,
      $_db.tVerses,
    ).filter((f) => f.chapterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tVersesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TChaptersTableFilterComposer
    extends Composer<_$TranslationDatabase, $TChaptersTable> {
  $$TChaptersTableFilterComposer({
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

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<BibleDocumentBlock>?,
    List<BibleDocumentBlock>,
    String
  >
  get blocks => $composableBuilder(
    column: $table.blocks,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$TBooksTableFilterComposer get bookId {
    final $$TBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.tBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TBooksTableFilterComposer(
            $db: $db,
            $table: $db.tBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tVersesRefs(
    Expression<bool> Function($$TVersesTableFilterComposer f) f,
  ) {
    final $$TVersesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tVerses,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TVersesTableFilterComposer(
            $db: $db,
            $table: $db.tVerses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TChaptersTableOrderingComposer
    extends Composer<_$TranslationDatabase, $TChaptersTable> {
  $$TChaptersTableOrderingComposer({
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

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blocks => $composableBuilder(
    column: $table.blocks,
    builder: (column) => ColumnOrderings(column),
  );

  $$TBooksTableOrderingComposer get bookId {
    final $$TBooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.tBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TBooksTableOrderingComposer(
            $db: $db,
            $table: $db.tBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TChaptersTableAnnotationComposer
    extends Composer<_$TranslationDatabase, $TChaptersTable> {
  $$TChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<BibleDocumentBlock>?, String>
  get blocks =>
      $composableBuilder(column: $table.blocks, builder: (column) => column);

  $$TBooksTableAnnotationComposer get bookId {
    final $$TBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.tBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.tBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tVersesRefs<T extends Object>(
    Expression<T> Function($$TVersesTableAnnotationComposer a) f,
  ) {
    final $$TVersesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tVerses,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TVersesTableAnnotationComposer(
            $db: $db,
            $table: $db.tVerses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TChaptersTableTableManager
    extends
        RootTableManager<
          _$TranslationDatabase,
          $TChaptersTable,
          TChapterEntry,
          $$TChaptersTableFilterComposer,
          $$TChaptersTableOrderingComposer,
          $$TChaptersTableAnnotationComposer,
          $$TChaptersTableCreateCompanionBuilder,
          $$TChaptersTableUpdateCompanionBuilder,
          (TChapterEntry, $$TChaptersTableReferences),
          TChapterEntry,
          PrefetchHooks Function({bool bookId, bool tVersesRefs})
        > {
  $$TChaptersTableTableManager(_$TranslationDatabase db, $TChaptersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<List<BibleDocumentBlock>?> blocks = const Value.absent(),
              }) => TChaptersCompanion(
                id: id,
                bookId: bookId,
                number: number,
                blocks: blocks,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bookId,
                required int number,
                Value<List<BibleDocumentBlock>?> blocks = const Value.absent(),
              }) => TChaptersCompanion.insert(
                id: id,
                bookId: bookId,
                number: number,
                blocks: blocks,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TChaptersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false, tVersesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tVersesRefs) db.tVerses],
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
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$TChaptersTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$TChaptersTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tVersesRefs)
                    await $_getPrefetchedData<
                      TChapterEntry,
                      $TChaptersTable,
                      TVerseEntry
                    >(
                      currentTable: table,
                      referencedTable: $$TChaptersTableReferences
                          ._tVersesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TChaptersTableReferences(db, table, p0).tVersesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.chapterId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$TranslationDatabase,
      $TChaptersTable,
      TChapterEntry,
      $$TChaptersTableFilterComposer,
      $$TChaptersTableOrderingComposer,
      $$TChaptersTableAnnotationComposer,
      $$TChaptersTableCreateCompanionBuilder,
      $$TChaptersTableUpdateCompanionBuilder,
      (TChapterEntry, $$TChaptersTableReferences),
      TChapterEntry,
      PrefetchHooks Function({bool bookId, bool tVersesRefs})
    >;
typedef $$TVersesTableCreateCompanionBuilder =
    TVersesCompanion Function({
      Value<int> id,
      required int chapterId,
      required int number,
      required String verseText,
      Value<List<String>?> notes,
      Value<List<String>?> references,
      Value<List<BibleVerseSpan>?> spans,
      Value<List<BibleFootnote>?> footnotes,
      Value<List<BibleCrossReference>?> crossReferences,
    });
typedef $$TVersesTableUpdateCompanionBuilder =
    TVersesCompanion Function({
      Value<int> id,
      Value<int> chapterId,
      Value<int> number,
      Value<String> verseText,
      Value<List<String>?> notes,
      Value<List<String>?> references,
      Value<List<BibleVerseSpan>?> spans,
      Value<List<BibleFootnote>?> footnotes,
      Value<List<BibleCrossReference>?> crossReferences,
    });

final class $$TVersesTableReferences
    extends BaseReferences<_$TranslationDatabase, $TVersesTable, TVerseEntry> {
  $$TVersesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TChaptersTable _chapterIdTable(_$TranslationDatabase db) => db
      .tChapters
      .createAlias($_aliasNameGenerator(db.tVerses.chapterId, db.tChapters.id));

  $$TChaptersTableProcessedTableManager get chapterId {
    final $_column = $_itemColumn<int>('chapter_id')!;

    final manager = $$TChaptersTableTableManager(
      $_db,
      $_db.tChapters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TVersesTableFilterComposer
    extends Composer<_$TranslationDatabase, $TVersesTable> {
  $$TVersesTableFilterComposer({
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

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verseText => $composableBuilder(
    column: $table.verseText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get references => $composableBuilder(
    column: $table.references,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<BibleVerseSpan>?,
    List<BibleVerseSpan>,
    String
  >
  get spans => $composableBuilder(
    column: $table.spans,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<BibleFootnote>?,
    List<BibleFootnote>,
    String
  >
  get footnotes => $composableBuilder(
    column: $table.footnotes,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<BibleCrossReference>?,
    List<BibleCrossReference>,
    String
  >
  get crossReferences => $composableBuilder(
    column: $table.crossReferences,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$TChaptersTableFilterComposer get chapterId {
    final $$TChaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.tChapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TChaptersTableFilterComposer(
            $db: $db,
            $table: $db.tChapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TVersesTableOrderingComposer
    extends Composer<_$TranslationDatabase, $TVersesTable> {
  $$TVersesTableOrderingComposer({
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

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verseText => $composableBuilder(
    column: $table.verseText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get references => $composableBuilder(
    column: $table.references,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spans => $composableBuilder(
    column: $table.spans,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get footnotes => $composableBuilder(
    column: $table.footnotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get crossReferences => $composableBuilder(
    column: $table.crossReferences,
    builder: (column) => ColumnOrderings(column),
  );

  $$TChaptersTableOrderingComposer get chapterId {
    final $$TChaptersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.tChapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TChaptersTableOrderingComposer(
            $db: $db,
            $table: $db.tChapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TVersesTableAnnotationComposer
    extends Composer<_$TranslationDatabase, $TVersesTable> {
  $$TVersesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get verseText =>
      $composableBuilder(column: $table.verseText, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get references =>
      $composableBuilder(
        column: $table.references,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<BibleVerseSpan>?, String> get spans =>
      $composableBuilder(column: $table.spans, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<BibleFootnote>?, String>
  get footnotes =>
      $composableBuilder(column: $table.footnotes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<BibleCrossReference>?, String>
  get crossReferences => $composableBuilder(
    column: $table.crossReferences,
    builder: (column) => column,
  );

  $$TChaptersTableAnnotationComposer get chapterId {
    final $$TChaptersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.tChapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TChaptersTableAnnotationComposer(
            $db: $db,
            $table: $db.tChapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TVersesTableTableManager
    extends
        RootTableManager<
          _$TranslationDatabase,
          $TVersesTable,
          TVerseEntry,
          $$TVersesTableFilterComposer,
          $$TVersesTableOrderingComposer,
          $$TVersesTableAnnotationComposer,
          $$TVersesTableCreateCompanionBuilder,
          $$TVersesTableUpdateCompanionBuilder,
          (TVerseEntry, $$TVersesTableReferences),
          TVerseEntry,
          PrefetchHooks Function({bool chapterId})
        > {
  $$TVersesTableTableManager(_$TranslationDatabase db, $TVersesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TVersesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TVersesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TVersesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> chapterId = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<String> verseText = const Value.absent(),
                Value<List<String>?> notes = const Value.absent(),
                Value<List<String>?> references = const Value.absent(),
                Value<List<BibleVerseSpan>?> spans = const Value.absent(),
                Value<List<BibleFootnote>?> footnotes = const Value.absent(),
                Value<List<BibleCrossReference>?> crossReferences =
                    const Value.absent(),
              }) => TVersesCompanion(
                id: id,
                chapterId: chapterId,
                number: number,
                verseText: verseText,
                notes: notes,
                references: references,
                spans: spans,
                footnotes: footnotes,
                crossReferences: crossReferences,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int chapterId,
                required int number,
                required String verseText,
                Value<List<String>?> notes = const Value.absent(),
                Value<List<String>?> references = const Value.absent(),
                Value<List<BibleVerseSpan>?> spans = const Value.absent(),
                Value<List<BibleFootnote>?> footnotes = const Value.absent(),
                Value<List<BibleCrossReference>?> crossReferences =
                    const Value.absent(),
              }) => TVersesCompanion.insert(
                id: id,
                chapterId: chapterId,
                number: number,
                verseText: verseText,
                notes: notes,
                references: references,
                spans: spans,
                footnotes: footnotes,
                crossReferences: crossReferences,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TVersesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chapterId = false}) {
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
                    if (chapterId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.chapterId,
                                referencedTable: $$TVersesTableReferences
                                    ._chapterIdTable(db),
                                referencedColumn: $$TVersesTableReferences
                                    ._chapterIdTable(db)
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

typedef $$TVersesTableProcessedTableManager =
    ProcessedTableManager<
      _$TranslationDatabase,
      $TVersesTable,
      TVerseEntry,
      $$TVersesTableFilterComposer,
      $$TVersesTableOrderingComposer,
      $$TVersesTableAnnotationComposer,
      $$TVersesTableCreateCompanionBuilder,
      $$TVersesTableUpdateCompanionBuilder,
      (TVerseEntry, $$TVersesTableReferences),
      TVerseEntry,
      PrefetchHooks Function({bool chapterId})
    >;

class $TranslationDatabaseManager {
  final _$TranslationDatabase _db;
  $TranslationDatabaseManager(this._db);
  $$TBooksTableTableManager get tBooks =>
      $$TBooksTableTableManager(_db, _db.tBooks);
  $$TChaptersTableTableManager get tChapters =>
      $$TChaptersTableTableManager(_db, _db.tChapters);
  $$TVersesTableTableManager get tVerses =>
      $$TVersesTableTableManager(_db, _db.tVerses);
}
