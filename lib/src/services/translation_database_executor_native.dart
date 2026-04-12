import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

QueryExecutor openTranslationDatabaseExecutor(String filePath) {
  return LazyDatabase(() async {
    return NativeDatabase.createInBackground(
      File(filePath),
      setup: (db) {
        db.execute('PRAGMA journal_mode=WAL;');
        db.execute('PRAGMA synchronous=NORMAL;');
        db.execute('PRAGMA cache_size=-8000;');
        db.execute('PRAGMA temp_store=MEMORY;');
      },
    );
  });
}
