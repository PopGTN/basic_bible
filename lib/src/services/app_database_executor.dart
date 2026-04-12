import 'package:drift/drift.dart';

import 'app_database_executor_stub.dart'
    if (dart.library.io) 'app_database_executor_native.dart'
    if (dart.library.js_interop) 'app_database_executor_web.dart'
    as impl;

QueryExecutor openAppDatabaseExecutor() => impl.openAppDatabaseExecutor();
