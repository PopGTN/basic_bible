import 'translation_storage_paths_stub.dart'
    if (dart.library.io) 'translation_storage_paths_native.dart'
    if (dart.library.js_interop) 'translation_storage_paths_web.dart'
    as impl;

Future<String> biblesStoragePath() => impl.biblesStoragePath();

Future<String> importedSourcesStoragePath() =>
    impl.importedSourcesStoragePath();
