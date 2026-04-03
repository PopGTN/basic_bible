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
  static const VerificationMeta _parserVersionMeta = const VerificationMeta(
    'parserVersion',
  );
  @override
  late final GeneratedColumn<int> parserVersion = GeneratedColumn<int>(
    'parser_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    parserVersion,
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
    if (data.containsKey('parser_version')) {
      context.handle(
        _parserVersionMeta,
        parserVersion.isAcceptableOrUnknown(
          data['parser_version']!,
          _parserVersionMeta,
        ),
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
      parserVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parser_version'],
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
  final int parserVersion;
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
    required this.parserVersion,
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
    map['parser_version'] = Variable<int>(parserVersion);
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
      parserVersion: Value(parserVersion),
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
      parserVersion: serializer.fromJson<int>(json['parserVersion']),
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
      'parserVersion': serializer.toJson<int>(parserVersion),
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
    int? parserVersion,
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
    parserVersion: parserVersion ?? this.parserVersion,
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
      parserVersion: data.parserVersion.present
          ? data.parserVersion.value
          : this.parserVersion,
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
          ..write('importedAt: $importedAt, ')
          ..write('parserVersion: $parserVersion')
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
    parserVersion,
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
          other.importedAt == this.importedAt &&
          other.parserVersion == this.parserVersion);
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
  final Value<int> parserVersion;
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
    this.parserVersion = const Value.absent(),
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
    this.parserVersion = const Value.absent(),
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
    Expression<int>? parserVersion,
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
      if (parserVersion != null) 'parser_version': parserVersion,
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
    Value<int>? parserVersion,
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
      parserVersion: parserVersion ?? this.parserVersion,
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
    if (parserVersion.present) {
      map['parser_version'] = Variable<int>(parserVersion.value);
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
          ..write('parserVersion: $parserVersion, ')
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
  late final GeneratedColumnWithTypeConverter<List<BibleTocLabel>?, String>
  tocLabels = GeneratedColumn<String>(
    'toc_labels',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<List<BibleTocLabel>?>($BooksTable.$convertertocLabelsn);
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
        $BooksTable.$converterintroductionBlocksn,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    translationId,
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
      tocLabels: $BooksTable.$convertertocLabelsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}toc_labels'],
        ),
      ),
      introductionBlocks: $BooksTable.$converterintroductionBlocksn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}introduction_blocks'],
        ),
      ),
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
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

class BookEntry extends DataClass implements Insertable<BookEntry> {
  final String id;
  final String translationId;
  final String name;
  final String shortName;
  final int bookNumber;
  final int bookType;
  final List<BibleTocLabel>? tocLabels;
  final List<BibleDocumentBlock>? introductionBlocks;
  const BookEntry({
    required this.id,
    required this.translationId,
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
    map['translation_id'] = Variable<String>(translationId);
    map['name'] = Variable<String>(name);
    map['short_name'] = Variable<String>(shortName);
    map['book_number'] = Variable<int>(bookNumber);
    map['book_type'] = Variable<int>(bookType);
    if (!nullToAbsent || tocLabels != null) {
      map['toc_labels'] = Variable<String>(
        $BooksTable.$convertertocLabelsn.toSql(tocLabels),
      );
    }
    if (!nullToAbsent || introductionBlocks != null) {
      map['introduction_blocks'] = Variable<String>(
        $BooksTable.$converterintroductionBlocksn.toSql(introductionBlocks),
      );
    }
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
      tocLabels: tocLabels == null && nullToAbsent
          ? const Value.absent()
          : Value(tocLabels),
      introductionBlocks: introductionBlocks == null && nullToAbsent
          ? const Value.absent()
          : Value(introductionBlocks),
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
      'translationId': serializer.toJson<String>(translationId),
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

  BookEntry copyWith({
    String? id,
    String? translationId,
    String? name,
    String? shortName,
    int? bookNumber,
    int? bookType,
    Value<List<BibleTocLabel>?> tocLabels = const Value.absent(),
    Value<List<BibleDocumentBlock>?> introductionBlocks = const Value.absent(),
  }) => BookEntry(
    id: id ?? this.id,
    translationId: translationId ?? this.translationId,
    name: name ?? this.name,
    shortName: shortName ?? this.shortName,
    bookNumber: bookNumber ?? this.bookNumber,
    bookType: bookType ?? this.bookType,
    tocLabels: tocLabels.present ? tocLabels.value : this.tocLabels,
    introductionBlocks: introductionBlocks.present
        ? introductionBlocks.value
        : this.introductionBlocks,
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
      tocLabels: data.tocLabels.present ? data.tocLabels.value : this.tocLabels,
      introductionBlocks: data.introductionBlocks.present
          ? data.introductionBlocks.value
          : this.introductionBlocks,
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
          ..write('bookType: $bookType, ')
          ..write('tocLabels: $tocLabels, ')
          ..write('introductionBlocks: $introductionBlocks')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    translationId,
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
      (other is BookEntry &&
          other.id == this.id &&
          other.translationId == this.translationId &&
          other.name == this.name &&
          other.shortName == this.shortName &&
          other.bookNumber == this.bookNumber &&
          other.bookType == this.bookType &&
          other.tocLabels == this.tocLabels &&
          other.introductionBlocks == this.introductionBlocks);
}

class BooksCompanion extends UpdateCompanion<BookEntry> {
  final Value<String> id;
  final Value<String> translationId;
  final Value<String> name;
  final Value<String> shortName;
  final Value<int> bookNumber;
  final Value<int> bookType;
  final Value<List<BibleTocLabel>?> tocLabels;
  final Value<List<BibleDocumentBlock>?> introductionBlocks;
  final Value<int> rowid;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.translationId = const Value.absent(),
    this.name = const Value.absent(),
    this.shortName = const Value.absent(),
    this.bookNumber = const Value.absent(),
    this.bookType = const Value.absent(),
    this.tocLabels = const Value.absent(),
    this.introductionBlocks = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BooksCompanion.insert({
    required String id,
    required String translationId,
    required String name,
    required String shortName,
    required int bookNumber,
    required int bookType,
    this.tocLabels = const Value.absent(),
    this.introductionBlocks = const Value.absent(),
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
    Expression<String>? tocLabels,
    Expression<String>? introductionBlocks,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (translationId != null) 'translation_id': translationId,
      if (name != null) 'name': name,
      if (shortName != null) 'short_name': shortName,
      if (bookNumber != null) 'book_number': bookNumber,
      if (bookType != null) 'book_type': bookType,
      if (tocLabels != null) 'toc_labels': tocLabels,
      if (introductionBlocks != null) 'introduction_blocks': introductionBlocks,
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
    Value<List<BibleTocLabel>?>? tocLabels,
    Value<List<BibleDocumentBlock>?>? introductionBlocks,
    Value<int>? rowid,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      translationId: translationId ?? this.translationId,
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
    if (tocLabels.present) {
      map['toc_labels'] = Variable<String>(
        $BooksTable.$convertertocLabelsn.toSql(tocLabels.value),
      );
    }
    if (introductionBlocks.present) {
      map['introduction_blocks'] = Variable<String>(
        $BooksTable.$converterintroductionBlocksn.toSql(
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
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('translationId: $translationId, ')
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
  late final GeneratedColumnWithTypeConverter<List<BibleDocumentBlock>?, String>
  blocks = GeneratedColumn<String>(
    'blocks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<List<BibleDocumentBlock>?>($ChaptersTable.$converterblocksn);
  @override
  List<GeneratedColumn> get $columns => [id, bookId, number, blocks];
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
      blocks: $ChaptersTable.$converterblocksn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}blocks'],
        ),
      ),
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }

  static TypeConverter<List<BibleDocumentBlock>, String> $converterblocks =
      const BibleDocumentBlockListConverter();
  static TypeConverter<List<BibleDocumentBlock>?, String?> $converterblocksn =
      NullAwareTypeConverter.wrap($converterblocks);
}

class ChapterEntry extends DataClass implements Insertable<ChapterEntry> {
  final int id;
  final String bookId;
  final int number;
  final List<BibleDocumentBlock>? blocks;
  const ChapterEntry({
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
        $ChaptersTable.$converterblocksn.toSql(blocks),
      );
    }
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      bookId: Value(bookId),
      number: Value(number),
      blocks: blocks == null && nullToAbsent
          ? const Value.absent()
          : Value(blocks),
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

  ChapterEntry copyWith({
    int? id,
    String? bookId,
    int? number,
    Value<List<BibleDocumentBlock>?> blocks = const Value.absent(),
  }) => ChapterEntry(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    number: number ?? this.number,
    blocks: blocks.present ? blocks.value : this.blocks,
  );
  ChapterEntry copyWithCompanion(ChaptersCompanion data) {
    return ChapterEntry(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      number: data.number.present ? data.number.value : this.number,
      blocks: data.blocks.present ? data.blocks.value : this.blocks,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterEntry(')
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
      (other is ChapterEntry &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.number == this.number &&
          other.blocks == this.blocks);
}

class ChaptersCompanion extends UpdateCompanion<ChapterEntry> {
  final Value<int> id;
  final Value<String> bookId;
  final Value<int> number;
  final Value<List<BibleDocumentBlock>?> blocks;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.number = const Value.absent(),
    this.blocks = const Value.absent(),
  });
  ChaptersCompanion.insert({
    this.id = const Value.absent(),
    required String bookId,
    required int number,
    this.blocks = const Value.absent(),
  }) : bookId = Value(bookId),
       number = Value(number);
  static Insertable<ChapterEntry> custom({
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

  ChaptersCompanion copyWith({
    Value<int>? id,
    Value<String>? bookId,
    Value<int>? number,
    Value<List<BibleDocumentBlock>?>? blocks,
  }) {
    return ChaptersCompanion(
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
        $ChaptersTable.$converterblocksn.toSql(blocks.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('number: $number, ')
          ..write('blocks: $blocks')
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
  late final GeneratedColumnWithTypeConverter<List<BibleVerseSpan>?, String>
  spans = GeneratedColumn<String>(
    'spans',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<List<BibleVerseSpan>?>($VersesTable.$converterspansn);
  @override
  late final GeneratedColumnWithTypeConverter<List<BibleFootnote>?, String>
  footnotes = GeneratedColumn<String>(
    'footnotes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<List<BibleFootnote>?>($VersesTable.$converterfootnotesn);
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
        $VersesTable.$convertercrossReferencesn,
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
      spans: $VersesTable.$converterspansn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}spans'],
        ),
      ),
      footnotes: $VersesTable.$converterfootnotesn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}footnotes'],
        ),
      ),
      crossReferences: $VersesTable.$convertercrossReferencesn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cross_references'],
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

class VerseEntry extends DataClass implements Insertable<VerseEntry> {
  final int id;
  final int chapterId;
  final int number;
  final String verseText;
  final List<String>? notes;
  final List<String>? references;
  final List<BibleVerseSpan>? spans;
  final List<BibleFootnote>? footnotes;
  final List<BibleCrossReference>? crossReferences;
  const VerseEntry({
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
        $VersesTable.$converternotesn.toSql(notes),
      );
    }
    if (!nullToAbsent || references != null) {
      map['references'] = Variable<String>(
        $VersesTable.$converterreferencesn.toSql(references),
      );
    }
    if (!nullToAbsent || spans != null) {
      map['spans'] = Variable<String>(
        $VersesTable.$converterspansn.toSql(spans),
      );
    }
    if (!nullToAbsent || footnotes != null) {
      map['footnotes'] = Variable<String>(
        $VersesTable.$converterfootnotesn.toSql(footnotes),
      );
    }
    if (!nullToAbsent || crossReferences != null) {
      map['cross_references'] = Variable<String>(
        $VersesTable.$convertercrossReferencesn.toSql(crossReferences),
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

  VerseEntry copyWith({
    int? id,
    int? chapterId,
    int? number,
    String? verseText,
    Value<List<String>?> notes = const Value.absent(),
    Value<List<String>?> references = const Value.absent(),
    Value<List<BibleVerseSpan>?> spans = const Value.absent(),
    Value<List<BibleFootnote>?> footnotes = const Value.absent(),
    Value<List<BibleCrossReference>?> crossReferences = const Value.absent(),
  }) => VerseEntry(
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
      spans: data.spans.present ? data.spans.value : this.spans,
      footnotes: data.footnotes.present ? data.footnotes.value : this.footnotes,
      crossReferences: data.crossReferences.present
          ? data.crossReferences.value
          : this.crossReferences,
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
      (other is VerseEntry &&
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

class VersesCompanion extends UpdateCompanion<VerseEntry> {
  final Value<int> id;
  final Value<int> chapterId;
  final Value<int> number;
  final Value<String> verseText;
  final Value<List<String>?> notes;
  final Value<List<String>?> references;
  final Value<List<BibleVerseSpan>?> spans;
  final Value<List<BibleFootnote>?> footnotes;
  final Value<List<BibleCrossReference>?> crossReferences;
  const VersesCompanion({
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
  VersesCompanion.insert({
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
  static Insertable<VerseEntry> custom({
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

  VersesCompanion copyWith({
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
    return VersesCompanion(
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
        $VersesTable.$converternotesn.toSql(notes.value),
      );
    }
    if (references.present) {
      map['references'] = Variable<String>(
        $VersesTable.$converterreferencesn.toSql(references.value),
      );
    }
    if (spans.present) {
      map['spans'] = Variable<String>(
        $VersesTable.$converterspansn.toSql(spans.value),
      );
    }
    if (footnotes.present) {
      map['footnotes'] = Variable<String>(
        $VersesTable.$converterfootnotesn.toSql(footnotes.value),
      );
    }
    if (crossReferences.present) {
      map['cross_references'] = Variable<String>(
        $VersesTable.$convertercrossReferencesn.toSql(crossReferences.value),
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
          ..write('references: $references, ')
          ..write('spans: $spans, ')
          ..write('footnotes: $footnotes, ')
          ..write('crossReferences: $crossReferences')
          ..write(')'))
        .toString();
  }
}

class $UserAnnotationsTable extends UserAnnotations
    with TableInfo<$UserAnnotationsTable, UserAnnotationEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserAnnotationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primaryBookIdMeta = const VerificationMeta(
    'primaryBookId',
  );
  @override
  late final GeneratedColumn<String> primaryBookId = GeneratedColumn<String>(
    'primary_book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primaryChapterMeta = const VerificationMeta(
    'primaryChapter',
  );
  @override
  late final GeneratedColumn<int> primaryChapter = GeneratedColumn<int>(
    'primary_chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primaryVerseMeta = const VerificationMeta(
    'primaryVerse',
  );
  @override
  late final GeneratedColumn<int> primaryVerse = GeneratedColumn<int>(
    'primary_verse',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primaryTranslationIdMeta =
      const VerificationMeta('primaryTranslationId');
  @override
  late final GeneratedColumn<String> primaryTranslationId =
      GeneratedColumn<String>(
        'primary_translation_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _primaryTranslationNameMeta =
      const VerificationMeta('primaryTranslationName');
  @override
  late final GeneratedColumn<String> primaryTranslationName =
      GeneratedColumn<String>(
        'primary_translation_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _noteTextMeta = const VerificationMeta(
    'noteText',
  );
  @override
  late final GeneratedColumn<String> noteText = GeneratedColumn<String>(
    'note_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _highlightColorValueMeta =
      const VerificationMeta('highlightColorValue');
  @override
  late final GeneratedColumn<int> highlightColorValue = GeneratedColumn<int>(
    'highlight_color_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> labels =
      GeneratedColumn<String>(
        'labels',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      ).withConverter<List<String>>($UserAnnotationsTable.$converterlabels);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    primaryBookId,
    primaryChapter,
    primaryVerse,
    primaryTranslationId,
    primaryTranslationName,
    noteText,
    highlightColorValue,
    labels,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_annotations';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserAnnotationEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('primary_book_id')) {
      context.handle(
        _primaryBookIdMeta,
        primaryBookId.isAcceptableOrUnknown(
          data['primary_book_id']!,
          _primaryBookIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryBookIdMeta);
    }
    if (data.containsKey('primary_chapter')) {
      context.handle(
        _primaryChapterMeta,
        primaryChapter.isAcceptableOrUnknown(
          data['primary_chapter']!,
          _primaryChapterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryChapterMeta);
    }
    if (data.containsKey('primary_verse')) {
      context.handle(
        _primaryVerseMeta,
        primaryVerse.isAcceptableOrUnknown(
          data['primary_verse']!,
          _primaryVerseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryVerseMeta);
    }
    if (data.containsKey('primary_translation_id')) {
      context.handle(
        _primaryTranslationIdMeta,
        primaryTranslationId.isAcceptableOrUnknown(
          data['primary_translation_id']!,
          _primaryTranslationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryTranslationIdMeta);
    }
    if (data.containsKey('primary_translation_name')) {
      context.handle(
        _primaryTranslationNameMeta,
        primaryTranslationName.isAcceptableOrUnknown(
          data['primary_translation_name']!,
          _primaryTranslationNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryTranslationNameMeta);
    }
    if (data.containsKey('note_text')) {
      context.handle(
        _noteTextMeta,
        noteText.isAcceptableOrUnknown(data['note_text']!, _noteTextMeta),
      );
    }
    if (data.containsKey('highlight_color_value')) {
      context.handle(
        _highlightColorValueMeta,
        highlightColorValue.isAcceptableOrUnknown(
          data['highlight_color_value']!,
          _highlightColorValueMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserAnnotationEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserAnnotationEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      primaryBookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_book_id'],
      )!,
      primaryChapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}primary_chapter'],
      )!,
      primaryVerse: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}primary_verse'],
      )!,
      primaryTranslationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_translation_id'],
      )!,
      primaryTranslationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_translation_name'],
      )!,
      noteText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_text'],
      ),
      highlightColorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}highlight_color_value'],
      ),
      labels: $UserAnnotationsTable.$converterlabels.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}labels'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserAnnotationsTable createAlias(String alias) {
    return $UserAnnotationsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterlabels =
      const JsonStringListConverter();
}

class UserAnnotationEntry extends DataClass
    implements Insertable<UserAnnotationEntry> {
  final int id;
  final String type;
  final String primaryBookId;
  final int primaryChapter;
  final int primaryVerse;
  final String primaryTranslationId;
  final String primaryTranslationName;
  final String? noteText;
  final int? highlightColorValue;
  final List<String> labels;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserAnnotationEntry({
    required this.id,
    required this.type,
    required this.primaryBookId,
    required this.primaryChapter,
    required this.primaryVerse,
    required this.primaryTranslationId,
    required this.primaryTranslationName,
    this.noteText,
    this.highlightColorValue,
    required this.labels,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['primary_book_id'] = Variable<String>(primaryBookId);
    map['primary_chapter'] = Variable<int>(primaryChapter);
    map['primary_verse'] = Variable<int>(primaryVerse);
    map['primary_translation_id'] = Variable<String>(primaryTranslationId);
    map['primary_translation_name'] = Variable<String>(primaryTranslationName);
    if (!nullToAbsent || noteText != null) {
      map['note_text'] = Variable<String>(noteText);
    }
    if (!nullToAbsent || highlightColorValue != null) {
      map['highlight_color_value'] = Variable<int>(highlightColorValue);
    }
    {
      map['labels'] = Variable<String>(
        $UserAnnotationsTable.$converterlabels.toSql(labels),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserAnnotationsCompanion toCompanion(bool nullToAbsent) {
    return UserAnnotationsCompanion(
      id: Value(id),
      type: Value(type),
      primaryBookId: Value(primaryBookId),
      primaryChapter: Value(primaryChapter),
      primaryVerse: Value(primaryVerse),
      primaryTranslationId: Value(primaryTranslationId),
      primaryTranslationName: Value(primaryTranslationName),
      noteText: noteText == null && nullToAbsent
          ? const Value.absent()
          : Value(noteText),
      highlightColorValue: highlightColorValue == null && nullToAbsent
          ? const Value.absent()
          : Value(highlightColorValue),
      labels: Value(labels),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserAnnotationEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserAnnotationEntry(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      primaryBookId: serializer.fromJson<String>(json['primaryBookId']),
      primaryChapter: serializer.fromJson<int>(json['primaryChapter']),
      primaryVerse: serializer.fromJson<int>(json['primaryVerse']),
      primaryTranslationId: serializer.fromJson<String>(
        json['primaryTranslationId'],
      ),
      primaryTranslationName: serializer.fromJson<String>(
        json['primaryTranslationName'],
      ),
      noteText: serializer.fromJson<String?>(json['noteText']),
      highlightColorValue: serializer.fromJson<int?>(
        json['highlightColorValue'],
      ),
      labels: serializer.fromJson<List<String>>(json['labels']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'primaryBookId': serializer.toJson<String>(primaryBookId),
      'primaryChapter': serializer.toJson<int>(primaryChapter),
      'primaryVerse': serializer.toJson<int>(primaryVerse),
      'primaryTranslationId': serializer.toJson<String>(primaryTranslationId),
      'primaryTranslationName': serializer.toJson<String>(
        primaryTranslationName,
      ),
      'noteText': serializer.toJson<String?>(noteText),
      'highlightColorValue': serializer.toJson<int?>(highlightColorValue),
      'labels': serializer.toJson<List<String>>(labels),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserAnnotationEntry copyWith({
    int? id,
    String? type,
    String? primaryBookId,
    int? primaryChapter,
    int? primaryVerse,
    String? primaryTranslationId,
    String? primaryTranslationName,
    Value<String?> noteText = const Value.absent(),
    Value<int?> highlightColorValue = const Value.absent(),
    List<String>? labels,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserAnnotationEntry(
    id: id ?? this.id,
    type: type ?? this.type,
    primaryBookId: primaryBookId ?? this.primaryBookId,
    primaryChapter: primaryChapter ?? this.primaryChapter,
    primaryVerse: primaryVerse ?? this.primaryVerse,
    primaryTranslationId: primaryTranslationId ?? this.primaryTranslationId,
    primaryTranslationName:
        primaryTranslationName ?? this.primaryTranslationName,
    noteText: noteText.present ? noteText.value : this.noteText,
    highlightColorValue: highlightColorValue.present
        ? highlightColorValue.value
        : this.highlightColorValue,
    labels: labels ?? this.labels,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserAnnotationEntry copyWithCompanion(UserAnnotationsCompanion data) {
    return UserAnnotationEntry(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      primaryBookId: data.primaryBookId.present
          ? data.primaryBookId.value
          : this.primaryBookId,
      primaryChapter: data.primaryChapter.present
          ? data.primaryChapter.value
          : this.primaryChapter,
      primaryVerse: data.primaryVerse.present
          ? data.primaryVerse.value
          : this.primaryVerse,
      primaryTranslationId: data.primaryTranslationId.present
          ? data.primaryTranslationId.value
          : this.primaryTranslationId,
      primaryTranslationName: data.primaryTranslationName.present
          ? data.primaryTranslationName.value
          : this.primaryTranslationName,
      noteText: data.noteText.present ? data.noteText.value : this.noteText,
      highlightColorValue: data.highlightColorValue.present
          ? data.highlightColorValue.value
          : this.highlightColorValue,
      labels: data.labels.present ? data.labels.value : this.labels,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserAnnotationEntry(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('primaryBookId: $primaryBookId, ')
          ..write('primaryChapter: $primaryChapter, ')
          ..write('primaryVerse: $primaryVerse, ')
          ..write('primaryTranslationId: $primaryTranslationId, ')
          ..write('primaryTranslationName: $primaryTranslationName, ')
          ..write('noteText: $noteText, ')
          ..write('highlightColorValue: $highlightColorValue, ')
          ..write('labels: $labels, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    primaryBookId,
    primaryChapter,
    primaryVerse,
    primaryTranslationId,
    primaryTranslationName,
    noteText,
    highlightColorValue,
    labels,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserAnnotationEntry &&
          other.id == this.id &&
          other.type == this.type &&
          other.primaryBookId == this.primaryBookId &&
          other.primaryChapter == this.primaryChapter &&
          other.primaryVerse == this.primaryVerse &&
          other.primaryTranslationId == this.primaryTranslationId &&
          other.primaryTranslationName == this.primaryTranslationName &&
          other.noteText == this.noteText &&
          other.highlightColorValue == this.highlightColorValue &&
          other.labels == this.labels &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserAnnotationsCompanion extends UpdateCompanion<UserAnnotationEntry> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> primaryBookId;
  final Value<int> primaryChapter;
  final Value<int> primaryVerse;
  final Value<String> primaryTranslationId;
  final Value<String> primaryTranslationName;
  final Value<String?> noteText;
  final Value<int?> highlightColorValue;
  final Value<List<String>> labels;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UserAnnotationsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.primaryBookId = const Value.absent(),
    this.primaryChapter = const Value.absent(),
    this.primaryVerse = const Value.absent(),
    this.primaryTranslationId = const Value.absent(),
    this.primaryTranslationName = const Value.absent(),
    this.noteText = const Value.absent(),
    this.highlightColorValue = const Value.absent(),
    this.labels = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserAnnotationsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String primaryBookId,
    required int primaryChapter,
    required int primaryVerse,
    required String primaryTranslationId,
    required String primaryTranslationName,
    this.noteText = const Value.absent(),
    this.highlightColorValue = const Value.absent(),
    this.labels = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : type = Value(type),
       primaryBookId = Value(primaryBookId),
       primaryChapter = Value(primaryChapter),
       primaryVerse = Value(primaryVerse),
       primaryTranslationId = Value(primaryTranslationId),
       primaryTranslationName = Value(primaryTranslationName);
  static Insertable<UserAnnotationEntry> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? primaryBookId,
    Expression<int>? primaryChapter,
    Expression<int>? primaryVerse,
    Expression<String>? primaryTranslationId,
    Expression<String>? primaryTranslationName,
    Expression<String>? noteText,
    Expression<int>? highlightColorValue,
    Expression<String>? labels,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (primaryBookId != null) 'primary_book_id': primaryBookId,
      if (primaryChapter != null) 'primary_chapter': primaryChapter,
      if (primaryVerse != null) 'primary_verse': primaryVerse,
      if (primaryTranslationId != null)
        'primary_translation_id': primaryTranslationId,
      if (primaryTranslationName != null)
        'primary_translation_name': primaryTranslationName,
      if (noteText != null) 'note_text': noteText,
      if (highlightColorValue != null)
        'highlight_color_value': highlightColorValue,
      if (labels != null) 'labels': labels,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserAnnotationsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String>? primaryBookId,
    Value<int>? primaryChapter,
    Value<int>? primaryVerse,
    Value<String>? primaryTranslationId,
    Value<String>? primaryTranslationName,
    Value<String?>? noteText,
    Value<int?>? highlightColorValue,
    Value<List<String>>? labels,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return UserAnnotationsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      primaryBookId: primaryBookId ?? this.primaryBookId,
      primaryChapter: primaryChapter ?? this.primaryChapter,
      primaryVerse: primaryVerse ?? this.primaryVerse,
      primaryTranslationId: primaryTranslationId ?? this.primaryTranslationId,
      primaryTranslationName:
          primaryTranslationName ?? this.primaryTranslationName,
      noteText: noteText ?? this.noteText,
      highlightColorValue: highlightColorValue ?? this.highlightColorValue,
      labels: labels ?? this.labels,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (primaryBookId.present) {
      map['primary_book_id'] = Variable<String>(primaryBookId.value);
    }
    if (primaryChapter.present) {
      map['primary_chapter'] = Variable<int>(primaryChapter.value);
    }
    if (primaryVerse.present) {
      map['primary_verse'] = Variable<int>(primaryVerse.value);
    }
    if (primaryTranslationId.present) {
      map['primary_translation_id'] = Variable<String>(
        primaryTranslationId.value,
      );
    }
    if (primaryTranslationName.present) {
      map['primary_translation_name'] = Variable<String>(
        primaryTranslationName.value,
      );
    }
    if (noteText.present) {
      map['note_text'] = Variable<String>(noteText.value);
    }
    if (highlightColorValue.present) {
      map['highlight_color_value'] = Variable<int>(highlightColorValue.value);
    }
    if (labels.present) {
      map['labels'] = Variable<String>(
        $UserAnnotationsTable.$converterlabels.toSql(labels.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserAnnotationsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('primaryBookId: $primaryBookId, ')
          ..write('primaryChapter: $primaryChapter, ')
          ..write('primaryVerse: $primaryVerse, ')
          ..write('primaryTranslationId: $primaryTranslationId, ')
          ..write('primaryTranslationName: $primaryTranslationName, ')
          ..write('noteText: $noteText, ')
          ..write('highlightColorValue: $highlightColorValue, ')
          ..write('labels: $labels, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AnnotationVersesTable extends AnnotationVerses
    with TableInfo<$AnnotationVersesTable, AnnotationVerseEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnnotationVersesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _annotationIdMeta = const VerificationMeta(
    'annotationId',
  );
  @override
  late final GeneratedColumn<int> annotationId = GeneratedColumn<int>(
    'annotation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_annotations (id)',
    ),
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
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterMeta = const VerificationMeta(
    'chapter',
  );
  @override
  late final GeneratedColumn<int> chapter = GeneratedColumn<int>(
    'chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseMeta = const VerificationMeta('verse');
  @override
  late final GeneratedColumn<int> verse = GeneratedColumn<int>(
    'verse',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  );
  static const VerificationMeta _translationNameMeta = const VerificationMeta(
    'translationName',
  );
  @override
  late final GeneratedColumn<String> translationName = GeneratedColumn<String>(
    'translation_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    annotationId,
    sortOrder,
    bookId,
    chapter,
    verse,
    translationId,
    translationName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'annotation_verses';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnnotationVerseEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('annotation_id')) {
      context.handle(
        _annotationIdMeta,
        annotationId.isAcceptableOrUnknown(
          data['annotation_id']!,
          _annotationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_annotationIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter')) {
      context.handle(
        _chapterMeta,
        chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterMeta);
    }
    if (data.containsKey('verse')) {
      context.handle(
        _verseMeta,
        verse.isAcceptableOrUnknown(data['verse']!, _verseMeta),
      );
    } else if (isInserting) {
      context.missing(_verseMeta);
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
    if (data.containsKey('translation_name')) {
      context.handle(
        _translationNameMeta,
        translationName.isAcceptableOrUnknown(
          data['translation_name']!,
          _translationNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {annotationId, sortOrder},
  ];
  @override
  AnnotationVerseEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnnotationVerseEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      annotationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}annotation_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      chapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter'],
      )!,
      verse: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse'],
      )!,
      translationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_id'],
      )!,
      translationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_name'],
      )!,
    );
  }

  @override
  $AnnotationVersesTable createAlias(String alias) {
    return $AnnotationVersesTable(attachedDatabase, alias);
  }
}

class AnnotationVerseEntry extends DataClass
    implements Insertable<AnnotationVerseEntry> {
  final int id;
  final int annotationId;
  final int sortOrder;
  final String bookId;
  final int chapter;
  final int verse;
  final String translationId;
  final String translationName;
  const AnnotationVerseEntry({
    required this.id,
    required this.annotationId,
    required this.sortOrder,
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.translationId,
    required this.translationName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['annotation_id'] = Variable<int>(annotationId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['book_id'] = Variable<String>(bookId);
    map['chapter'] = Variable<int>(chapter);
    map['verse'] = Variable<int>(verse);
    map['translation_id'] = Variable<String>(translationId);
    map['translation_name'] = Variable<String>(translationName);
    return map;
  }

  AnnotationVersesCompanion toCompanion(bool nullToAbsent) {
    return AnnotationVersesCompanion(
      id: Value(id),
      annotationId: Value(annotationId),
      sortOrder: Value(sortOrder),
      bookId: Value(bookId),
      chapter: Value(chapter),
      verse: Value(verse),
      translationId: Value(translationId),
      translationName: Value(translationName),
    );
  }

  factory AnnotationVerseEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnnotationVerseEntry(
      id: serializer.fromJson<int>(json['id']),
      annotationId: serializer.fromJson<int>(json['annotationId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      bookId: serializer.fromJson<String>(json['bookId']),
      chapter: serializer.fromJson<int>(json['chapter']),
      verse: serializer.fromJson<int>(json['verse']),
      translationId: serializer.fromJson<String>(json['translationId']),
      translationName: serializer.fromJson<String>(json['translationName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'annotationId': serializer.toJson<int>(annotationId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'bookId': serializer.toJson<String>(bookId),
      'chapter': serializer.toJson<int>(chapter),
      'verse': serializer.toJson<int>(verse),
      'translationId': serializer.toJson<String>(translationId),
      'translationName': serializer.toJson<String>(translationName),
    };
  }

  AnnotationVerseEntry copyWith({
    int? id,
    int? annotationId,
    int? sortOrder,
    String? bookId,
    int? chapter,
    int? verse,
    String? translationId,
    String? translationName,
  }) => AnnotationVerseEntry(
    id: id ?? this.id,
    annotationId: annotationId ?? this.annotationId,
    sortOrder: sortOrder ?? this.sortOrder,
    bookId: bookId ?? this.bookId,
    chapter: chapter ?? this.chapter,
    verse: verse ?? this.verse,
    translationId: translationId ?? this.translationId,
    translationName: translationName ?? this.translationName,
  );
  AnnotationVerseEntry copyWithCompanion(AnnotationVersesCompanion data) {
    return AnnotationVerseEntry(
      id: data.id.present ? data.id.value : this.id,
      annotationId: data.annotationId.present
          ? data.annotationId.value
          : this.annotationId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      verse: data.verse.present ? data.verse.value : this.verse,
      translationId: data.translationId.present
          ? data.translationId.value
          : this.translationId,
      translationName: data.translationName.present
          ? data.translationName.value
          : this.translationName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnnotationVerseEntry(')
          ..write('id: $id, ')
          ..write('annotationId: $annotationId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('bookId: $bookId, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('translationId: $translationId, ')
          ..write('translationName: $translationName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    annotationId,
    sortOrder,
    bookId,
    chapter,
    verse,
    translationId,
    translationName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnnotationVerseEntry &&
          other.id == this.id &&
          other.annotationId == this.annotationId &&
          other.sortOrder == this.sortOrder &&
          other.bookId == this.bookId &&
          other.chapter == this.chapter &&
          other.verse == this.verse &&
          other.translationId == this.translationId &&
          other.translationName == this.translationName);
}

class AnnotationVersesCompanion extends UpdateCompanion<AnnotationVerseEntry> {
  final Value<int> id;
  final Value<int> annotationId;
  final Value<int> sortOrder;
  final Value<String> bookId;
  final Value<int> chapter;
  final Value<int> verse;
  final Value<String> translationId;
  final Value<String> translationName;
  const AnnotationVersesCompanion({
    this.id = const Value.absent(),
    this.annotationId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapter = const Value.absent(),
    this.verse = const Value.absent(),
    this.translationId = const Value.absent(),
    this.translationName = const Value.absent(),
  });
  AnnotationVersesCompanion.insert({
    this.id = const Value.absent(),
    required int annotationId,
    required int sortOrder,
    required String bookId,
    required int chapter,
    required int verse,
    required String translationId,
    required String translationName,
  }) : annotationId = Value(annotationId),
       sortOrder = Value(sortOrder),
       bookId = Value(bookId),
       chapter = Value(chapter),
       verse = Value(verse),
       translationId = Value(translationId),
       translationName = Value(translationName);
  static Insertable<AnnotationVerseEntry> custom({
    Expression<int>? id,
    Expression<int>? annotationId,
    Expression<int>? sortOrder,
    Expression<String>? bookId,
    Expression<int>? chapter,
    Expression<int>? verse,
    Expression<String>? translationId,
    Expression<String>? translationName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (annotationId != null) 'annotation_id': annotationId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (bookId != null) 'book_id': bookId,
      if (chapter != null) 'chapter': chapter,
      if (verse != null) 'verse': verse,
      if (translationId != null) 'translation_id': translationId,
      if (translationName != null) 'translation_name': translationName,
    });
  }

  AnnotationVersesCompanion copyWith({
    Value<int>? id,
    Value<int>? annotationId,
    Value<int>? sortOrder,
    Value<String>? bookId,
    Value<int>? chapter,
    Value<int>? verse,
    Value<String>? translationId,
    Value<String>? translationName,
  }) {
    return AnnotationVersesCompanion(
      id: id ?? this.id,
      annotationId: annotationId ?? this.annotationId,
      sortOrder: sortOrder ?? this.sortOrder,
      bookId: bookId ?? this.bookId,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      translationId: translationId ?? this.translationId,
      translationName: translationName ?? this.translationName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (annotationId.present) {
      map['annotation_id'] = Variable<int>(annotationId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<int>(chapter.value);
    }
    if (verse.present) {
      map['verse'] = Variable<int>(verse.value);
    }
    if (translationId.present) {
      map['translation_id'] = Variable<String>(translationId.value);
    }
    if (translationName.present) {
      map['translation_name'] = Variable<String>(translationName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnnotationVersesCompanion(')
          ..write('id: $id, ')
          ..write('annotationId: $annotationId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('bookId: $bookId, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('translationId: $translationId, ')
          ..write('translationName: $translationName')
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
  late final $UserAnnotationsTable userAnnotations = $UserAnnotationsTable(
    this,
  );
  late final $AnnotationVersesTable annotationVerses = $AnnotationVersesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    translations,
    books,
    chapters,
    verses,
    userAnnotations,
    annotationVerses,
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
      Value<int> parserVersion,
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
      Value<int> parserVersion,
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

  ColumnFilters<int> get parserVersion => $composableBuilder(
    column: $table.parserVersion,
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

  ColumnOrderings<int> get parserVersion => $composableBuilder(
    column: $table.parserVersion,
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

  GeneratedColumn<int> get parserVersion => $composableBuilder(
    column: $table.parserVersion,
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
                Value<int> parserVersion = const Value.absent(),
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
                parserVersion: parserVersion,
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
                Value<int> parserVersion = const Value.absent(),
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
                parserVersion: parserVersion,
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
      Value<List<BibleTocLabel>?> tocLabels,
      Value<List<BibleDocumentBlock>?> introductionBlocks,
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
      Value<List<BibleTocLabel>?> tocLabels,
      Value<List<BibleDocumentBlock>?> introductionBlocks,
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

  ColumnOrderings<String> get tocLabels => $composableBuilder(
    column: $table.tocLabels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get introductionBlocks => $composableBuilder(
    column: $table.introductionBlocks,
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

  GeneratedColumnWithTypeConverter<List<BibleTocLabel>?, String>
  get tocLabels =>
      $composableBuilder(column: $table.tocLabels, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<BibleDocumentBlock>?, String>
  get introductionBlocks => $composableBuilder(
    column: $table.introductionBlocks,
    builder: (column) => column,
  );

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
                Value<List<BibleTocLabel>?> tocLabels = const Value.absent(),
                Value<List<BibleDocumentBlock>?> introductionBlocks =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                translationId: translationId,
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
                required String translationId,
                required String name,
                required String shortName,
                required int bookNumber,
                required int bookType,
                Value<List<BibleTocLabel>?> tocLabels = const Value.absent(),
                Value<List<BibleDocumentBlock>?> introductionBlocks =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                translationId: translationId,
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
      Value<List<BibleDocumentBlock>?> blocks,
    });
typedef $$ChaptersTableUpdateCompanionBuilder =
    ChaptersCompanion Function({
      Value<int> id,
      Value<String> bookId,
      Value<int> number,
      Value<List<BibleDocumentBlock>?> blocks,
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

  ColumnWithTypeConverterFilters<
    List<BibleDocumentBlock>?,
    List<BibleDocumentBlock>,
    String
  >
  get blocks => $composableBuilder(
    column: $table.blocks,
    builder: (column) => ColumnWithTypeConverterFilters(column),
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

  ColumnOrderings<String> get blocks => $composableBuilder(
    column: $table.blocks,
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

  GeneratedColumnWithTypeConverter<List<BibleDocumentBlock>?, String>
  get blocks =>
      $composableBuilder(column: $table.blocks, builder: (column) => column);

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
                Value<List<BibleDocumentBlock>?> blocks = const Value.absent(),
              }) => ChaptersCompanion(
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
              }) => ChaptersCompanion.insert(
                id: id,
                bookId: bookId,
                number: number,
                blocks: blocks,
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
      Value<List<BibleVerseSpan>?> spans,
      Value<List<BibleFootnote>?> footnotes,
      Value<List<BibleCrossReference>?> crossReferences,
    });
typedef $$VersesTableUpdateCompanionBuilder =
    VersesCompanion Function({
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
                Value<List<BibleVerseSpan>?> spans = const Value.absent(),
                Value<List<BibleFootnote>?> footnotes = const Value.absent(),
                Value<List<BibleCrossReference>?> crossReferences =
                    const Value.absent(),
              }) => VersesCompanion(
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
              }) => VersesCompanion.insert(
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
typedef $$UserAnnotationsTableCreateCompanionBuilder =
    UserAnnotationsCompanion Function({
      Value<int> id,
      required String type,
      required String primaryBookId,
      required int primaryChapter,
      required int primaryVerse,
      required String primaryTranslationId,
      required String primaryTranslationName,
      Value<String?> noteText,
      Value<int?> highlightColorValue,
      Value<List<String>> labels,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$UserAnnotationsTableUpdateCompanionBuilder =
    UserAnnotationsCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<String> primaryBookId,
      Value<int> primaryChapter,
      Value<int> primaryVerse,
      Value<String> primaryTranslationId,
      Value<String> primaryTranslationName,
      Value<String?> noteText,
      Value<int?> highlightColorValue,
      Value<List<String>> labels,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$UserAnnotationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $UserAnnotationsTable,
          UserAnnotationEntry
        > {
  $$UserAnnotationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$AnnotationVersesTable, List<AnnotationVerseEntry>>
  _annotationVersesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.annotationVerses,
    aliasName: $_aliasNameGenerator(
      db.userAnnotations.id,
      db.annotationVerses.annotationId,
    ),
  );

  $$AnnotationVersesTableProcessedTableManager get annotationVersesRefs {
    final manager = $$AnnotationVersesTableTableManager(
      $_db,
      $_db.annotationVerses,
    ).filter((f) => f.annotationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _annotationVersesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserAnnotationsTableFilterComposer
    extends Composer<_$AppDatabase, $UserAnnotationsTable> {
  $$UserAnnotationsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryBookId => $composableBuilder(
    column: $table.primaryBookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get primaryChapter => $composableBuilder(
    column: $table.primaryChapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get primaryVerse => $composableBuilder(
    column: $table.primaryVerse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryTranslationId => $composableBuilder(
    column: $table.primaryTranslationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryTranslationName => $composableBuilder(
    column: $table.primaryTranslationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteText => $composableBuilder(
    column: $table.noteText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get highlightColorValue => $composableBuilder(
    column: $table.highlightColorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> annotationVersesRefs(
    Expression<bool> Function($$AnnotationVersesTableFilterComposer f) f,
  ) {
    final $$AnnotationVersesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.annotationVerses,
      getReferencedColumn: (t) => t.annotationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnnotationVersesTableFilterComposer(
            $db: $db,
            $table: $db.annotationVerses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserAnnotationsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserAnnotationsTable> {
  $$UserAnnotationsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryBookId => $composableBuilder(
    column: $table.primaryBookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get primaryChapter => $composableBuilder(
    column: $table.primaryChapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get primaryVerse => $composableBuilder(
    column: $table.primaryVerse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryTranslationId => $composableBuilder(
    column: $table.primaryTranslationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryTranslationName => $composableBuilder(
    column: $table.primaryTranslationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteText => $composableBuilder(
    column: $table.noteText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get highlightColorValue => $composableBuilder(
    column: $table.highlightColorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserAnnotationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserAnnotationsTable> {
  $$UserAnnotationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get primaryBookId => $composableBuilder(
    column: $table.primaryBookId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get primaryChapter => $composableBuilder(
    column: $table.primaryChapter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get primaryVerse => $composableBuilder(
    column: $table.primaryVerse,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryTranslationId => $composableBuilder(
    column: $table.primaryTranslationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryTranslationName => $composableBuilder(
    column: $table.primaryTranslationName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get noteText =>
      $composableBuilder(column: $table.noteText, builder: (column) => column);

  GeneratedColumn<int> get highlightColorValue => $composableBuilder(
    column: $table.highlightColorValue,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get labels =>
      $composableBuilder(column: $table.labels, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> annotationVersesRefs<T extends Object>(
    Expression<T> Function($$AnnotationVersesTableAnnotationComposer a) f,
  ) {
    final $$AnnotationVersesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.annotationVerses,
      getReferencedColumn: (t) => t.annotationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnnotationVersesTableAnnotationComposer(
            $db: $db,
            $table: $db.annotationVerses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserAnnotationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserAnnotationsTable,
          UserAnnotationEntry,
          $$UserAnnotationsTableFilterComposer,
          $$UserAnnotationsTableOrderingComposer,
          $$UserAnnotationsTableAnnotationComposer,
          $$UserAnnotationsTableCreateCompanionBuilder,
          $$UserAnnotationsTableUpdateCompanionBuilder,
          (UserAnnotationEntry, $$UserAnnotationsTableReferences),
          UserAnnotationEntry,
          PrefetchHooks Function({bool annotationVersesRefs})
        > {
  $$UserAnnotationsTableTableManager(
    _$AppDatabase db,
    $UserAnnotationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserAnnotationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserAnnotationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserAnnotationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> primaryBookId = const Value.absent(),
                Value<int> primaryChapter = const Value.absent(),
                Value<int> primaryVerse = const Value.absent(),
                Value<String> primaryTranslationId = const Value.absent(),
                Value<String> primaryTranslationName = const Value.absent(),
                Value<String?> noteText = const Value.absent(),
                Value<int?> highlightColorValue = const Value.absent(),
                Value<List<String>> labels = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserAnnotationsCompanion(
                id: id,
                type: type,
                primaryBookId: primaryBookId,
                primaryChapter: primaryChapter,
                primaryVerse: primaryVerse,
                primaryTranslationId: primaryTranslationId,
                primaryTranslationName: primaryTranslationName,
                noteText: noteText,
                highlightColorValue: highlightColorValue,
                labels: labels,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required String primaryBookId,
                required int primaryChapter,
                required int primaryVerse,
                required String primaryTranslationId,
                required String primaryTranslationName,
                Value<String?> noteText = const Value.absent(),
                Value<int?> highlightColorValue = const Value.absent(),
                Value<List<String>> labels = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserAnnotationsCompanion.insert(
                id: id,
                type: type,
                primaryBookId: primaryBookId,
                primaryChapter: primaryChapter,
                primaryVerse: primaryVerse,
                primaryTranslationId: primaryTranslationId,
                primaryTranslationName: primaryTranslationName,
                noteText: noteText,
                highlightColorValue: highlightColorValue,
                labels: labels,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserAnnotationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({annotationVersesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (annotationVersesRefs) db.annotationVerses,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (annotationVersesRefs)
                    await $_getPrefetchedData<
                      UserAnnotationEntry,
                      $UserAnnotationsTable,
                      AnnotationVerseEntry
                    >(
                      currentTable: table,
                      referencedTable: $$UserAnnotationsTableReferences
                          ._annotationVersesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$UserAnnotationsTableReferences(
                            db,
                            table,
                            p0,
                          ).annotationVersesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.annotationId == item.id,
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

typedef $$UserAnnotationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserAnnotationsTable,
      UserAnnotationEntry,
      $$UserAnnotationsTableFilterComposer,
      $$UserAnnotationsTableOrderingComposer,
      $$UserAnnotationsTableAnnotationComposer,
      $$UserAnnotationsTableCreateCompanionBuilder,
      $$UserAnnotationsTableUpdateCompanionBuilder,
      (UserAnnotationEntry, $$UserAnnotationsTableReferences),
      UserAnnotationEntry,
      PrefetchHooks Function({bool annotationVersesRefs})
    >;
typedef $$AnnotationVersesTableCreateCompanionBuilder =
    AnnotationVersesCompanion Function({
      Value<int> id,
      required int annotationId,
      required int sortOrder,
      required String bookId,
      required int chapter,
      required int verse,
      required String translationId,
      required String translationName,
    });
typedef $$AnnotationVersesTableUpdateCompanionBuilder =
    AnnotationVersesCompanion Function({
      Value<int> id,
      Value<int> annotationId,
      Value<int> sortOrder,
      Value<String> bookId,
      Value<int> chapter,
      Value<int> verse,
      Value<String> translationId,
      Value<String> translationName,
    });

final class $$AnnotationVersesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AnnotationVersesTable,
          AnnotationVerseEntry
        > {
  $$AnnotationVersesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UserAnnotationsTable _annotationIdTable(_$AppDatabase db) =>
      db.userAnnotations.createAlias(
        $_aliasNameGenerator(
          db.annotationVerses.annotationId,
          db.userAnnotations.id,
        ),
      );

  $$UserAnnotationsTableProcessedTableManager get annotationId {
    final $_column = $_itemColumn<int>('annotation_id')!;

    final manager = $$UserAnnotationsTableTableManager(
      $_db,
      $_db.userAnnotations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_annotationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AnnotationVersesTableFilterComposer
    extends Composer<_$AppDatabase, $AnnotationVersesTable> {
  $$AnnotationVersesTableFilterComposer({
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

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translationName => $composableBuilder(
    column: $table.translationName,
    builder: (column) => ColumnFilters(column),
  );

  $$UserAnnotationsTableFilterComposer get annotationId {
    final $$UserAnnotationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.annotationId,
      referencedTable: $db.userAnnotations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserAnnotationsTableFilterComposer(
            $db: $db,
            $table: $db.userAnnotations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnnotationVersesTableOrderingComposer
    extends Composer<_$AppDatabase, $AnnotationVersesTable> {
  $$AnnotationVersesTableOrderingComposer({
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

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationName => $composableBuilder(
    column: $table.translationName,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserAnnotationsTableOrderingComposer get annotationId {
    final $$UserAnnotationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.annotationId,
      referencedTable: $db.userAnnotations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserAnnotationsTableOrderingComposer(
            $db: $db,
            $table: $db.userAnnotations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnnotationVersesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnnotationVersesTable> {
  $$AnnotationVersesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<int> get verse =>
      $composableBuilder(column: $table.verse, builder: (column) => column);

  GeneratedColumn<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translationName => $composableBuilder(
    column: $table.translationName,
    builder: (column) => column,
  );

  $$UserAnnotationsTableAnnotationComposer get annotationId {
    final $$UserAnnotationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.annotationId,
      referencedTable: $db.userAnnotations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserAnnotationsTableAnnotationComposer(
            $db: $db,
            $table: $db.userAnnotations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnnotationVersesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnnotationVersesTable,
          AnnotationVerseEntry,
          $$AnnotationVersesTableFilterComposer,
          $$AnnotationVersesTableOrderingComposer,
          $$AnnotationVersesTableAnnotationComposer,
          $$AnnotationVersesTableCreateCompanionBuilder,
          $$AnnotationVersesTableUpdateCompanionBuilder,
          (AnnotationVerseEntry, $$AnnotationVersesTableReferences),
          AnnotationVerseEntry,
          PrefetchHooks Function({bool annotationId})
        > {
  $$AnnotationVersesTableTableManager(
    _$AppDatabase db,
    $AnnotationVersesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnnotationVersesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnnotationVersesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnnotationVersesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> annotationId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> chapter = const Value.absent(),
                Value<int> verse = const Value.absent(),
                Value<String> translationId = const Value.absent(),
                Value<String> translationName = const Value.absent(),
              }) => AnnotationVersesCompanion(
                id: id,
                annotationId: annotationId,
                sortOrder: sortOrder,
                bookId: bookId,
                chapter: chapter,
                verse: verse,
                translationId: translationId,
                translationName: translationName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int annotationId,
                required int sortOrder,
                required String bookId,
                required int chapter,
                required int verse,
                required String translationId,
                required String translationName,
              }) => AnnotationVersesCompanion.insert(
                id: id,
                annotationId: annotationId,
                sortOrder: sortOrder,
                bookId: bookId,
                chapter: chapter,
                verse: verse,
                translationId: translationId,
                translationName: translationName,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AnnotationVersesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({annotationId = false}) {
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
                    if (annotationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.annotationId,
                                referencedTable:
                                    $$AnnotationVersesTableReferences
                                        ._annotationIdTable(db),
                                referencedColumn:
                                    $$AnnotationVersesTableReferences
                                        ._annotationIdTable(db)
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

typedef $$AnnotationVersesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnnotationVersesTable,
      AnnotationVerseEntry,
      $$AnnotationVersesTableFilterComposer,
      $$AnnotationVersesTableOrderingComposer,
      $$AnnotationVersesTableAnnotationComposer,
      $$AnnotationVersesTableCreateCompanionBuilder,
      $$AnnotationVersesTableUpdateCompanionBuilder,
      (AnnotationVerseEntry, $$AnnotationVersesTableReferences),
      AnnotationVerseEntry,
      PrefetchHooks Function({bool annotationId})
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
  $$UserAnnotationsTableTableManager get userAnnotations =>
      $$UserAnnotationsTableTableManager(_db, _db.userAnnotations);
  $$AnnotationVersesTableTableManager get annotationVerses =>
      $$AnnotationVersesTableTableManager(_db, _db.annotationVerses);
}
