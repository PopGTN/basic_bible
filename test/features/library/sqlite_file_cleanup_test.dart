import 'dart:io';

import 'package:basic_bible/src/features/library/data/library_source_io.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'deleteSqliteDatabaseFiles removes the database and its sidecars',
    () async {
      final dir = await Directory.systemTemp.createTemp('sqlite_cleanup');
      addTearDown(() => dir.delete(recursive: true));
      final path = '${dir.path}/kjv.sqlite';
      for (final suffix in ['', '-wal', '-shm', '-journal']) {
        await File('$path$suffix').writeAsString('x');
      }
      final unrelated = File('${dir.path}/web.sqlite-wal')
        ..writeAsStringSync('x');

      await deleteSqliteDatabaseFiles(path);

      for (final suffix in ['', '-wal', '-shm', '-journal']) {
        expect(File('$path$suffix').existsSync(), isFalse, reason: suffix);
      }
      expect(unrelated.existsSync(), isTrue);
    },
  );

  test('deleteSqliteDatabaseFiles tolerates missing files', () async {
    final dir = await Directory.systemTemp.createTemp('sqlite_cleanup');
    addTearDown(() => dir.delete(recursive: true));
    await deleteSqliteDatabaseFiles('${dir.path}/missing.sqlite');
  });
}
