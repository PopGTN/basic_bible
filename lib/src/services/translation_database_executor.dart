import 'package:drift/drift.dart';

import 'translation_database_executor_stub.dart'
    if (dart.library.io) 'translation_database_executor_native.dart'
    if (dart.library.js_interop) 'translation_database_executor_web.dart'
    as impl;

QueryExecutor openTranslationDatabaseExecutor(String storageKey) =>
    impl.openTranslationDatabaseExecutor(storageKey);
