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

Future<ParsedBibleSource> parseBibleSourceBytes(
  List<int> bytes, {
  required String sourceName,
  BibleFormat? hintedFormat,
}) async {
  final usfmBundle = tryExtractUsfmBundle(bytes, sourceName: sourceName);
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
    bytes,
    sourceName: sourceName,
    hintedFormat: hintedFormat,
  );
  final parsed = await compute(parseBibleToSerializable, document.content);
  return ParsedBibleSource(
    format: document.format,
    books: parsed.map(mapSerializableBook).toList(growable: false),
  );
}
