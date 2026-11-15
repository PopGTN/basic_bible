import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:path/path.dart' as p;

import 'usfm_bundle_support.dart';

typedef _ParseUsfmBundleNative = ffi.Pointer<Utf8> Function(
  ffi.Pointer<Utf8>,
);
typedef _ParseUsfmBundleDart = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>);

typedef _FreeStringNative = ffi.Void Function(ffi.Pointer<Utf8>);
typedef _FreeStringDart = void Function(ffi.Pointer<Utf8>);

final _nativeLibrary = _tryOpenUsfmLibrary();
final _parseUsfmBundle = _nativeLibrary?.lookupFunction<
  _ParseUsfmBundleNative,
  _ParseUsfmBundleDart
>('basic_bible_parse_usfm_bundle');
final _freeString = _nativeLibrary?.lookupFunction<
  _FreeStringNative,
  _FreeStringDart
>('basic_bible_free_string');

bool get supportsNativeUsfmParsing =>
    _nativeLibrary != null && _parseUsfmBundle != null && _freeString != null;
String get nativeUsfmParsingUnavailabilityReason {
  if (supportsNativeUsfmParsing) return '';
  final libraryFileName = _libraryFileNameForPlatform();
  final candidates = _libraryCandidates().toList(growable: false);
  final lines = <String>[
    'USFM import uses a native Rust parser on desktop, but the $libraryFileName library was not found.',
    'Platform: ${Platform.operatingSystem}.',
    'Searched these locations:',
    for (final candidate in candidates) ' - $candidate',
    'Make sure Rust/Cargo is installed and that this desktop build bundles the native parser library.',
  ];
  return lines.join('\n');
}

Future<List<Map<String, dynamic>>> parseUsfmBundleToSerializable(
  UsfmSourceBundle bundle,
) async {
  if (!supportsNativeUsfmParsing) {
    throw UnsupportedError(nativeUsfmParsingUnavailabilityReason);
  }

  final requestJson = jsonEncode({
    'files': bundle.files.map((file) => file.toJson()).toList(growable: false),
  });
  final requestPtr = requestJson.toNativeUtf8();

  ffi.Pointer<Utf8> responsePtr = ffi.nullptr;
  try {
    responsePtr = _parseUsfmBundle!(requestPtr);
    if (responsePtr == ffi.nullptr) {
      throw Exception('The native USFM parser returned no response.');
    }
    final responseJson = responsePtr.toDartString();
    final decoded = jsonDecode(responseJson) as Map<String, dynamic>;
    if (decoded['ok'] != true) {
      throw Exception(
        (decoded['error'] as String?) ??
            'The native USFM parser returned an unknown error.',
      );
    }
    return (decoded['books'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  } finally {
    malloc.free(requestPtr);
    if (responsePtr != ffi.nullptr) {
      _freeString!(responsePtr);
    }
  }
}

ffi.DynamicLibrary? _tryOpenUsfmLibrary() {
  for (final candidate in _libraryCandidates()) {
    final file = File(candidate);
    if (!file.existsSync()) continue;
    try {
      return ffi.DynamicLibrary.open(candidate);
    } catch (_) {}
  }
  return null;
}

Iterable<String> _libraryCandidates() sync* {
  final executableDir = File(Platform.resolvedExecutable).parent.path;
  final executableParentDir = Directory(executableDir).parent.path;

  if (Platform.isLinux) {
    yield p.join(executableDir, 'libbasic_bible_usfm_parser.so');
    yield p.join(executableDir, 'lib', 'libbasic_bible_usfm_parser.so');
    yield p.join(executableParentDir, 'lib', 'libbasic_bible_usfm_parser.so');
  } else if (Platform.isMacOS) {
    yield p.join(executableDir, 'libbasic_bible_usfm_parser.dylib');
    yield p.join(executableDir, 'lib', 'libbasic_bible_usfm_parser.dylib');
    yield p.join(executableParentDir, 'Frameworks', 'libbasic_bible_usfm_parser.dylib');
  } else if (Platform.isWindows) {
    yield p.join(executableDir, 'basic_bible_usfm_parser.dll');
    yield p.join(executableDir, 'data', 'basic_bible_usfm_parser.dll');
  }

  // Cargo build output relative to the *current working directory* is only a
  // dev convenience (flutter run from the project root). Loading libraries
  // from the CWD in release builds would let a writable launch directory
  // plant a substitute library, so these paths are debug-only.
  if (kDebugMode) {
    final cwd = Directory.current.path;
    final releaseDir =
        p.join(cwd, 'native', 'usfm_parser', 'target', 'release');
    final debugDir = p.join(cwd, 'native', 'usfm_parser', 'target', 'debug');
    final fileName = _libraryFileNameForPlatform();
    yield p.join(releaseDir, fileName);
    yield p.join(debugDir, fileName);
  }
}

String _libraryFileNameForPlatform() {
  if (Platform.isLinux) return 'libbasic_bible_usfm_parser.so';
  if (Platform.isMacOS) return 'libbasic_bible_usfm_parser.dylib';
  if (Platform.isWindows) return 'basic_bible_usfm_parser.dll';
  return 'basic_bible_usfm_parser';
}
