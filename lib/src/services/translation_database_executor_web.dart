import 'package:drift/drift.dart';
// ignore: deprecated_member_use_from_same_package
import 'package:drift/web.dart';

QueryExecutor openTranslationDatabaseExecutor(String storageKey) {
  return WebDatabase.withStorage(
    DriftWebStorage.indexedDb(_sanitizeStorageKey(storageKey)),
  );
}

String _sanitizeStorageKey(String input) {
  final sanitized = input.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
  return sanitized.isEmpty ? 'translation' : sanitized;
}
