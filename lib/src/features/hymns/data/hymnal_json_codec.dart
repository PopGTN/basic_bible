import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart' show GZipDecoder;
import 'package:flutter/foundation.dart' show compute;

import '../models/hymn.dart';
import '../models/hymn_search_index.dart';
import '../models/hymnal.dart';

/// Thrown when a file isn't a hymnal we can read. [message] is shown to the
/// user, so keep it plain.
class HymnalFormatException implements Exception {
  const HymnalFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Everything `parseHymnalBytes` needs, bundled so it can cross an isolate.
class HymnalParseRequest {
  const HymnalParseRequest({
    required this.bytes,
    required this.fallbackId,
    required this.fallbackTitle,
    this.sourceKind = HymnalSourceKind.imported,
  });

  final Uint8List bytes;

  /// Used when the file has no `book.id` (legacy format).
  final String fallbackId;

  /// Used when the file has no `book.title` (legacy format) — usually the
  /// file name the user picked.
  final String fallbackTitle;
  final HymnalSourceKind sourceKind;
}

/// Hard limits so a hostile or broken file can't exhaust memory.
const int kMaxHymnalBytes = 20 * 1024 * 1024;
const int _maxHymns = 20000;

/// Parses off the UI isolate (inline on web, where `compute` has no isolate;
/// the biggest books still parse in well under a second there).
Future<Hymnal> parseHymnalInBackground(HymnalParseRequest request) =>
    compute(parseHymnalBytes, request);

/// Reads either accepted format:
///
/// 1. Legacy — a bare JSON array of hymns
///    `{id, title, author, meter, tuneName, verses, chorus, addedChorus}`.
/// 2. Hymnal v1 — `{"format": "hymnal", "schemaVersion": 1, "book": {...},
///    "hymns": [...]}`, whose hymns may add `notes`, `optionalVerses`,
///    `alternateChoruses`, `copyright` and `rightsStatus`.
///
/// Gzipped input is detected by its magic bytes. Unknown keys are ignored.
/// Hymns with a duplicate number keep the first occurrence.
Hymnal parseHymnalBytes(HymnalParseRequest request) {
  var bytes = request.bytes;
  if (bytes.length > kMaxHymnalBytes) {
    throw const HymnalFormatException('The file is too large to be a hymnal.');
  }
  if (bytes.length > 2 && bytes[0] == 0x1f && bytes[1] == 0x8b) {
    try {
      bytes = Uint8List.fromList(GZipDecoder().decodeBytes(bytes));
    } catch (_) {
      throw const HymnalFormatException('The compressed file is damaged.');
    }
    if (bytes.length > kMaxHymnalBytes * 4) {
      throw const HymnalFormatException(
        'The file is too large to be a hymnal.',
      );
    }
  }

  final Object? decoded;
  try {
    var text = utf8.decode(bytes, allowMalformed: true);
    if (text.startsWith('﻿')) text = text.substring(1);
    decoded = jsonDecode(text);
  } on FormatException {
    throw const HymnalFormatException('The file is not valid JSON.');
  }

  final List<dynamic> rawHymns;
  Map<String, dynamic> book = const {};
  var schemaVersion = 0;
  if (decoded is List) {
    rawHymns = decoded;
  } else if (decoded is Map && decoded['hymns'] is List) {
    rawHymns = decoded['hymns'] as List;
    if (decoded['book'] is Map) {
      book = Map<String, dynamic>.from(decoded['book'] as Map);
    }
    final version = decoded['schemaVersion'];
    schemaVersion = version is int ? version : 1;
  } else {
    throw const HymnalFormatException(
      'This file is not a hymnal. Expected a list of hymns, or an object '
      'with a "hymns" list.',
    );
  }
  if (rawHymns.length > _maxHymns) {
    throw const HymnalFormatException('The file has too many hymns.');
  }

  final hymns = <Hymn>[];
  final seen = <int>{};
  for (final raw in rawHymns) {
    if (raw is! Map) continue;
    final hymn = _parseHymn(Map<String, dynamic>.from(raw));
    if (hymn == null || !seen.add(hymn.number)) continue;
    hymns.add(hymn);
  }
  if (hymns.isEmpty) {
    throw const HymnalFormatException('No hymns were found in this file.');
  }
  hymns.sort((a, b) => a.number.compareTo(b.number));

  final parsedInfo = HymnalInfo.fromJson(book);
  final info = HymnalInfo.fromJson({
    ...parsedInfo.toJson(),
    'id': parsedInfo.id.isNotEmpty ? parsedInfo.id : request.fallbackId,
    'title': parsedInfo.title.isNotEmpty
        ? parsedInfo.title
        : request.fallbackTitle,
    'sourceKind': request.sourceKind.name,
    'hymnCount': hymns.length,
    'schemaVersion': schemaVersion,
  });

  return Hymnal(info: info, hymns: hymns, index: HymnSearchIndex(hymns));
}

Hymn? _parseHymn(Map<String, dynamic> raw) {
  final id = raw['id'] ?? raw['number'];
  final number = id is int ? id : int.tryParse('${id ?? ''}'.trim());
  if (number == null) return null;

  final verses = [
    for (final verse in raw['verses'] as List? ?? const [])
      if (_lines(verse) case final lines when lines.isNotEmpty) lines,
  ];
  final chorus = _lines(raw['chorus']);
  final alternateChoruses = [
    ..._parts(raw['alternateChoruses']),
    if (_lines(raw['addedChorus']) case final added when added.isNotEmpty)
      HymnPart(lines: added),
  ];
  final optionalVerses = _parts(raw['optionalVerses']);
  if (verses.isEmpty && chorus.isEmpty && optionalVerses.isEmpty) return null;

  var title = _str(raw['title']);
  if (title.isEmpty || title == '(c)') {
    title = verses.isNotEmpty
        ? verses.first.first
        : (chorus.isNotEmpty ? chorus.first : 'Hymn $number');
  }
  return Hymn(
    number: number,
    title: title,
    author: _str(raw['author']),
    meter: _str(raw['meter']),
    tuneName: _str(raw['tuneName'] ?? raw['tune']),
    verses: verses,
    chorus: chorus,
    optionalVerses: optionalVerses,
    alternateChoruses: alternateChoruses,
    notes: _lines(raw['notes']),
    copyright: _str(raw['copyright']).isEmpty ? null : _str(raw['copyright']),
    rightsStatus: _str(raw['rightsStatus']).isEmpty
        ? null
        : _str(raw['rightsStatus']),
  );
}

String _str(Object? value) => value == null ? '' : '$value'.trim();

/// Accepts a list of lines or a single string with embedded newlines.
List<String> _lines(Object? value) {
  final Iterable<Object?> raw = switch (value) {
    List() => value,
    String() => value.split('\n'),
    _ => const [],
  };
  return [
    for (final line in raw)
      if (line != null && '$line'.trim().isNotEmpty) '$line'.trimRight(),
  ];
}

List<HymnPart> _parts(Object? value) {
  if (value is! List) return const [];
  return [
    for (final part in value)
      if (part is Map && _lines(part['lines']).isNotEmpty)
        HymnPart(
          label: _str(part['label']).isEmpty ? null : _str(part['label']),
          lines: _lines(part['lines']),
        ),
  ];
}
