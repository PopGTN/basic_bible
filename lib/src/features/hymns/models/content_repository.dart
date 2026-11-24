import 'package:equatable/equatable.dart';

/// A content source the user subscribed to, F-Droid style: a URL serving a
/// repository index (`format: basic-bible-repo`). The official repository is
/// always present; third-party ones are added by the user after accepting
/// the disclaimer.
class ContentRepository extends Equatable {
  const ContentRepository({
    required this.id,
    required this.url,
    required this.name,
    this.description,
    this.maintainer,
    this.homepage,
    this.takedownContact,
    this.disclaimer,
    this.enabled = true,
    this.isOfficial = false,
  });

  final String id;
  final String url;
  final String name;
  final String? description;
  final String? maintainer;
  final String? homepage;

  /// mailto: or https: link for copyright/takedown reports about this repo.
  final String? takedownContact;

  /// The repo owner's own disclaimer text, shown alongside ours.
  final String? disclaimer;
  final bool enabled;
  final bool isOfficial;

  ContentRepository copyWith({
    String? name,
    String? description,
    String? maintainer,
    String? homepage,
    String? takedownContact,
    String? disclaimer,
    bool? enabled,
  }) => ContentRepository(
    id: id,
    url: url,
    name: name ?? this.name,
    description: description ?? this.description,
    maintainer: maintainer ?? this.maintainer,
    homepage: homepage ?? this.homepage,
    takedownContact: takedownContact ?? this.takedownContact,
    disclaimer: disclaimer ?? this.disclaimer,
    enabled: enabled ?? this.enabled,
    isOfficial: isOfficial,
  );

  factory ContentRepository.fromJson(Map<String, dynamic> json) =>
      ContentRepository(
        id: '${json['id'] ?? ''}',
        url: '${json['url'] ?? ''}',
        name: '${json['name'] ?? ''}',
        description: _opt(json['description']),
        maintainer: _opt(json['maintainer']),
        homepage: _opt(json['homepage']),
        takedownContact: _opt(json['takedownContact']),
        disclaimer: _opt(json['disclaimer']),
        enabled: json['enabled'] != false,
        isOfficial: json['isOfficial'] == true,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'name': name,
    'description': ?description,
    'maintainer': ?maintainer,
    'homepage': ?homepage,
    'takedownContact': ?takedownContact,
    'disclaimer': ?disclaimer,
    'enabled': enabled,
    'isOfficial': isOfficial,
  };

  @override
  List<Object?> get props => [
    id,
    url,
    name,
    description,
    maintainer,
    homepage,
    takedownContact,
    disclaimer,
    enabled,
    isOfficial,
  ];
}

/// Rights statuses that must never be offered for download, whatever the
/// repository says (same vocabulary as bible-data/catalog/README.md).
const kNonDistributableRights = {'unclear', 'copyrighted_no_distribution'};

/// One downloadable hymnal listed in a repository index.
class RepoHymnalEntry extends Equatable {
  const RepoHymnalEntry({
    required this.id,
    required this.title,
    required this.downloadUrl,
    this.publisher,
    this.language,
    this.year,
    this.hymnCount,
    this.rightsStatus,
    this.license,
    this.copyrightNotice,
    this.sizeBytes,
    this.sha256,
    this.schemaVersion,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String downloadUrl;
  final String? publisher;
  final String? language;
  final int? year;
  final int? hymnCount;
  final String? rightsStatus;
  final String? license;
  final String? copyrightNotice;
  final int? sizeBytes;
  final String? sha256;
  final int? schemaVersion;
  final String? updatedAt;

  bool get isDownloadable =>
      downloadUrl.isNotEmpty && !kNonDistributableRights.contains(rightsStatus);

  factory RepoHymnalEntry.fromJson(Map<String, dynamic> json) =>
      RepoHymnalEntry(
        id: '${json['id'] ?? ''}'.trim(),
        title: '${json['title'] ?? json['name'] ?? ''}'.trim(),
        downloadUrl: '${json['downloadUrl'] ?? ''}'.trim(),
        publisher: _opt(json['publisher']),
        language: _opt(json['language']),
        year: _int(json['year']),
        hymnCount: _int(json['hymnCount']),
        rightsStatus: _opt(json['rightsStatus']),
        license: _opt(json['license']),
        copyrightNotice: _opt(json['copyrightNotice']),
        sizeBytes: _int(json['sizeBytes']),
        sha256: _opt(json['sha256']),
        schemaVersion: _int(json['schemaVersion']),
        updatedAt: _opt(json['updatedAt']),
      );

  @override
  List<Object?> get props => [id, title, downloadUrl, sha256, updatedAt];
}

/// A fetched repository index.
class RepoIndex {
  const RepoIndex({
    required this.name,
    this.repoId,
    this.description,
    this.maintainer,
    this.homepage,
    this.takedownContact,
    this.disclaimer,
    this.hymnals = const [],
    this.withdrawn = const {},
  });

  final String name;
  final String? repoId;
  final String? description;
  final String? maintainer;
  final String? homepage;
  final String? takedownContact;
  final String? disclaimer;
  final List<RepoHymnalEntry> hymnals;

  /// Ids taken down by the repo owner. Installed copies are removed on the
  /// next refresh — the takedown kill-switch.
  final Set<String> withdrawn;

  /// Throws [FormatException] for anything that isn't a repository index.
  factory RepoIndex.fromJson(Object? decoded) {
    if (decoded is! Map || decoded['format'] != 'basic-bible-repo') {
      throw const FormatException(
        'This address does not serve a repository index '
        '("format": "basic-bible-repo").',
      );
    }
    final repo = decoded['repo'] is Map
        ? Map<String, dynamic>.from(decoded['repo'] as Map)
        : const <String, dynamic>{};
    final name = _opt(repo['name']);
    if (name == null) {
      throw const FormatException('The repository index has no name.');
    }
    final withdrawn = {
      for (final id in decoded['withdrawn'] as List? ?? const []) '$id',
    };
    return RepoIndex(
      name: name,
      repoId: _opt(repo['id']),
      description: _opt(repo['description']),
      maintainer: _opt(repo['maintainer']),
      homepage: _opt(repo['homepage']),
      takedownContact: _opt(repo['takedownContact']),
      disclaimer: _opt(repo['disclaimer']),
      withdrawn: withdrawn,
      hymnals: [
        for (final raw in decoded['hymnals'] as List? ?? const [])
          if (raw is Map)
            if (RepoHymnalEntry.fromJson(Map<String, dynamic>.from(raw))
                case final entry
                when entry.id.isNotEmpty &&
                    entry.title.isNotEmpty &&
                    !withdrawn.contains(entry.id))
              entry,
      ],
    );
  }
}

String? _opt(Object? value) {
  if (value == null) return null;
  final text = '$value'.trim();
  return text.isEmpty ? null : text;
}

int? _int(Object? value) =>
    value is int ? value : int.tryParse('${value ?? ''}');
