import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:basic_bible/src/features/library/data/bible_archive_support.dart';

class UsfmSourceFile {
  const UsfmSourceFile({required this.name, required this.content});

  final String name;
  final String content;

  Map<String, dynamic> toJson() => {'name': name, 'content': content};
}

class UsfmSourceBundle {
  const UsfmSourceBundle({required this.sourceName, required this.files});

  final String sourceName;
  final List<UsfmSourceFile> files;

  Map<String, dynamic> toJson() => {
    'sourceName': sourceName,
    'files': files.map((file) => file.toJson()).toList(growable: false),
  };
}

UsfmSourceBundle? tryExtractUsfmBundle(
  List<int> bytes, {
  required String sourceName,
}) {
  if (looksLikeZipBytes(bytes)) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final files = <UsfmSourceFile>[];
    var totalDecodedBytes = 0;
    for (final file in archive.files) {
      if (!file.isFile) continue;
      final lowerName = file.name.toLowerCase();
      if (!lowerName.endsWith('.usfm') && !lowerName.endsWith('.sfm')) {
        continue;
      }
      ensureArchiveEntryWithinLimits(
        declaredSize: file.size,
        totalSoFar: totalDecodedBytes,
      );
      final Object rawContent = file.content;
      if (rawContent is! List<int>) continue;
      totalDecodedBytes += rawContent.length;
      try {
        files.add(
          UsfmSourceFile(name: file.name, content: utf8.decode(rawContent)),
        );
      } on FormatException {
        continue;
      }
    }
    if (files.isEmpty) return null;
    return UsfmSourceBundle(sourceName: sourceName, files: files);
  }

  final lowerName = sourceName.toLowerCase();
  if (!lowerName.endsWith('.usfm') && !lowerName.endsWith('.sfm')) {
    return null;
  }

  return UsfmSourceBundle(
    sourceName: sourceName,
    files: [
      UsfmSourceFile(name: sourceName, content: utf8.decode(bytes)),
    ],
  );
}
