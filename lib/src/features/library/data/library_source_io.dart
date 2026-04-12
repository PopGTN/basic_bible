import 'library_source_io_stub.dart'
    if (dart.library.io) 'library_source_io_native.dart'
    if (dart.library.js_interop) 'library_source_io_web.dart'
    as impl;

bool get usesFileBackedStorage => impl.usesFileBackedStorage;
bool get supportsDirectFileImport => impl.supportsDirectFileImport;

Future<bool> pathExists(String path) => impl.pathExists(path);

Future<void> deleteFileIfExists(String path) => impl.deleteFileIfExists(path);

Future<String> readTextFile(String path) => impl.readTextFile(path);

Future<void> copyFile(String sourcePath, String destinationPath) =>
    impl.copyFile(sourcePath, destinationPath);

Future<void> clearDirectoryFiles(String directoryPath, {String? extension}) =>
    impl.clearDirectoryFiles(directoryPath, extension: extension);
