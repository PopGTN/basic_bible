import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> biblesStoragePath() async {
  final appDir = await getApplicationSupportDirectory();
  final dir = Directory(p.join(appDir.path, 'bibles'));
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir.path;
}

Future<String> importedSourcesStoragePath() async {
  final appDir = await getApplicationSupportDirectory();
  final dir = Directory(p.join(appDir.path, 'imported_sources'));
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir.path;
}
