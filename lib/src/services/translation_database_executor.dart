import 'package:drift/drift.dart';

import 'translation_database_executor_stub.dart'
    if (dart.library.io) 'translation_database_executor_native.dart'
    if (dart.library.js_interop) 'translation_database_executor_web.dart'
    as impl;

QueryExecutor openTranslationDatabaseExecutor(String storageKey) =>
    impl.openTranslationDatabaseExecutor(storageKey);

/// Replaces the stored database for [storageKey] with a complete, prebuilt
/// SQLite file ([bytes]), so it opens ready to read without parsing or
/// inserting anything. Native writes the file; web writes the IndexedDB blob
/// drift's WebDatabase reads. Any open connection for [storageKey] must be
/// closed (and awaited) first, or it can overwrite the seed when it closes.
Future<void> seedTranslationDatabase(String storageKey, Uint8List bytes) =>
    impl.seedTranslationDatabase(storageKey, bytes);
