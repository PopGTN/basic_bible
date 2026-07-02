import 'package:basic_bible/src/features/library/data/bible_archive_support.dart';
import 'package:basic_bible/src/features/library/data/bible_parser_worker.dart';
import 'package:basic_bible/src/features/library/data/usfm_bundle_support.dart';
import 'package:basic_bible/src/features/library/data/usfm_parser_bridge.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter/foundation.dart';

class ParsedBibleSource {
  const ParsedBibleSource({required this.format, required this.books});

  final BibleFormat format;
  final List<BibleBook> books;
}

/// Message for the worker isolate. Must hold only sendable values.
class _ParseSourceRequest {
  const _ParseSourceRequest({
    required this.bytes,
    required this.sourceName,
    required this.hintedFormat,
  });

  final Uint8List bytes;
  final String sourceName;
  final BibleFormat? hintedFormat;
}

/// Parses raw Bible source bytes (XML, ZIP, or USFM) into app models.
///
/// The entire pipeline — ZIP inflation, UTF-8 decode, parsing (including the
/// native USFM parser), and mapping to model objects — runs inside a single
/// `compute()` worker isolate so multi-megabyte files never freeze the UI.
Future<ParsedBibleSource> parseBibleSourceBytes(
  List<int> bytes, {
  required String sourceName,
  BibleFormat? hintedFormat,
}) {
  return compute(
    _parseBibleSourceWorker,
    _ParseSourceRequest(
      bytes: bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
      sourceName: sourceName,
      hintedFormat: hintedFormat,
    ),
  );
}

Future<ParsedBibleSource> _parseBibleSourceWorker(
  _ParseSourceRequest request,
) async {
  final usfmBundle = tryExtractUsfmBundle(
    request.bytes,
    sourceName: request.sourceName,
  );
  if (usfmBundle != null) {
    if (!supportsNativeUsfmParsing) {
      throw UnsupportedError(nativeUsfmParsingUnavailabilityReason);
    }
    final parsed = await parseUsfmBundleToSerializable(usfmBundle);
    return ParsedBibleSource(
      format: usfmBundle.files.length > 1 ? BibleFormat.zip : BibleFormat.usfm,
      books: parsed.map(mapSerializableBook).toList(growable: false),
    );
  }

  final document = decodeBibleArchiveText(
    request.bytes,
    sourceName: request.sourceName,
    hintedFormat: request.hintedFormat,
  );
  final books = await parseBibleContentToBooks(document.content);
  return ParsedBibleSource(format: document.format, books: books);
}
