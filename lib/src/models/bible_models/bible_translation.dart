import 'package:equatable/equatable.dart';

enum BibleFormat { usfx, usfm, usfmDirectory, osis, zefania, sqlite, zip, auto }

enum BibleSourceType { asset, download, import, session }

enum BibleTranslationAvailability {
  bundled,
  downloadable,
  downloaded,
  imported,
  session,
}

class BibleTranslationArtifact extends Equatable {
  const BibleTranslationArtifact({
    required this.format,
    required this.downloadUrl,
    required this.fileName,
    this.parserVersion,
    this.schemaVersion,
    this.sizeBytes,
    this.sha256,
    this.isPreferred = false,
  });

  final BibleFormat format;
  final String downloadUrl;
  final String fileName;
  final int? parserVersion;
  final int? schemaVersion;
  final int? sizeBytes;
  final String? sha256;
  final bool isPreferred;

  @override
  List<Object?> get props => [
    format,
    downloadUrl,
    fileName,
    parserVersion,
    schemaVersion,
    sizeBytes,
    sha256,
    isPreferred,
  ];
}

class BibleTranslation extends Equatable {
  final String id;
  final String name;
  final String language;
  final String languageName;
  final String description;
  final bool isLocal;
  final String? filePath;
  final String? githubUrl;
  final BibleFormat format;
  final BibleSourceType sourceType;
  final bool bundledByDefault;
  final int displayOrder;
  final List<BibleTranslationArtifact> artifacts;

  const BibleTranslation({
    required this.id,
    required this.name,
    required this.language,
    this.languageName = '',
    required this.description,
    this.isLocal = false,
    this.filePath,
    this.githubUrl,
    this.format = BibleFormat.auto,
    this.sourceType = BibleSourceType.asset,
    this.bundledByDefault = false,
    this.displayOrder = 0,
    this.artifacts = const [],
  });

  BibleTranslation copyWith({
    String? id,
    String? name,
    String? language,
    String? languageName,
    String? description,
    bool? isLocal,
    String? filePath,
    String? githubUrl,
    BibleFormat? format,
    BibleSourceType? sourceType,
    bool? bundledByDefault,
    int? displayOrder,
    List<BibleTranslationArtifact>? artifacts,
  }) {
    return BibleTranslation(
      id: id ?? this.id,
      name: name ?? this.name,
      language: language ?? this.language,
      languageName: languageName ?? this.languageName,
      description: description ?? this.description,
      isLocal: isLocal ?? this.isLocal,
      filePath: filePath ?? this.filePath,
      githubUrl: githubUrl ?? this.githubUrl,
      format: format ?? this.format,
      sourceType: sourceType ?? this.sourceType,
      bundledByDefault: bundledByDefault ?? this.bundledByDefault,
      displayOrder: displayOrder ?? this.displayOrder,
      artifacts: artifacts ?? this.artifacts,
    );
  }

  String get effectiveLanguageName =>
      languageName.trim().isNotEmpty ? languageName.trim() : language;

  BibleTranslationAvailability get availability {
    return switch (sourceType) {
      BibleSourceType.asset => BibleTranslationAvailability.bundled,
      BibleSourceType.import => BibleTranslationAvailability.imported,
      BibleSourceType.session => BibleTranslationAvailability.session,
      BibleSourceType.download =>
        isLocal
            ? BibleTranslationAvailability.downloaded
            : BibleTranslationAvailability.downloadable,
    };
  }

  bool get isReadableNow {
    return availability != BibleTranslationAvailability.downloadable;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    language,
    languageName,
    description,
    isLocal,
    filePath,
    githubUrl,
    format,
    sourceType,
    bundledByDefault,
    displayOrder,
    artifacts,
  ];
}
