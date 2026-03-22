// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TranslationsTable extends Translations
    with TableInfo<$TranslationsTable, TranslationEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranslationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceLocationMeta = const VerificationMeta(
    'sourceLocation',
  );
  @override
  late final GeneratedColumn<String> sourceLocation = GeneratedColumn<String>(
    'source_location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isLocalMeta = const VerificationMeta(
    'isLocal',
  );
  @override
  late final GeneratedColumn<bool> isLocal = GeneratedColumn<bool>(
    'is_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_local" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    language,
    description,
    format,
    sourceType,
    sourceLocation,
    isLocal,
    importedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'translations';
  @override
  VerificationContext validateIntegrity(
    Insertable<TranslationEntry> instance, {
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
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_location')) {
      context.handle(
        _sourceLocationMeta,
        sourceLocation.isAcceptableOrUnknown(
          data['source_location']!,
          _sourceLocationMeta,
        ),
      );
    }
    if (data.containsKey('is_local')) {
      context.handle(
        _isLocalMeta,
        isLocal.isAcceptableOrUnknown(data['is_local']!, _isLocalMeta),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TranslationEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranslationEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      sourceLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_location'],
      ),
      isLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_local'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
    );
  }

  @override
  $TranslationsTable createAlias(String alias) {
    return $TranslationsTable(attachedDatabase, alias);
  }
}

class TranslationEntry extends DataClass
    implements Insertable<TranslationEntry> {
  final String id;
  final String name;
  final String language;
  final String description;
  final String format;
  final String sourceType;
  final String? sourceLocation;
  final bool isLocal;
  final DateTime importedAt;
  const TranslationEntry({
    required this.id,
    required this.name,
    required this.language,
    required this.description,
    required this.format,
    required this.sourceType,
    this.sourceLocation,
    required this.isLocal,
    required this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['language'] = Variable<String>(language);
    map['description'] = Variable<String>(description);
    map['format'] = Variable<String>(format);
    map['source_type'] = Variable<String>(sourceType);
    if (!nullToAbsent || sourceLocation != null) {
      map['source_location'] = Variable<String>(sourceLocation);
    }
    map['is_local'] = Variable<bool>(isLocal);
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  TranslationsCompanion toCompanion(bool nullToAbsent) {
    return TranslationsCompanion(
      id: Value(id),
      name: Value(name),
      language: Value(language),
      description: Value(description),
      format: Value(format),
      sourceType: Value(sourceType),
      sourceLocation: sourceLocation == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceLocation),
      isLocal: Value(isLocal),
      importedAt: Value(importedAt),
    );
  }

  factory TranslationEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranslationEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      language: serializer.fromJson<String>(json['language']),
      description: serializer.fromJson<String>(json['description']),
      format: serializer.fromJson<String>(json['format']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceLocation: serializer.fromJson<String?>(json['sourceLocation']),
      isLocal: serializer.fromJson<bool>(json['isLocal']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'language': serializer.toJson<String>(language),
      'description': serializer.toJson<String>(description),
      'format': serializer.toJson<String>(format),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceLocation': serializer.toJson<String?>(sourceLocation),
      'isLocal': serializer.toJson<bool>(isLocal),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  TranslationEntry copyWith({
    String? id,
    String? name,
    String? language,
    String? description,
    String? format,
    String? sourceType,
    Value<String?> sourceLocation = const Value.absent(),
    bool? isLocal,
    DateTime? importedAt,
  }) => TranslationEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    language: language ?? this.language,
    description: description ?? this.description,
    format: format ?? this.format,
    sourceType: sourceType ?? this.sourceType,
    sourceLocation: sourceLocation.present
        ? sourceLocation.value
        : this.sourceLocation,
    isLocal: isLocal ?? this.isLocal,
    importedAt: importedAt ?? this.importedAt,
  );
  TranslationEntry copyWithCompanion(TranslationsCompanion data) {
    return TranslationEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      language: data.language.present ? data.language.value : this.language,
      description: data.description.present
          ? data.description.value
          : this.description,
      format: data.format.present ? data.format.value : this.format,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      sourceLocation: data.sourceLocation.present
          ? data.sourceLocation.value
          : this.sourceLocation,
      isLocal: data.isLocal.present ? data.isLocal.value : this.isLocal,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranslationEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('language: $language, ')
          ..write('description: $description, ')
          ..write('format: $format, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceLocation: $sourceLocation, ')
          ..write('isLocal: $isLocal, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    language,
    description,
    format,
    sourceType,
    sourceLocation,
    isLocal,
    importedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranslationEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.language == this.language &&
          other.description == this.description &&
          other.format == this.format &&
          other.sourceType == this.sourceType &&
          other.sourceLocation == this.sourceLocation &&
          other.isLocal == this.isLocal &&
          other.importedAt == this.importedAt);
}

class TranslationsCompanion extends UpdateCompanion<TranslationEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> language;
  final Value<String> description;
  final Value<String> format;
  final Value<String> sourceType;
  final Value<String?> sourceLocation;
  final Value<bool> isLocal;
  final Value<DateTime> importedAt;
  final Value<int> rowid;
  const TranslationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.language = const Value.absent(),
    this.description = const Value.absent(),
    this.format = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceLocation = const Value.absent(),
    this.isLocal = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TranslationsCompanion.insert({
    required String id,
    required String name,
    required String language,
    required String description,
    required String format,
    required String sourceType,
    this.sourceLocation = const Value.absent(),
    this.isLocal = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       language = Value(language),
       description = Value(description),
       format = Value(format),
       sourceType = Value(sourceType);
  static Insertable<TranslationEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? language,
    Expression<String>? description,
    Expression<String>? format,
    Expression<String>? sourceType,
    Expression<String>? sourceLocation,
    Expression<bool>? isLocal,
    Expression<DateTime>? importedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (language != null) 'language': language,
      if (description != null) 'description': description,
      if (format != null) 'format': format,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceLocation != null) 'source_location': sourceLocation,
      if (isLocal != null) 'is_local': isLocal,
      if (importedAt != null) 'imported_at': importedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TranslationsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? language,
    Value<String>? description,
    Value<String>? format,
    Value<String>? sourceType,
    Value<String?>? sourceLocation,
    Value<bool>? isLocal,
    Value<DateTime>? importedAt,
    Value<int>? rowid,
  }) {
    return TranslationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      language: language ?? this.language,
      description: description ?? this.description,
      format: format ?? this.format,
      sourceType: sourceType ?? this.sourceType,
      sourceLocation: sourceLocation ?? this.sourceLocation,
      isLocal: isLocal ?? this.isLocal,
      importedAt: importedAt ?? this.importedAt,
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
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceLocation.present) {
      map['source_location'] = Variable<String>(sourceLocation.value);
    }
    if (isLocal.present) {
      map['is_local'] = Variable<bool>(isLocal.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranslationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('language: $language, ')
          ..write('description: $description, ')
          ..write('format: $format, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceLocation: $sourceLocation, ')
          ..write('isLocal: $isLocal, ')
          ..write('importedAt: $importedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BooksTable extends Books with TableInfo<$BooksTable, BookEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translationIdMeta = const VerificationMeta(
    'translationId',
  );
  @override
  late final GeneratedColumn<String> translationId = GeneratedColumn<String>(
    'translation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES translations (id)',
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
  List<GeneratedColumn> get $columns => [
    id,
    translationId,
    name,
    shortName,
    bookNumber,
    bookType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('translation_id')) {
      context.handle(
        _translationIdMeta,
        translationId.isAcceptableOrUnknown(
          data['translation_id']!,
          _translationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationIdMeta);
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
  BookEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      translationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_id'],
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
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class BookEntry extends DataClass implements Insertable<BookEntry> {
  final String id;
  final String translationId;
  final String name;
  final String shortName;
  final int bookNumber;
  final int bookType;
  const BookEntry({
    required this.id,
    required this.translationId,
    required this.name,
    required this.shortName,
    required this.bookNumber,
    required this.bookType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['translation_id'] = Variable<String>(translationId);
    map['name'] = Variable<String>(name);
    map['short_name'] = Variable<String>(shortName);
    map['book_number'] = Variable<int>(bookNumber);
    map['book_type'] = Variable<int>(bookType);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      translationId: Value(translationId),
      name: Value(name),
      shortName: Value(shortName),
      bookNumber: Value(bookNumber),
      bookType: Value(bookType),
    );
  }

  factory BookEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookEntry(
      id: serializer.fromJson<String>(json['id']),
      translationId: serializer.fromJson<String>(json['translationId']),
      name: serializer.fromJson<String>(json['name']),
      shortName: serializer.fromJson<String>(json['shortName']),
      bookNumber: serializer.fromJson<int>(json['bookNumber']),
      bookType: serializer.fromJson<int>(json['bookType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'translationId': serializer.toJson<String>(translationId),
      'name': serializer.toJson<String>(name),
      'shortName': serializer.toJson<String>(shortName),
      'bookNumber': serializer.toJson<int>(bookNumber),
      'bookType': serializer.toJson<int>(bookType),
    };
  }

  BookEntry copyWith({
    String? id,
    String? translationId,
    String? name,
    String? shortName,
    int? bookNumber,
    int? bookType,
  }) => BookEntry(
    id: id ?? this.id,
    translationId: translationId ?? this.translationId,
    name: name ?? this.name,
    shortName: shortName ?? this.shortName,
    bookNumber: bookNumber ?? this.bookNumber,
    bookType: bookType ?? this.bookType,
  );
  BookEntry copyWithCompanion(BooksCompanion data) {
    return BookEntry(
      id: data.id.present ? data.id.value : this.id,
      translationId: data.translationId.present
          ? data.translationId.value
          : this.translationId,
      name: data.name.present ? data.name.value : this.name,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
      bookNumber: data.bookNumber.present
          ? data.bookNumber.value
          : this.bookNumber,
      bookType: data.bookType.present ? data.bookType.value : this.bookType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookEntry(')
          ..write('id: $id, ')
          ..write('translationId: $translationId, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('bookNumber: $bookNumber, ')
          ..write('bookType: $bookType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, translationId, name, shortName, bookNumber, bookType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookEntry &&
          other.id == this.id &&
          other.translationId == this.translationId &&
          other.name == this.name &&
          other.shortName == this.shortName &&
          other.bookNumber == this.bookNumber &&
          other.bookType == this.bookType);
}

class BooksCompanion extends UpdateCompanion<BookEntry> {
  final Value<String> id;
  final Value<String> translationId;
  final Value<String> name;
  final Value<String> shortName;
  final Value<int> bookNumber;
  final Value<int> bookType;
  final Value<int> rowid;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.translationId = const Value.absent(),
    this.name = const Value.absent(),
    this.shortName = const Value.absent(),
    this.bookNumber = const Value.absent(),
    this.bookType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BooksCompanion.insert({
    required String id,
    required String translationId,
    required String name,
    required String shortName,
    required int bookNumber,
    required int bookType,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       translationId = Value(translationId),
       name = Value(name),
       shortName = Value(shortName),
       bookNumber = Value(bookNumber),
       bookType = Value(bookType);
  static Insertable<BookEntry> custom({
    Expression<String>? id,
    Expression<String>? translationId,
    Expression<String>? name,
    Expression<String>? shortName,
    Expression<int>? bookNumber,
    Expression<int>? bookType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (translationId != null) 'translation_id': translationId,
      if (name != null) 'name': name,
      if (shortName != null) 'short_name': shortName,
      if (bookNumber != null) 'book_number': bookNumber,
      if (bookType != null) 'book_type': bookType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BooksCompanion copyWith({
    Value<String>? id,
    Value<String>? translationId,
    Value<String>? name,
    Value<String>? shortName,
    Value<int>? bookNumber,
    Value<int>? bookType,
    Value<int>? rowid,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      translationId: translationId ?? this.translationId,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      bookNumber: bookNumber ?? this.bookNumber,
      bookType: bookType ?? this.bookType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (translationId.present) {
      map['translation_id'] = Variable<String>(translationId.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('translationId: $translationId, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('bookNumber: $bookNumber, ')
          ..write('bookType: $bookType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters
    with TableInfo<$ChaptersTable, ChapterEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
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
      'REFERENCES books (id)',
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
  List<GeneratedColumn> get $columns => [id, bookId, number];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapterEntry> instance, {
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
  ChapterEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterEntry(
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
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }
}

class ChapterEntry extends DataClass implements Insertable<ChapterEntry> {
  final int id;
  final String bookId;
  final int number;
  const ChapterEntry({
    required this.id,
    required this.bookId,
    required this.number,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<String>(bookId);
    map['number'] = Variable<int>(number);
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      bookId: Value(bookId),
      number: Value(number),
    );
  }

  factory ChapterEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterEntry(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      number: serializer.fromJson<int>(json['number']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<String>(bookId),
      'number': serializer.toJson<int>(number),
    };
  }

  ChapterEntry copyWith({int? id, String? bookId, int? number}) => ChapterEntry(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    number: number ?? this.number,
  );
  ChapterEntry copyWithCompanion(ChaptersCompanion data) {
    return ChapterEntry(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      number: data.number.present ? data.number.value : this.number,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterEntry(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('number: $number')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, number);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterEntry &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.number == this.number);
}

class ChaptersCompanion extends UpdateCompanion<ChapterEntry> {
  final Value<int> id;
  final Value<String> bookId;
  final Value<int> number;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.number = const Value.absent(),
  });
  ChaptersCompanion.insert({
    this.id = const Value.absent(),
    required String bookId,
    required int number,
  }) : bookId = Value(bookId),
       number = Value(number);
  static Insertable<ChapterEntry> custom({
    Expression<int>? id,
    Expression<String>? bookId,
    Expression<int>? number,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (number != null) 'number': number,
    });
  }

  ChaptersCompanion copyWith({
    Value<int>? id,
    Value<String>? bookId,
    Value<int>? number,
  }) {
    return ChaptersCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      number: number ?? this.number,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('number: $number')
          ..write(')'))
        .toString();
  }
}

class $VersesTable extends Verses with TableInfo<$VersesTable, VerseEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VersesTable(this.attachedDatabase, [this._alias]);
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
      'REFERENCES chapters (id)',
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
      ).withConverter<List<String>?>($VersesTable.$converternotesn);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String>
  references = GeneratedColumn<String>(
    'references',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<List<String>?>($VersesTable.$converterreferencesn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chapterId,
    number,
    verseText,
    notes,
    references,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verses';
  @override
  VerificationContext validateIntegrity(
    Insertable<VerseEntry> instance, {
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
  VerseEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VerseEntry(
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
      notes: $VersesTable.$converternotesn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}notes'],
        ),
      ),
      references: $VersesTable.$converterreferencesn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}references'],
        ),
      ),
    );
  }

  @override
  $VersesTable createAlias(String alias) {
    return $VersesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converternotes =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converternotesn =
      NullAwareTypeConverter.wrap($converternotes);
  static TypeConverter<List<String>, String> $converterreferences =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterreferencesn =
      NullAwareTypeConverter.wrap($converterreferences);
}

class VerseEntry extends DataClass implements Insertable<VerseEntry> {
  final int id;
  final int chapterId;
  final int number;
  final String verseText;
  final List<String>? notes;
  final List<String>? references;
  const VerseEntry({
    required this.id,
    required this.chapterId,
    required this.number,
    required this.verseText,
    this.notes,
    this.references,
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
        $VersesTable.$converternotesn.toSql(notes),
      );
    }
    if (!nullToAbsent || references != null) {
      map['references'] = Variable<String>(
        $VersesTable.$converterreferencesn.toSql(references),
      );
    }
    return map;
  }

  VersesCompanion toCompanion(bool nullToAbsent) {
    return VersesCompanion(
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
    );
  }

  factory VerseEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VerseEntry(
      id: serializer.fromJson<int>(json['id']),
      chapterId: serializer.fromJson<int>(json['chapterId']),
      number: serializer.fromJson<int>(json['number']),
      verseText: serializer.fromJson<String>(json['verseText']),
      notes: serializer.fromJson<List<String>?>(json['notes']),
      references: serializer.fromJson<List<String>?>(json['references']),
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
    };
  }

  VerseEntry copyWith({
    int? id,
    int? chapterId,
    int? number,
    String? verseText,
    Value<List<String>?> notes = const Value.absent(),
    Value<List<String>?> references = const Value.absent(),
  }) => VerseEntry(
    id: id ?? this.id,
    chapterId: chapterId ?? this.chapterId,
    number: number ?? this.number,
    verseText: verseText ?? this.verseText,
    notes: notes.present ? notes.value : this.notes,
    references: references.present ? references.value : this.references,
  );
  VerseEntry copyWithCompanion(VersesCompanion data) {
    return VerseEntry(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      number: data.number.present ? data.number.value : this.number,
      verseText: data.verseText.present ? data.verseText.value : this.verseText,
      notes: data.notes.present ? data.notes.value : this.notes,
      references: data.references.present
          ? data.references.value
          : this.references,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VerseEntry(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('number: $number, ')
          ..write('verseText: $verseText, ')
          ..write('notes: $notes, ')
          ..write('references: $references')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, chapterId, number, verseText, notes, references);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VerseEntry &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.number == this.number &&
          other.verseText == this.verseText &&
          other.notes == this.notes &&
          other.references == this.references);
}

class VersesCompanion extends UpdateCompanion<VerseEntry> {
  final Value<int> id;
  final Value<int> chapterId;
  final Value<int> number;
  final Value<String> verseText;
  final Value<List<String>?> notes;
  final Value<List<String>?> references;
  const VersesCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.number = const Value.absent(),
    this.verseText = const Value.absent(),
    this.notes = const Value.absent(),
    this.references = const Value.absent(),
  });
  VersesCompanion.insert({
    this.id = const Value.absent(),
    required int chapterId,
    required int number,
    required String verseText,
    this.notes = const Value.absent(),
    this.references = const Value.absent(),
  }) : chapterId = Value(chapterId),
       number = Value(number),
       verseText = Value(verseText);
  static Insertable<VerseEntry> custom({
    Expression<int>? id,
    Expression<int>? chapterId,
    Expression<int>? number,
    Expression<String>? verseText,
    Expression<String>? notes,
    Expression<String>? references,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (number != null) 'number': number,
      if (verseText != null) 'verse_text': verseText,
      if (notes != null) 'notes': notes,
      if (references != null) 'references': references,
    });
  }

  VersesCompanion copyWith({
    Value<int>? id,
    Value<int>? chapterId,
    Value<int>? number,
    Value<String>? verseText,
    Value<List<String>?>? notes,
    Value<List<String>?>? references,
  }) {
    return VersesCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      number: number ?? this.number,
      verseText: verseText ?? this.verseText,
      notes: notes ?? this.notes,
      references: references ?? this.references,
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
        $VersesTable.$converternotesn.toSql(notes.value),
      );
    }
    if (references.present) {
      map['references'] = Variable<String>(
        $VersesTable.$converterreferencesn.toSql(references.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VersesCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('number: $number, ')
          ..write('verseText: $verseText, ')
          ..write('notes: $notes, ')
          ..write('references: $references')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TranslationsTable translations = $TranslationsTable(this);
  late final $BooksTable books = $BooksTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $VersesTable verses = $VersesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    translations,
    books,
    chapters,
    verses,
  ];
}

typedef $$TranslationsTableCreateCompanionBuilder =
    TranslationsCompanion Function({
      required String id,
      required String name,
      required String language,
      required String description,
      required String format,
      required String sourceType,
      Value<String?> sourceLocation,
      Value<bool> isLocal,
      Value<DateTime> importedAt,
      Value<int> rowid,
    });
typedef $$TranslationsTableUpdateCompanionBuilder =
    TranslationsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> language,
      Value<String> description,
      Value<String> format,
      Value<String> sourceType,
      Value<String?> sourceLocation,
      Value<bool> isLocal,
      Value<DateTime> importedAt,
      Value<int> rowid,
    });

final class $$TranslationsTableReferences
    extends
        BaseReferences<_$AppDatabase, $TranslationsTable, TranslationEntry> {
  $$TranslationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BooksTable, List<BookEntry>> _booksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.books,
    aliasName: $_aliasNameGenerator(db.translations.id, db.books.translationId),
  );

  $$BooksTableProcessedTableManager get booksRefs {
    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.translationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_booksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TranslationsTableFilterComposer
    extends Composer<_$AppDatabase, $TranslationsTable> {
  $$TranslationsTableFilterComposer({
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

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceLocation => $composableBuilder(
    column: $table.sourceLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocal => $composableBuilder(
    column: $table.isLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> booksRefs(
    Expression<bool> Function($$BooksTableFilterComposer f) f,
  ) {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.translationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TranslationsTableOrderingComposer
    extends Composer<_$AppDatabase, $TranslationsTable> {
  $$TranslationsTableOrderingComposer({
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

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceLocation => $composableBuilder(
    column: $table.sourceLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocal => $composableBuilder(
    column: $table.isLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TranslationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TranslationsTable> {
  $$TranslationsTableAnnotationComposer({
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

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceLocation => $composableBuilder(
    column: $table.sourceLocation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLocal =>
      $composableBuilder(column: $table.isLocal, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  Expression<T> booksRefs<T extends Object>(
    Expression<T> Function($$BooksTableAnnotationComposer a) f,
  ) {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.translationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TranslationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TranslationsTable,
          TranslationEntry,
          $$TranslationsTableFilterComposer,
          $$TranslationsTableOrderingComposer,
          $$TranslationsTableAnnotationComposer,
          $$TranslationsTableCreateCompanionBuilder,
          $$TranslationsTableUpdateCompanionBuilder,
          (TranslationEntry, $$TranslationsTableReferences),
          TranslationEntry,
          PrefetchHooks Function({bool booksRefs})
        > {
  $$TranslationsTableTableManager(_$AppDatabase db, $TranslationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranslationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TranslationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TranslationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String?> sourceLocation = const Value.absent(),
                Value<bool> isLocal = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranslationsCompanion(
                id: id,
                name: name,
                language: language,
                description: description,
                format: format,
                sourceType: sourceType,
                sourceLocation: sourceLocation,
                isLocal: isLocal,
                importedAt: importedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String language,
                required String description,
                required String format,
                required String sourceType,
                Value<String?> sourceLocation = const Value.absent(),
                Value<bool> isLocal = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranslationsCompanion.insert(
                id: id,
                name: name,
                language: language,
                description: description,
                format: format,
                sourceType: sourceType,
                sourceLocation: sourceLocation,
                isLocal: isLocal,
                importedAt: importedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TranslationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({booksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (booksRefs) db.books],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (booksRefs)
                    await $_getPrefetchedData<
                      TranslationEntry,
                      $TranslationsTable,
                      BookEntry
                    >(
                      currentTable: table,
                      referencedTable: $$TranslationsTableReferences
                          ._booksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TranslationsTableReferences(
                            db,
                            table,
                            p0,
                          ).booksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.translationId == item.id,
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

typedef $$TranslationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TranslationsTable,
      TranslationEntry,
      $$TranslationsTableFilterComposer,
      $$TranslationsTableOrderingComposer,
      $$TranslationsTableAnnotationComposer,
      $$TranslationsTableCreateCompanionBuilder,
      $$TranslationsTableUpdateCompanionBuilder,
      (TranslationEntry, $$TranslationsTableReferences),
      TranslationEntry,
      PrefetchHooks Function({bool booksRefs})
    >;
typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      required String id,
      required String translationId,
      required String name,
      required String shortName,
      required int bookNumber,
      required int bookType,
      Value<int> rowid,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<String> id,
      Value<String> translationId,
      Value<String> name,
      Value<String> shortName,
      Value<int> bookNumber,
      Value<int> bookType,
      Value<int> rowid,
    });

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, BookEntry> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TranslationsTable _translationIdTable(_$AppDatabase db) =>
      db.translations.createAlias(
        $_aliasNameGenerator(db.books.translationId, db.translations.id),
      );

  $$TranslationsTableProcessedTableManager get translationId {
    final $_column = $_itemColumn<String>('translation_id')!;

    final manager = $$TranslationsTableTableManager(
      $_db,
      $_db.translations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_translationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ChaptersTable, List<ChapterEntry>>
  _chaptersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chapters,
    aliasName: $_aliasNameGenerator(db.books.id, db.chapters.bookId),
  );

  $$ChaptersTableProcessedTableManager get chaptersRefs {
    final manager = $$ChaptersTableTableManager(
      $_db,
      $_db.chapters,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chaptersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
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

  $$TranslationsTableFilterComposer get translationId {
    final $$TranslationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.translationId,
      referencedTable: $db.translations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TranslationsTableFilterComposer(
            $db: $db,
            $table: $db.translations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> chaptersRefs(
    Expression<bool> Function($$ChaptersTableFilterComposer f) f,
  ) {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableFilterComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
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

  $$TranslationsTableOrderingComposer get translationId {
    final $$TranslationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.translationId,
      referencedTable: $db.translations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TranslationsTableOrderingComposer(
            $db: $db,
            $table: $db.translations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
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

  $$TranslationsTableAnnotationComposer get translationId {
    final $$TranslationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.translationId,
      referencedTable: $db.translations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TranslationsTableAnnotationComposer(
            $db: $db,
            $table: $db.translations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> chaptersRefs<T extends Object>(
    Expression<T> Function($$ChaptersTableAnnotationComposer a) f,
  ) {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableAnnotationComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          BookEntry,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (BookEntry, $$BooksTableReferences),
          BookEntry,
          PrefetchHooks Function({bool translationId, bool chaptersRefs})
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> translationId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> shortName = const Value.absent(),
                Value<int> bookNumber = const Value.absent(),
                Value<int> bookType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                translationId: translationId,
                name: name,
                shortName: shortName,
                bookNumber: bookNumber,
                bookType: bookType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String translationId,
                required String name,
                required String shortName,
                required int bookNumber,
                required int bookType,
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                translationId: translationId,
                name: name,
                shortName: shortName,
                bookNumber: bookNumber,
                bookType: bookType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BooksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({translationId = false, chaptersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (chaptersRefs) db.chapters],
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
                        if (translationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.translationId,
                                    referencedTable: $$BooksTableReferences
                                        ._translationIdTable(db),
                                    referencedColumn: $$BooksTableReferences
                                        ._translationIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (chaptersRefs)
                        await $_getPrefetchedData<
                          BookEntry,
                          $BooksTable,
                          ChapterEntry
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._chaptersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).chaptersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
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

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      BookEntry,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (BookEntry, $$BooksTableReferences),
      BookEntry,
      PrefetchHooks Function({bool translationId, bool chaptersRefs})
    >;
typedef $$ChaptersTableCreateCompanionBuilder =
    ChaptersCompanion Function({
      Value<int> id,
      required String bookId,
      required int number,
    });
typedef $$ChaptersTableUpdateCompanionBuilder =
    ChaptersCompanion Function({
      Value<int> id,
      Value<String> bookId,
      Value<int> number,
    });

final class $$ChaptersTableReferences
    extends BaseReferences<_$AppDatabase, $ChaptersTable, ChapterEntry> {
  $$ChaptersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) => db.books.createAlias(
    $_aliasNameGenerator(db.chapters.bookId, db.books.id),
  );

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$VersesTable, List<VerseEntry>> _versesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.verses,
    aliasName: $_aliasNameGenerator(db.chapters.id, db.verses.chapterId),
  );

  $$VersesTableProcessedTableManager get versesRefs {
    final manager = $$VersesTableTableManager(
      $_db,
      $_db.verses,
    ).filter((f) => f.chapterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_versesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableFilterComposer({
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

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> versesRefs(
    Expression<bool> Function($$VersesTableFilterComposer f) f,
  ) {
    final $$VersesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.verses,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersesTableFilterComposer(
            $db: $db,
            $table: $db.verses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableOrderingComposer({
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

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableAnnotationComposer({
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

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> versesRefs<T extends Object>(
    Expression<T> Function($$VersesTableAnnotationComposer a) f,
  ) {
    final $$VersesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.verses,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersesTableAnnotationComposer(
            $db: $db,
            $table: $db.verses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChaptersTable,
          ChapterEntry,
          $$ChaptersTableFilterComposer,
          $$ChaptersTableOrderingComposer,
          $$ChaptersTableAnnotationComposer,
          $$ChaptersTableCreateCompanionBuilder,
          $$ChaptersTableUpdateCompanionBuilder,
          (ChapterEntry, $$ChaptersTableReferences),
          ChapterEntry,
          PrefetchHooks Function({bool bookId, bool versesRefs})
        > {
  $$ChaptersTableTableManager(_$AppDatabase db, $ChaptersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> number = const Value.absent(),
              }) => ChaptersCompanion(id: id, bookId: bookId, number: number),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bookId,
                required int number,
              }) => ChaptersCompanion.insert(
                id: id,
                bookId: bookId,
                number: number,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChaptersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false, versesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (versesRefs) db.verses],
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
                                referencedTable: $$ChaptersTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$ChaptersTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (versesRefs)
                    await $_getPrefetchedData<
                      ChapterEntry,
                      $ChaptersTable,
                      VerseEntry
                    >(
                      currentTable: table,
                      referencedTable: $$ChaptersTableReferences
                          ._versesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ChaptersTableReferences(db, table, p0).versesRefs,
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

typedef $$ChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChaptersTable,
      ChapterEntry,
      $$ChaptersTableFilterComposer,
      $$ChaptersTableOrderingComposer,
      $$ChaptersTableAnnotationComposer,
      $$ChaptersTableCreateCompanionBuilder,
      $$ChaptersTableUpdateCompanionBuilder,
      (ChapterEntry, $$ChaptersTableReferences),
      ChapterEntry,
      PrefetchHooks Function({bool bookId, bool versesRefs})
    >;
typedef $$VersesTableCreateCompanionBuilder =
    VersesCompanion Function({
      Value<int> id,
      required int chapterId,
      required int number,
      required String verseText,
      Value<List<String>?> notes,
      Value<List<String>?> references,
    });
typedef $$VersesTableUpdateCompanionBuilder =
    VersesCompanion Function({
      Value<int> id,
      Value<int> chapterId,
      Value<int> number,
      Value<String> verseText,
      Value<List<String>?> notes,
      Value<List<String>?> references,
    });

final class $$VersesTableReferences
    extends BaseReferences<_$AppDatabase, $VersesTable, VerseEntry> {
  $$VersesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) => db.chapters
      .createAlias($_aliasNameGenerator(db.verses.chapterId, db.chapters.id));

  $$ChaptersTableProcessedTableManager get chapterId {
    final $_column = $_itemColumn<int>('chapter_id')!;

    final manager = $$ChaptersTableTableManager(
      $_db,
      $_db.chapters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VersesTableFilterComposer
    extends Composer<_$AppDatabase, $VersesTable> {
  $$VersesTableFilterComposer({
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

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableFilterComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VersesTableOrderingComposer
    extends Composer<_$AppDatabase, $VersesTable> {
  $$VersesTableOrderingComposer({
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

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableOrderingComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VersesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VersesTable> {
  $$VersesTableAnnotationComposer({
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

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableAnnotationComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VersesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VersesTable,
          VerseEntry,
          $$VersesTableFilterComposer,
          $$VersesTableOrderingComposer,
          $$VersesTableAnnotationComposer,
          $$VersesTableCreateCompanionBuilder,
          $$VersesTableUpdateCompanionBuilder,
          (VerseEntry, $$VersesTableReferences),
          VerseEntry,
          PrefetchHooks Function({bool chapterId})
        > {
  $$VersesTableTableManager(_$AppDatabase db, $VersesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VersesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VersesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VersesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> chapterId = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<String> verseText = const Value.absent(),
                Value<List<String>?> notes = const Value.absent(),
                Value<List<String>?> references = const Value.absent(),
              }) => VersesCompanion(
                id: id,
                chapterId: chapterId,
                number: number,
                verseText: verseText,
                notes: notes,
                references: references,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int chapterId,
                required int number,
                required String verseText,
                Value<List<String>?> notes = const Value.absent(),
                Value<List<String>?> references = const Value.absent(),
              }) => VersesCompanion.insert(
                id: id,
                chapterId: chapterId,
                number: number,
                verseText: verseText,
                notes: notes,
                references: references,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$VersesTableReferences(db, table, e)),
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
                                referencedTable: $$VersesTableReferences
                                    ._chapterIdTable(db),
                                referencedColumn: $$VersesTableReferences
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

typedef $$VersesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VersesTable,
      VerseEntry,
      $$VersesTableFilterComposer,
      $$VersesTableOrderingComposer,
      $$VersesTableAnnotationComposer,
      $$VersesTableCreateCompanionBuilder,
      $$VersesTableUpdateCompanionBuilder,
      (VerseEntry, $$VersesTableReferences),
      VerseEntry,
      PrefetchHooks Function({bool chapterId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TranslationsTableTableManager get translations =>
      $$TranslationsTableTableManager(_db, _db.translations);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
  $$VersesTableTableManager get verses =>
      $$VersesTableTableManager(_db, _db.verses);
}
