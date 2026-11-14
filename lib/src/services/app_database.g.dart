// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $InstalledTranslationsTable extends InstalledTranslations
    with TableInfo<$InstalledTranslationsTable, InstalledTranslationEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstalledTranslationsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'installed_translations';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstalledTranslationEntry> instance, {
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
  InstalledTranslationEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstalledTranslationEntry(
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
  $InstalledTranslationsTable createAlias(String alias) {
    return $InstalledTranslationsTable(attachedDatabase, alias);
  }
}

class InstalledTranslationEntry extends DataClass
    implements Insertable<InstalledTranslationEntry> {
  final String id;
  final String name;
  final String language;
  final String description;
  final String format;
  final String sourceType;

  /// Original source: asset bundle path, download URL, or imported file path.
  /// Used to re-parse when [parserVersion] is bumped.
  final String? sourceLocation;
  final bool isLocal;
  final DateTime importedAt;

  /// Recorded parser version at last parse. Compare against
  /// [AppBibleRepository._currentParserVersion] to detect stale caches.
  final int parserVersion;
  const InstalledTranslationEntry({
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

  InstalledTranslationsCompanion toCompanion(bool nullToAbsent) {
    return InstalledTranslationsCompanion(
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

  factory InstalledTranslationEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstalledTranslationEntry(
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

  InstalledTranslationEntry copyWith({
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
  }) => InstalledTranslationEntry(
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
  InstalledTranslationEntry copyWithCompanion(
    InstalledTranslationsCompanion data,
  ) {
    return InstalledTranslationEntry(
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
    return (StringBuffer('InstalledTranslationEntry(')
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
      (other is InstalledTranslationEntry &&
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

class InstalledTranslationsCompanion
    extends UpdateCompanion<InstalledTranslationEntry> {
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
  const InstalledTranslationsCompanion({
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
  InstalledTranslationsCompanion.insert({
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
  static Insertable<InstalledTranslationEntry> custom({
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

  InstalledTranslationsCompanion copyWith({
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
    return InstalledTranslationsCompanion(
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
    return (StringBuffer('InstalledTranslationsCompanion(')
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
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
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
    deletedAt,
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
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
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
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      ),
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
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
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

  /// Globally stable identity used by sync/export merging. Nullable in the
  /// schema only to keep the v8 ALTER TABLE migration simple; application
  /// code always populates it on insert/backfill.
  final String? uuid;
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

  /// Soft-delete tombstone. Deleted notes keep their row (invisible to the
  /// UI) so other devices/imports see a deterministic deletion instead of a
  /// silently missing note.
  final DateTime? deletedAt;
  const UserAnnotationEntry({
    required this.id,
    this.uuid,
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
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || uuid != null) {
      map['uuid'] = Variable<String>(uuid);
    }
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
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  UserAnnotationsCompanion toCompanion(bool nullToAbsent) {
    return UserAnnotationsCompanion(
      id: Value(id),
      uuid: uuid == null && nullToAbsent ? const Value.absent() : Value(uuid),
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
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory UserAnnotationEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserAnnotationEntry(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String?>(json['uuid']),
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
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String?>(uuid),
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
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  UserAnnotationEntry copyWith({
    int? id,
    Value<String?> uuid = const Value.absent(),
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
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => UserAnnotationEntry(
    id: id ?? this.id,
    uuid: uuid.present ? uuid.value : this.uuid,
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
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  UserAnnotationEntry copyWithCompanion(UserAnnotationsCompanion data) {
    return UserAnnotationEntry(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
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
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserAnnotationEntry(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
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
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
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
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserAnnotationEntry &&
          other.id == this.id &&
          other.uuid == this.uuid &&
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
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class UserAnnotationsCompanion extends UpdateCompanion<UserAnnotationEntry> {
  final Value<int> id;
  final Value<String?> uuid;
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
  final Value<DateTime?> deletedAt;
  const UserAnnotationsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
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
    this.deletedAt = const Value.absent(),
  });
  UserAnnotationsCompanion.insert({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
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
    this.deletedAt = const Value.absent(),
  }) : type = Value(type),
       primaryBookId = Value(primaryBookId),
       primaryChapter = Value(primaryChapter),
       primaryVerse = Value(primaryVerse),
       primaryTranslationId = Value(primaryTranslationId),
       primaryTranslationName = Value(primaryTranslationName);
  static Insertable<UserAnnotationEntry> custom({
    Expression<int>? id,
    Expression<String>? uuid,
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
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
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
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  UserAnnotationsCompanion copyWith({
    Value<int>? id,
    Value<String?>? uuid,
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
    Value<DateTime?>? deletedAt,
  }) {
    return UserAnnotationsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
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
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
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
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserAnnotationsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
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
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
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
  late final $InstalledTranslationsTable installedTranslations =
      $InstalledTranslationsTable(this);
  late final $UserAnnotationsTable userAnnotations = $UserAnnotationsTable(
    this,
  );
  late final $AnnotationVersesTable annotationVerses = $AnnotationVersesTable(
    this,
  );
  late final Index idxUserAnnotationsUuid = Index(
    'idx_user_annotations_uuid',
    'CREATE UNIQUE INDEX idx_user_annotations_uuid ON user_annotations (uuid)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    installedTranslations,
    userAnnotations,
    annotationVerses,
    idxUserAnnotationsUuid,
  ];
}

typedef $$InstalledTranslationsTableCreateCompanionBuilder =
    InstalledTranslationsCompanion Function({
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
typedef $$InstalledTranslationsTableUpdateCompanionBuilder =
    InstalledTranslationsCompanion Function({
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

class $$InstalledTranslationsTableFilterComposer
    extends Composer<_$AppDatabase, $InstalledTranslationsTable> {
  $$InstalledTranslationsTableFilterComposer({
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
}

class $$InstalledTranslationsTableOrderingComposer
    extends Composer<_$AppDatabase, $InstalledTranslationsTable> {
  $$InstalledTranslationsTableOrderingComposer({
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

class $$InstalledTranslationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstalledTranslationsTable> {
  $$InstalledTranslationsTableAnnotationComposer({
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
}

class $$InstalledTranslationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstalledTranslationsTable,
          InstalledTranslationEntry,
          $$InstalledTranslationsTableFilterComposer,
          $$InstalledTranslationsTableOrderingComposer,
          $$InstalledTranslationsTableAnnotationComposer,
          $$InstalledTranslationsTableCreateCompanionBuilder,
          $$InstalledTranslationsTableUpdateCompanionBuilder,
          (
            InstalledTranslationEntry,
            BaseReferences<
              _$AppDatabase,
              $InstalledTranslationsTable,
              InstalledTranslationEntry
            >,
          ),
          InstalledTranslationEntry,
          PrefetchHooks Function()
        > {
  $$InstalledTranslationsTableTableManager(
    _$AppDatabase db,
    $InstalledTranslationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstalledTranslationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$InstalledTranslationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InstalledTranslationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
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
              }) => InstalledTranslationsCompanion(
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
              }) => InstalledTranslationsCompanion.insert(
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InstalledTranslationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstalledTranslationsTable,
      InstalledTranslationEntry,
      $$InstalledTranslationsTableFilterComposer,
      $$InstalledTranslationsTableOrderingComposer,
      $$InstalledTranslationsTableAnnotationComposer,
      $$InstalledTranslationsTableCreateCompanionBuilder,
      $$InstalledTranslationsTableUpdateCompanionBuilder,
      (
        InstalledTranslationEntry,
        BaseReferences<
          _$AppDatabase,
          $InstalledTranslationsTable,
          InstalledTranslationEntry
        >,
      ),
      InstalledTranslationEntry,
      PrefetchHooks Function()
    >;
typedef $$UserAnnotationsTableCreateCompanionBuilder =
    UserAnnotationsCompanion Function({
      Value<int> id,
      Value<String?> uuid,
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
      Value<DateTime?> deletedAt,
    });
typedef $$UserAnnotationsTableUpdateCompanionBuilder =
    UserAnnotationsCompanion Function({
      Value<int> id,
      Value<String?> uuid,
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
      Value<DateTime?> deletedAt,
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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
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

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

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

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

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
                Value<String?> uuid = const Value.absent(),
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
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => UserAnnotationsCompanion(
                id: id,
                uuid: uuid,
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
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> uuid = const Value.absent(),
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
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => UserAnnotationsCompanion.insert(
                id: id,
                uuid: uuid,
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
                deletedAt: deletedAt,
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
  $$InstalledTranslationsTableTableManager get installedTranslations =>
      $$InstalledTranslationsTableTableManager(_db, _db.installedTranslations);
  $$UserAnnotationsTableTableManager get userAnnotations =>
      $$UserAnnotationsTableTableManager(_db, _db.userAnnotations);
  $$AnnotationVersesTableTableManager get annotationVerses =>
      $$AnnotationVersesTableTableManager(_db, _db.annotationVerses);
}
