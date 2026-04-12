Future<void> exportTranslationDatabase({
  required String dbPath,
  required String fileName,
  required String translationName,
}) async {
  throw UnsupportedError(
    'Exporting cached translation databases is not available in the browser.',
  );
}
