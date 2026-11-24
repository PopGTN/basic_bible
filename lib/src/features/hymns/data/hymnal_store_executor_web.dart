import 'package:drift/drift.dart';
// Same (deprecated) drift web backend as AppDatabase; see CONTEXT.md.
// ignore: deprecated_member_use
import 'package:drift/web.dart';

QueryExecutor openHymnalStoreExecutor() {
  return WebDatabase.withStorage(
    DriftWebStorage.indexedDb('basic_bible_hymnals'),
  );
}
