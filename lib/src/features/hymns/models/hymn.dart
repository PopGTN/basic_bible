import 'package:equatable/equatable.dart';

/// A labelled block of lines that is not part of the main verse sequence:
/// an optional verse ("Verse 1 of Hymn #2") or an alternate chorus
/// ("Chorus for tune by I. Sankey"). [label] is null for an unlabelled
/// optional chorus (the legacy `addedChorus` field).
class HymnPart extends Equatable {
  const HymnPart({this.label, required this.lines});

  final String? label;
  final List<String> lines;

  Map<String, dynamic> toJson() => {
    if (label != null) 'label': label,
    'lines': lines,
  };

  @override
  List<Object?> get props => [label, lines];
}

/// One hymn. [number] is the hymn's number in its book (the JSON `id`).
class Hymn extends Equatable {
  const Hymn({
    required this.number,
    required this.title,
    this.author = '',
    this.meter = '',
    this.tuneName = '',
    this.verses = const [],
    this.chorus = const [],
    this.optionalVerses = const [],
    this.alternateChoruses = const [],
    this.notes = const [],
    this.copyright,
    this.rightsStatus,
  });

  final int number;
  final String title;
  final String author;
  final String meter;
  final String tuneName;
  final List<List<String>> verses;
  final List<String> chorus;
  final List<HymnPart> optionalVerses;
  final List<HymnPart> alternateChoruses;
  final List<String> notes;

  /// Per-hymn copyright line, shown under the lyrics and appended to copies.
  final String? copyright;

  /// Internal rights bookkeeping (public_domain, unclear, …). Not shown.
  final String? rightsStatus;

  bool get hasChorus => chorus.isNotEmpty;

  /// The first lyric line, used as a list subtitle when it differs from the
  /// title (e.g. "The Solid Rock" → "My hope is built on nothing less").
  String get firstLine {
    if (verses.isNotEmpty && verses.first.isNotEmpty) return verses.first.first;
    if (chorus.isNotEmpty) return chorus.first;
    return '';
  }

  @override
  List<Object?> get props => [
    number,
    title,
    author,
    meter,
    tuneName,
    verses,
    chorus,
    optionalVerses,
    alternateChoruses,
    notes,
    copyright,
    rightsStatus,
  ];
}
