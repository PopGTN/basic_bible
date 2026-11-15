import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:path/path.dart' as p;

sealed class BibleArchiveException implements Exception {
  const BibleArchiveException(this.message);

  final String message;

  @override
  String toString() => message;
}

class InvalidBibleArchiveException extends BibleArchiveException {
  const InvalidBibleArchiveException(super.message);
}

class UnsupportedBibleArchiveException extends BibleArchiveException {
  const UnsupportedBibleArchiveException(super.message);
}

class BibleArchiveText {
  const BibleArchiveText({
    required this.content,
    required this.format,
    required this.sourceName,
    this.wasArchived = false,
  });

  final String content;
  final BibleFormat format;
  final String sourceName;
  final bool wasArchived;
}

/// Caps on uncompressed ZIP entry sizes, guarding against "zip bombs" —
/// tiny archives that declare gigabytes of expanded data and crash the app.
/// The largest legitimate Bible XML files are tens of megabytes.
const int kMaxArchiveEntryBytes = 100 * 1024 * 1024;
const int kMaxArchiveTotalBytes = 300 * 1024 * 1024;

/// Throws if [declaredSize] (or the running [totalSoFar]) exceeds the caps.
/// Call before touching an entry's `content`, which triggers decompression.
void ensureArchiveEntryWithinLimits({
  required int declaredSize,
  required int totalSoFar,
}) {
  if (declaredSize > kMaxArchiveEntryBytes ||
      totalSoFar + declaredSize > kMaxArchiveTotalBytes) {
    throw const InvalidBibleArchiveException(
      'This ZIP file declares more uncompressed data than the app allows and was rejected.',
    );
  }
}

BibleArchiveText decodeBibleArchiveText(
  List<int> bytes, {
  String? sourceName,
  BibleFormat? hintedFormat,
}) {
  if (_looksLikeZip(bytes)) {
    try {
      return _decodeBibleZip(
        bytes,
        sourceName: sourceName ?? 'archive.zip',
        hintedFormat: hintedFormat,
      );
    } on BibleArchiveException {
      rethrow;
    } catch (_) {
      throw const InvalidBibleArchiveException(
        'This ZIP file could not be opened. The archive appears to be invalid or corrupted.',
      );
    }
  }

  late final String content;
  try {
    content = utf8.decode(bytes);
  } on FormatException {
    throw const InvalidBibleArchiveException(
      'This file could not be decoded as Bible text.',
    );
  }
  return BibleArchiveText(
    content: content,
    format: _detectBibleFormatFromContent(content, hintedFormat: hintedFormat),
    sourceName: sourceName ?? 'document',
  );
}

BibleArchiveText decodeBibleArchiveTextFromText(
  String content, {
  String? sourceName,
  BibleFormat? hintedFormat,
}) {
  return BibleArchiveText(
    content: content,
    format: _detectBibleFormatFromContent(content, hintedFormat: hintedFormat),
    sourceName: sourceName ?? 'document',
  );
}

BibleArchiveText _decodeBibleZip(
  List<int> bytes, {
  required String sourceName,
  BibleFormat? hintedFormat,
}) {
  final archive = ZipDecoder().decodeBytes(Uint8List.fromList(bytes));
  if (archive.files.isEmpty) {
    throw const InvalidBibleArchiveException(
      'This ZIP file could not be opened. The archive appears to be invalid or corrupted.',
    );
  }
  final xmlCandidates = <BibleArchiveText>[];
  var sawUsfm = false;
  var totalDecodedBytes = 0;

  for (final file in archive.files) {
    if (!file.isFile) continue;
    final entryName = file.name.trim();
    if (entryName.isEmpty) continue;
    final extension = p.extension(entryName).toLowerCase();
    if (extension == '.usfm' || extension == '.sfm') {
      sawUsfm = true;
      continue;
    }

    if (extension != '.xml' && extension != '.usfx' && extension != '.osis') {
      continue;
    }

    ensureArchiveEntryWithinLimits(
      declaredSize: file.size,
      totalSoFar: totalDecodedBytes,
    );

    // archive 4.x: content is Uint8List? — skip entries that failed to decode.
    final Object rawEntryBytes = file.content;
    if (rawEntryBytes is! List<int>) continue;
    totalDecodedBytes += rawEntryBytes.length;

    try {
      final content = utf8.decode(rawEntryBytes);
      final format = _detectBibleFormatFromContent(
        content,
        hintedFormat: hintedFormat,
      );
      if (_isXmlBibleFormat(format)) {
        xmlCandidates.add(
          BibleArchiveText(
            content: content,
            format: format,
            sourceName: entryName,
            wasArchived: true,
          ),
        );
      }
    } on FormatException {
      continue;
    }
  }

  if (xmlCandidates.isNotEmpty) {
    xmlCandidates.sort((a, b) {
      final formatRank = _formatPreferenceRank(a.format).compareTo(
        _formatPreferenceRank(b.format),
      );
      if (formatRank != 0) return formatRank;
      return a.sourceName.length.compareTo(b.sourceName.length);
    });
    return xmlCandidates.first;
  }

  if (sawUsfm) {
    throw const UnsupportedBibleArchiveException(
      'This ZIP contains USFM files, but USFM import is not connected yet. Please use a USFX ZIP or XML translation instead.',
    );
  }

  throw const UnsupportedBibleArchiveException(
    'This ZIP file did not contain a supported Bible XML file.',
  );
}

BibleFormat detectBibleFormatFromSourceName(String sourceName) {
  final extension = p.extension(sourceName).toLowerCase();
  return switch (extension) {
    '.sqlite' || '.sqlite3' || '.db' => BibleFormat.sqlite,
    '.zip' => BibleFormat.zip,
    '.usfm' || '.sfm' => BibleFormat.usfm,
    '.usfx' => BibleFormat.usfx,
    '.osis' => BibleFormat.osis,
    '.xml' => BibleFormat.auto,
    _ => BibleFormat.auto,
  };
}

BibleFormat _detectBibleFormatFromContent(
  String content, {
  BibleFormat? hintedFormat,
}) {
  // Format markers always appear near the top of the document — no need to
  // scan (and allocate a lowercase copy of) the entire multi-megabyte string.
  const sampleLength = 2048;
  final sample = content.length > sampleLength
      ? content.substring(0, sampleLength).toLowerCase()
      : content.toLowerCase();
  if (sample.contains('<usfx')) return BibleFormat.usfx;
  if (sample.contains('<osis') || sample.contains('<osistext')) {
    return BibleFormat.osis;
  }
  if (sample.contains('<xmlbible')) return BibleFormat.zefania;
  if (hintedFormat != null && hintedFormat != BibleFormat.auto) {
    return hintedFormat;
  }
  return BibleFormat.auto;
}

bool _isXmlBibleFormat(BibleFormat format) {
  return format == BibleFormat.usfx ||
      format == BibleFormat.osis ||
      format == BibleFormat.zefania;
}

int _formatPreferenceRank(BibleFormat format) {
  return switch (format) {
    BibleFormat.usfx => 0,
    BibleFormat.osis => 1,
    BibleFormat.zefania => 2,
    _ => 99,
  };
}

bool _looksLikeZip(List<int> bytes) {
  if (bytes.length < 4) return false;
  return bytes[0] == 0x50 &&
      bytes[1] == 0x4B &&
      (bytes[2] == 0x03 || bytes[2] == 0x05 || bytes[2] == 0x07) &&
      (bytes[3] == 0x04 || bytes[3] == 0x06 || bytes[3] == 0x08);
}

bool looksLikeZipBytes(List<int> bytes) => _looksLikeZip(bytes);

BibleFormat normalizeBibleFormat({
  required BibleFormat declaredFormat,
  required String fileName,
  required List<int> bytes,
}) {
  if (_looksLikeZip(bytes)) return BibleFormat.zip;
  final inferredContainer = detectBibleFormatFromSourceName(fileName);
  if (declaredFormat == BibleFormat.auto || declaredFormat == BibleFormat.zip) {
    if (inferredContainer != BibleFormat.auto) return inferredContainer;
  }
  return declaredFormat;
}
