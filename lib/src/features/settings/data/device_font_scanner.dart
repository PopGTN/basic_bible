import 'dart:io';

import 'package:basic_bible/src/features/settings/models/reader_font.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Finds the fonts installed in the operating system's font folders and
/// groups their files into families.
///
/// The scan runs on a background isolate (`compute`) — Linux and Android can
/// have thousands of font files — once per app session, and only when the
/// picker asks for it.
class DeviceFontScanner {
  /// [directories] overrides the platform's font folders (for tests).
  DeviceFontScanner({List<String>? directories}) : _directories = directories;

  final List<String>? _directories;
  List<ReaderFont>? _fonts;
  Future<List<ReaderFont>>? _scan;

  /// Whether the OS font folders can be listed. iOS apps are sandboxed from
  /// them, and the web has no file system.
  static bool get isSupported =>
      !kIsWeb &&
      (Platform.isAndroid ||
          Platform.isLinux ||
          Platform.isWindows ||
          Platform.isMacOS);

  /// The installed font families, sorted by name.
  Future<List<ReaderFont>> fonts() {
    // Hand back a fresh future once resolved, rather than the original one,
    // so listeners run in the caller's zone (matters for widget tests).
    final cached = _fonts;
    if (cached != null) return Future.value(cached);
    return _scan ??= _scanFonts()
        .then((fonts) => _fonts = fonts)
        .catchError((Object e) {
          debugPrint('DeviceFontScanner: scan failed: $e');
          return const <ReaderFont>[]; // not cached: retry on next open
        })
        .whenComplete(() {
          _scan = null;
        });
  }

  Future<List<ReaderFont>> _scanFonts() async {
    if (_directories == null && !isSupported) return const [];
    final directories = _directories ?? _platformDirectories();
    final files = await compute(_listFontFiles, directories);
    return groupFiles(files);
  }

  static List<String> _platformDirectories() {
    if (Platform.isAndroid) {
      return const ['/system/fonts', '/system_ext/fonts', '/product/fonts'];
    }
    final home = Platform.environment['HOME'];
    final hasHome = home != null && home.isNotEmpty;
    if (Platform.isLinux) {
      return [
        '/usr/share/fonts',
        '/usr/local/share/fonts',
        if (hasHome) ...['$home/.local/share/fonts', '$home/.fonts'],
      ];
    }
    if (Platform.isMacOS) {
      return [
        '/Library/Fonts',
        '/System/Library/Fonts',
        if (hasHome) '$home/Library/Fonts',
      ];
    }
    if (Platform.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      return [
        '${Platform.environment['windir'] ?? r'C:\Windows'}\\Fonts',
        if (localAppData != null && localAppData.isNotEmpty)
          '$localAppData\\Microsoft\\Windows\\Fonts',
      ];
    }
    return const [];
  }

  /// Runs on a background isolate: sync I/O is faster there and can't jank.
  static Map<String, int> _listFontFiles(List<String> directories) {
    final files = <String, int>{}; // path -> size
    for (final path in directories) {
      final dir = Directory(path);
      try {
        if (!dir.existsSync()) continue;
        for (final entity in dir.listSync(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is! File) continue;
          final ext = p.extension(entity.path).toLowerCase();
          if (ext != '.ttf' && ext != '.otf') continue;
          files[entity.path] = entity.statSync().size;
        }
      } on FileSystemException {
        // Unreadable folder (permissions) — skip it, keep what we have.
      }
    }
    return files;
  }

  /// Groups font files into families by file-name stem
  /// (`NotoSerif-BoldItalic.ttf` → `NotoSerif`). Pure and public for tests.
  @visibleForTesting
  static List<ReaderFont> groupFiles(Map<String, int> filesWithSizes) {
    final groups = <String, List<String>>{};
    final sizes = <String, int>{};
    for (final entry in filesWithSizes.entries) {
      final stem = familyStem(p.basenameWithoutExtension(entry.key));
      if (stem.isEmpty) continue;
      groups.putIfAbsent(stem, () => []).add(entry.key);
      sizes[stem] = (sizes[stem] ?? 0) + entry.value;
    }
    final fonts = [
      for (final entry in groups.entries)
        ReaderFont(
          id: 'device:${entry.key}',
          name: prettyFontName(entry.key),
          source: ReaderFontSource.device,
          family: 'device:${entry.key}',
          paths: (entry.value..sort()),
          sizeBytes: sizes[entry.key]!,
        ),
    ];
    fonts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return fonts;
  }

  @visibleForTesting
  static String familyStem(String fileBaseName) {
    // Variable fonts carry their axes in brackets (`NotoSerif[wght]`,
    // `NotoSerif-Italic[wght]`); drop them so they join the static family.
    final name = fileBaseName.replaceAll(RegExp(r'\[[^\]]*\]'), '');
    final dash = name.indexOf('-');
    return (dash > 0 ? name.substring(0, dash) : name).trim();
  }
}
