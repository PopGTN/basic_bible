import 'package:drift/drift.dart';
// ignore: deprecated_member_use_from_same_package
import 'package:drift/web.dart';

QueryExecutor openAppDatabaseExecutor() {
  return WebDatabase.withStorage(DriftWebStorage.indexedDb('basic_bible_app'));
}
