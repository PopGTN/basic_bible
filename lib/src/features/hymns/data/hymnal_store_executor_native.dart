import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

QueryExecutor openHymnalStoreExecutor() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final dbDir = Directory(p.join(dir.path, 'database'));
    if (!await dbDir.exists()) await dbDir.create(recursive: true);
    return NativeDatabase.createInBackground(
      File(p.join(dbDir.path, 'hymnals.sqlite')),
      setup: (db) => db.execute('PRAGMA journal_mode=WAL;'),
    );
  });
}
