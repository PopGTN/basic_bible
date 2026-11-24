import 'package:drift/drift.dart';

import 'hymnal_store_executor_stub.dart'
    if (dart.library.io) 'hymnal_store_executor_native.dart'
    if (dart.library.js_interop) 'hymnal_store_executor_web.dart'
    as impl;

/// Opens the separate hymnal database (`hymnals.sqlite` natively, IndexedDB
/// `basic_bible_hymnals` on web). Kept apart from `AppDatabase` so hymn
/// storage can never disturb notes/highlights migrations.
QueryExecutor openHymnalStoreExecutor() => impl.openHymnalStoreExecutor();
