import 'package:equatable/equatable.dart';

import 'hymn.dart';
import 'hymn_search_index.dart';

/// Where an installed hymnal came from. Drives what the library screen lets
/// the user do with it (bundled books can't be deleted) and who to contact
/// about its rights.
enum HymnalSourceKind { bundled, imported, repository }

/// Book-level metadata. For the "hymnal" v1 format this is the `book` block;
/// for a legacy bare-array file most fields are empty and [title] comes from
/// the file name the user picked.
class HymnalInfo extends Equatable {
  const HymnalInfo({
    required this.id,
    required this.title,
    this.shortTitle,
    this.publisher,
    this.publisherAddress,
    this.publisherUrl,
    this.edition,
    this.year,
    this.language,
    this.isbn,
    this.copyright,
    this.rightsStatus,
    this.permissionNotice,
    this.sourceUrl,
    this.takedownContact,
    this.sourceKind = HymnalSourceKind.imported,
    this.repoId,
    this.repoUrl,
    this.hymnCount = 0,
    this.schemaVersion = 0,
  });

  /// Stable id, unique across all installed books. Repository books are
  /// namespaced `<repoId>/<bookId>` so two repos can't collide.
  final String id;
  final String title;
  final String? shortTitle;
  final String? publisher;
  final String? publisherAddress;
  final String? publisherUrl;
  final String? edition;
  final int? year;
  final String? language;
  final String? isbn;
  final String? copyright;
  final String? rightsStatus;
  final String? permissionNotice;
  final String? sourceUrl;
  final String? takedownContact;
  final HymnalSourceKind sourceKind;
  final String? repoId;
  final String? repoUrl;
  final int hymnCount;

  /// 0 for the legacy bare-array format, otherwise the file's schemaVersion.
  final int schemaVersion;

  String get displayShortTitle =>
      (shortTitle?.trim().isNotEmpty ?? false) ? shortTitle!.trim() : title;

  /// The credit lines that must travel with every copy, share and print.
  List<String> get creditLines => [
    if (copyright?.trim().isNotEmpty ?? false) copyright!.trim(),
    if (permissionNotice?.trim().isNotEmpty ?? false) permissionNotice!.trim(),
  ];

  HymnalInfo copyWith({
    String? id,
    HymnalSourceKind? sourceKind,
    String? repoId,
    String? repoUrl,
    String? takedownContact,
    String? title,
  }) {
    return HymnalInfo(
      id: id ?? this.id,
      title: title ?? this.title,
      shortTitle: shortTitle,
      publisher: publisher,
      publisherAddress: publisherAddress,
      publisherUrl: publisherUrl,
      edition: edition,
      year: year,
      language: language,
      isbn: isbn,
      copyright: copyright,
      rightsStatus: rightsStatus,
      permissionNotice: permissionNotice,
      sourceUrl: sourceUrl,
      takedownContact: takedownContact ?? this.takedownContact,
      sourceKind: sourceKind ?? this.sourceKind,
      repoId: repoId ?? this.repoId,
      repoUrl: repoUrl ?? this.repoUrl,
      hymnCount: hymnCount,
      schemaVersion: schemaVersion,
    );
  }

  factory HymnalInfo.fromJson(Map<String, dynamic> json) {
    String? str(String key) {
      final value = json[key];
      if (value == null) return null;
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    return HymnalInfo(
      id: str('id') ?? '',
      title: str('title') ?? '',
      shortTitle: str('shortTitle'),
      publisher: str('publisher'),
      publisherAddress: str('publisherAddress'),
      publisherUrl: str('publisherUrl'),
      edition: str('edition'),
      year: json['year'] is int
          ? json['year'] as int
          : int.tryParse('${json['year']}'),
      language: str('language'),
      isbn: str('isbn'),
      copyright: str('copyright'),
      rightsStatus: str('rightsStatus'),
      permissionNotice: str('permissionNotice'),
      sourceUrl: str('sourceUrl'),
      takedownContact: str('takedownContact'),
      sourceKind: HymnalSourceKind.values.firstWhere(
        (kind) => kind.name == json['sourceKind'],
        orElse: () => HymnalSourceKind.imported,
      ),
      repoId: str('repoId'),
      repoUrl: str('repoUrl'),
      hymnCount: json['hymnCount'] is int ? json['hymnCount'] as int : 0,
      schemaVersion: json['schemaVersion'] is int
          ? json['schemaVersion'] as int
          : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'shortTitle': ?shortTitle,
    'publisher': ?publisher,
    'publisherAddress': ?publisherAddress,
    'publisherUrl': ?publisherUrl,
    'edition': ?edition,
    'year': ?year,
    'language': ?language,
    'isbn': ?isbn,
    'copyright': ?copyright,
    'rightsStatus': ?rightsStatus,
    'permissionNotice': ?permissionNotice,
    'sourceUrl': ?sourceUrl,
    'takedownContact': ?takedownContact,
    'sourceKind': sourceKind.name,
    'repoId': ?repoId,
    'repoUrl': ?repoUrl,
    'hymnCount': hymnCount,
    'schemaVersion': schemaVersion,
  };

  @override
  List<Object?> get props => [
    id,
    title,
    shortTitle,
    publisher,
    edition,
    year,
    copyright,
    permissionNotice,
    sourceKind,
    repoId,
    repoUrl,
    hymnCount,
    schemaVersion,
  ];
}

/// A parsed book, ready to display and search. Built off the UI isolate by
/// `parseHymnalBytes`, including the normalized [index].
class Hymnal {
  Hymnal({required this.info, required this.hymns, required this.index})
    : _byNumber = {for (final hymn in hymns) hymn.number: hymn};

  final HymnalInfo info;

  /// Sorted by number.
  final List<Hymn> hymns;
  final HymnSearchIndex index;
  final Map<int, Hymn> _byNumber;

  Hymn? byNumber(int number) => _byNumber[number];
}
