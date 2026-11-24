import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/hymnal.dart';
import 'hymnal_store_executor.dart';

/// One installed (imported or downloaded) hymnal: its metadata plus the
/// original file bytes, which are re-parsed on demand.
class StoredHymnal {
  const StoredHymnal({required this.info, required this.content, this.sha256});

  final HymnalInfo info;
  final Uint8List content;
  final String? sha256;
}

/// Persistence for user-installed hymnals. Bundled books never go here —
/// they load straight from assets.
abstract class HymnalStore {
  Future<List<HymnalInfo>> listInfos();
  Future<StoredHymnal?> read(String id);
  Future<void> save(StoredHymnal hymnal);
  Future<void> delete(String id);
}

/// Drift-backed store. Uses plain SQL on a `GeneratedDatabase` with no
/// generated tables, so it needs no build_runner step.
class DriftHymnalStore implements HymnalStore {
  DriftHymnalStore([QueryExecutor? executor])
    : _db = _HymnalDatabase(executor ?? openHymnalStoreExecutor());

  final _HymnalDatabase _db;

  @override
  Future<List<HymnalInfo>> listInfos() async {
    final rows = await _db
        .customSelect(
          'SELECT info_json FROM installed_hymnals ORDER BY installed_at',
        )
        .get();
    return [
      for (final row in rows)
        HymnalInfo.fromJson(
          jsonDecode(row.read<String>('info_json')) as Map<String, dynamic>,
        ),
    ];
  }

  @override
  Future<StoredHymnal?> read(String id) async {
    final row = await _db
        .customSelect(
          'SELECT info_json, content, sha256 FROM installed_hymnals WHERE id = ?',
          variables: [Variable.withString(id)],
        )
        .getSingleOrNull();
    if (row == null) return null;
    return StoredHymnal(
      info: HymnalInfo.fromJson(
        jsonDecode(row.read<String>('info_json')) as Map<String, dynamic>,
      ),
      content: row.read<Uint8List>('content'),
      sha256: row.readNullable<String>('sha256'),
    );
  }

  @override
  Future<void> save(StoredHymnal hymnal) {
    return _db.customStatement(
      'INSERT OR REPLACE INTO installed_hymnals '
      '(id, info_json, content, sha256, installed_at) VALUES (?, ?, ?, ?, ?)',
      [
        hymnal.info.id,
        jsonEncode(hymnal.info.toJson()),
        hymnal.content,
        hymnal.sha256,
        DateTime.now().millisecondsSinceEpoch,
      ],
    );
  }

  @override
  Future<void> delete(String id) =>
      _db.customStatement('DELETE FROM installed_hymnals WHERE id = ?', [id]);

  Future<void> close() => _db.close();
}

class _HymnalDatabase extends GeneratedDatabase {
  _HymnalDatabase(super.executor);

  @override
  Iterable<TableInfo> get allTables => const [];

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => customStatement(
      'CREATE TABLE IF NOT EXISTS installed_hymnals ('
      'id TEXT NOT NULL PRIMARY KEY, '
      'info_json TEXT NOT NULL, '
      'content BLOB NOT NULL, '
      'sha256 TEXT, '
      'installed_at INTEGER NOT NULL)',
    ),
  );
}

/// For tests and as a fallback where no database is available.
class InMemoryHymnalStore implements HymnalStore {
  final Map<String, StoredHymnal> _items = {};

  @override
  Future<List<HymnalInfo>> listInfos() async => [
    for (final item in _items.values) item.info,
  ];

  @override
  Future<StoredHymnal?> read(String id) async => _items[id];

  @override
  Future<void> save(StoredHymnal hymnal) async =>
      _items[hymnal.info.id] = hymnal;

  @override
  Future<void> delete(String id) async => _items.remove(id);
}
