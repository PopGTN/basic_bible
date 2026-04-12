import 'translation_db_exporter_stub.dart'
    if (dart.library.io) 'translation_db_exporter_native.dart'
    if (dart.library.js_interop) 'translation_db_exporter_web.dart'
    as impl;

Future<void> exportTranslationDatabase({
  required String dbPath,
  required String fileName,
  required String translationName,
}) {
  return impl.exportTranslationDatabase(
    dbPath: dbPath,
    fileName: fileName,
    translationName: translationName,
  );
}
