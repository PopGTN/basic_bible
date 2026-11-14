const bool usesFileBackedStorage = false;
const bool supportsDirectFileImport = false;

Future<bool> pathExists(String path) async => false;

Future<void> deleteFileIfExists(String path) async {}

Future<String> readTextFile(String path) async {
  throw UnsupportedError('Direct file access is unavailable on this platform.');
}

Future<List<int>> readBinaryFile(String path) async {
  throw UnsupportedError('Direct file access is unavailable on this platform.');
}

Future<void> copyFile(String sourcePath, String destinationPath) async {
  throw UnsupportedError('File copy is unavailable on this platform.');
}

Future<void> writeBinaryFile(String destinationPath, List<int> bytes) async {
  throw UnsupportedError(
    'Writing raw Bible files is unavailable on this platform.',
  );
}

Future<void> clearDirectoryFiles(
  String directoryPath, {
  String? extension,
}) async {}
