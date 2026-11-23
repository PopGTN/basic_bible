import 'package:drift/drift.dart';
// ignore: deprecated_member_use_from_same_package
import 'package:drift/web.dart';

QueryExecutor openTranslationDatabaseExecutor(String storageKey) {
  return WebDatabase.withStorage(
    DriftWebStorage.indexedDb(_sanitizeStorageKey(storageKey)),
  );
}

Future<void> seedTranslationDatabase(String storageKey, Uint8List bytes) async {
  // Same storage key the executor above reads, so the next open finds it.
  final storage = DriftWebStorage.indexedDb(_sanitizeStorageKey(storageKey));
  await storage.open();
  try {
    await storage.store(bytes);
  } finally {
    await storage.close();
  }
}

String _sanitizeStorageKey(String input) {
  final sanitized = input.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
  return sanitized.isEmpty ? 'translation' : sanitized;
}
