import 'package:equatable/equatable.dart';

enum BibleFormat { usfx, usfm, osis, auto }

enum BibleSourceType { asset, download, import }

class BibleTranslation extends Equatable {
  final String id;
  final String name;
  final String language;
  final String description;
  final bool isLocal;
  final String? filePath;
  final String? githubUrl;
  final BibleFormat format;
  final BibleSourceType sourceType;

  const BibleTranslation({
    required this.id,
    required this.name,
    required this.language,
    required this.description,
    this.isLocal = false,
    this.filePath,
    this.githubUrl,
    this.format = BibleFormat.auto,
    this.sourceType = BibleSourceType.asset,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        language,
        description,
        isLocal,
        filePath,
        githubUrl,
        format,
        sourceType,
      ];
}
