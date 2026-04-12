const bool usesFileBackedStorage = false;
const bool supportsDirectFileImport = false;

Future<bool> pathExists(String path) async => false;

Future<void> deleteFileIfExists(String path) async {}

Future<String> readTextFile(String path) async {
  throw UnsupportedError(
    'Importing local Bible files is not available in the browser yet.',
  );
}

Future<void> copyFile(String sourcePath, String destinationPath) async {
  throw UnsupportedError(
    'Copying local Bible files is not available in the browser.',
  );
}

Future<void> clearDirectoryFiles(
  String directoryPath, {
  String? extension,
}) async {}
