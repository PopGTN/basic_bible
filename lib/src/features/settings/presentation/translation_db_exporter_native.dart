import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:share_plus/share_plus.dart';

import '../../../platform/runtime_support.dart';

Future<void> exportTranslationDatabase({
  required String dbPath,
  required String fileName,
  required String translationName,
}) async {
  final file = File(dbPath);
  if (!await file.exists()) {
    throw Exception(
      '"$translationName" has not been loaded yet. Open it in the reader first to generate the cache file.',
    );
  }

  if (isMobileRuntime) {
    await Share.shareXFiles(
      [XFile(dbPath)],
      subject: '$translationName Bible Database',
      text: fileName,
    );
    return;
  }

  final location = await getSaveLocation(
    suggestedName: fileName,
    acceptedTypeGroups: [
      const XTypeGroup(label: 'SQLite database', extensions: ['sqlite', 'db']),
    ],
  );
  if (location == null) return;

  await file.copy(location.path);
}
