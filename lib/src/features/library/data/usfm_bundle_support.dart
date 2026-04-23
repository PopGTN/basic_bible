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
    final files = archive.files
        .where((file) => file.isFile)
        .where(
          (file) =>
              file.name.toLowerCase().endsWith('.usfm') ||
              file.name.toLowerCase().endsWith('.sfm'),
        )
        .map((file) {
          final Object rawContent = file.content;
          if (rawContent is! List<int>) return null;
          try {
            return UsfmSourceFile(
              name: file.name,
              content: utf8.decode(rawContent),
            );
          } on FormatException {
            return null;
          }
        })
        .whereType<UsfmSourceFile>()
        .toList(growable: false);
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
