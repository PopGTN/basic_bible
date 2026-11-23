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

Future<void> seedTranslationDatabase(String filePath, Uint8List bytes) async {
  final file = File(filePath);
  await file.parent.create(recursive: true);
  // A stale WAL/SHM pair from a previous database would be replayed onto the
  // new file and corrupt it.
  for (final suffix in const ['-wal', '-shm']) {
    final sidecar = File('$filePath$suffix');
    if (await sidecar.exists()) await sidecar.delete();
  }
  await file.writeAsBytes(bytes, flush: true);
}
