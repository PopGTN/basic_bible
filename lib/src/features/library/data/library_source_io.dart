import 'library_source_io_stub.dart'
    if (dart.library.io) 'library_source_io_native.dart'
    if (dart.library.js_interop) 'library_source_io_web.dart'
    as impl;

bool get usesFileBackedStorage => impl.usesFileBackedStorage;
bool get supportsDirectFileImport => impl.supportsDirectFileImport;

Future<bool> pathExists(String path) => impl.pathExists(path);

Future<void> deleteFileIfExists(String path) => impl.deleteFileIfExists(path);

/// Deletes a SQLite database and its `-wal`, `-shm` and `-journal` sidecars.
///
/// Deleting only the main file leaves a stale WAL behind, which SQLite would
/// try to pair with whatever database is written to the same path next.
Future<void> deleteSqliteDatabaseFiles(String path) async {
  for (final suffix in const ['', '-wal', '-shm', '-journal']) {
    await impl.deleteFileIfExists('$path$suffix');
  }
}

Future<String> readTextFile(String path) => impl.readTextFile(path);

Future<List<int>> readBinaryFile(String path) => impl.readBinaryFile(path);

Future<void> copyFile(String sourcePath, String destinationPath) =>
    impl.copyFile(sourcePath, destinationPath);

Future<void> writeBinaryFile(String destinationPath, List<int> bytes) =>
    impl.writeBinaryFile(destinationPath, bytes);

Future<void> clearDirectoryFiles(String directoryPath, {String? extension}) =>
    impl.clearDirectoryFiles(directoryPath, extension: extension);
