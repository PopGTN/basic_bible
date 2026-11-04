import 'dart:convert';
import 'dart:io';

import 'package:basic_bible/src/features/settings/data/device_font_scanner.dart';
import 'package:basic_bible/src/features/settings/data/reader_font_loader.dart';
import 'package:basic_bible/src/features/settings/models/reader_font.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// A font family we ship in `assets/fonts/`. It only appears in the picker
/// when matching files are actually present, so adding the font files later is
/// all it takes to enable it (no code or pubspec change).
class BundledFontSpec {
  const BundledFontSpec({
    required this.id,
    required this.name,
    required this.filePrefix,
  });

  final String id;
  final String name;

  /// Lower-case file-name prefix under `assets/fonts/`, e.g. `gentiumplus`
  /// matches `GentiumPlus-Regular.ttf` and `GentiumPlus-Italic.ttf`.
  final String filePrefix;
}

const bundledFontSpecs = <BundledFontSpec>[
  BundledFontSpec(
    id: 'bundled:gentium-plus',
    name: 'Gentium Plus',
    filePrefix: 'gentiumplus',
  ),
  BundledFontSpec(
    id: 'bundled:opendyslexic',
    name: 'OpenDyslexic',
    filePrefix: 'opendyslexic',
  ),
];

/// The bundled font Bible text uses until the user chooses another.
const defaultBundledFontId = 'bundled:gentium-plus';

/// Adds the bundled fonts' SIL Open Font License texts to Flutter's license
/// registry (shown by `showLicensePage`). Read lazily, only when viewed.
void registerBundledFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (name, asset) in const [
      ('Gentium Plus', 'assets/fonts/GentiumPlus-OFL.txt'),
      ('OpenDyslexic', 'assets/fonts/OpenDyslexic-OFL.txt'),
    ]) {
      try {
        yield LicenseEntryWithLineBreaks([
          name,
        ], await rootBundle.loadString(asset));
      } catch (_) {
        // Font not shipped in this build.
      }
    }
  });
}

/// The reader-font feature's data entry point: remembers the user's choice,
/// lists bundled fonts, and manages imported font files.
///
/// Engine loading lives in [loader] and the OS font scan in [scanner]; both
/// are lazy, so only the selected font is read at startup and unused fonts
/// cost neither memory nor battery.
class ReaderFontRepository {
  ReaderFontRepository(
    this._prefs, {
    FontRegistrar? registrar,
    Future<Directory> Function()? fontsDirectory,
    Future<List<String>> Function()? assetKeys,
    Future<Uint8List> Function(String path)? fileReader,
    List<String>? deviceFontDirectories,
  }) : loader = ReaderFontLoader(registrar: registrar, fileReader: fileReader),
       scanner = DeviceFontScanner(directories: deviceFontDirectories),
       _fontsDirectory = fontsDirectory ?? _defaultFontsDirectory,
       _assetKeys = assetKeys ?? _defaultAssetKeys;

  static const _selectedKey = 'reader_font_selected';
  static const _importedKey = 'reader_font_imported';

  /// Whether this platform can import font files at all.
  static bool get supportsFontFiles => !kIsWeb;

  final ReaderFontLoader loader;
  final DeviceFontScanner scanner;

  final SharedPreferences _prefs;
  final Future<Directory> Function() _fontsDirectory;
  final Future<List<String>> Function() _assetKeys;
  Future<List<ReaderFont>>? _bundledFonts;

  static Future<Directory> _defaultFontsDirectory() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'reader_fonts'));
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  static Future<List<String>> _defaultAssetKeys() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return manifest.listAssets();
  }

  // ---------------------------------------------------------------------
  // Selection + startup
  // ---------------------------------------------------------------------

  /// The font Bible text uses until the user picks another one: the bundled
  /// font named by [defaultBundledFontId], once [restore] has found and
  /// loaded it; otherwise the theme font.
  ReaderFont get appDefault => _appDefault ?? ReaderFont.systemDefault;
  ReaderFont? _appDefault;

  /// The persisted choice (or [appDefault] if there is none), without
  /// loading anything.
  ReaderFont get selected => _savedSelection ?? appDefault;

  ReaderFont? get _savedSelection {
    final raw = _prefs.getString(_selectedKey);
    if (raw == null) return null;
    try {
      return ReaderFont.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  /// Loads the saved font (or [appDefault]) into the engine. Call before
  /// `runApp` so the first frame already uses it. Falls back to [appDefault],
  /// then the theme font, if a font's files are gone.
  Future<ReaderFont> restore() async {
    _appDefault = await _findAppDefault();
    final saved = _savedSelection;
    if (saved != null) {
      if (await loader.ensureLoaded(saved)) return saved;
      await _prefs.remove(_selectedKey);
    }
    if (await loader.ensureLoaded(appDefault)) return appDefault;
    _appDefault = null;
    return ReaderFont.systemDefault;
  }

  Future<ReaderFont?> _findAppDefault() async {
    try {
      for (final font in await bundledFonts()) {
        if (font.id == defaultBundledFontId) return font;
      }
    } catch (e) {
      debugPrint('ReaderFontRepository: bundled fonts unavailable: $e');
    }
    return null;
  }

  /// Saves the choice. "System Default" is stored explicitly so it isn't
  /// mistaken for "never chosen", which means [appDefault].
  ///
  /// Keyed on [defaultBundledFontId], not [appDefault]: before [restore] runs
  /// (or when the bundled font is missing) [appDefault] is the theme font,
  /// and comparing against it would silently forget an explicit
  /// "System Default" choice.
  Future<void> saveSelected(ReaderFont font) async {
    if (font.id == defaultBundledFontId) {
      await _prefs.remove(_selectedKey);
    } else {
      await _prefs.setString(_selectedKey, jsonEncode(font.toJson()));
    }
  }

  // ---------------------------------------------------------------------
  // Bundled
  // ---------------------------------------------------------------------

  /// Bundled fonts whose files are present in `assets/fonts/`. The asset
  /// manifest is read once per session.
  Future<List<ReaderFont>> bundledFonts() =>
      _bundledFonts ??= _findBundledFonts();

  Future<List<ReaderFont>> _findBundledFonts() async {
    final keys = await _assetKeys();
    final result = <ReaderFont>[];
    for (final spec in bundledFontSpecs) {
      final matches = keys.where((key) {
        final lower = key.toLowerCase();
        return lower.startsWith('assets/fonts/${spec.filePrefix}') &&
            (lower.endsWith('.ttf') || lower.endsWith('.otf'));
      }).toList()..sort();
      if (matches.isEmpty) continue;
      result.add(
        ReaderFont(
          id: spec.id,
          name: spec.name,
          source: ReaderFontSource.bundled,
          family: spec.id,
          paths: matches,
        ),
      );
    }
    return result;
  }

  // ---------------------------------------------------------------------
  // Imported
  // ---------------------------------------------------------------------

  List<ReaderFont> importedFonts() {
    final raw = _prefs.getString(_importedKey);
    if (raw == null) return const [];
    try {
      return [
        for (final item in jsonDecode(raw) as List)
          if (ReaderFont.fromJson(item) case final font?)
            if (font.paths.every((path) => File(path).existsSync())) font,
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveImported(List<ReaderFont> fonts) {
    return _prefs.setString(
      _importedKey,
      jsonEncode([for (final f in fonts) f.toJson()]),
    );
  }

  /// True when [bytes] start with a TrueType/OpenType signature.
  static bool looksLikeFont(Uint8List bytes) {
    if (bytes.length < 12) return false;
    final tag = String.fromCharCodes(bytes.sublist(0, 4));
    return tag == 'OTTO' ||
        tag == 'true' ||
        tag == 'ttcf' ||
        (bytes[0] == 0 && bytes[1] == 1 && bytes[2] == 0 && bytes[3] == 0);
  }

  /// Validates, stores and registers a user-supplied font. Throws
  /// [InvalidFontFileException] if the file isn't a usable font.
  Future<ReaderFont> importFont({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final ext = p.extension(fileName).toLowerCase();
    if (ext != '.ttf' && ext != '.otf') {
      throw const InvalidFontFileException(InvalidFontReason.unsupportedType);
    }
    if (!looksLikeFont(bytes)) {
      throw const InvalidFontFileException(InvalidFontReason.notAFont);
    }

    final uuid = const Uuid().v4();
    final id = 'imported:$uuid';
    try {
      await loader.registerBytes(id, bytes);
    } catch (_) {
      throw const InvalidFontFileException(InvalidFontReason.unloadable);
    }

    final dir = await _fontsDirectory();
    final stored = File(p.join(dir.path, '$uuid$ext'));
    await stored.writeAsBytes(bytes, flush: true);

    final font = ReaderFont(
      id: id,
      name: prettyFontName(p.basenameWithoutExtension(fileName)),
      source: ReaderFontSource.imported,
      family: id,
      paths: [stored.path],
      sizeBytes: bytes.length,
    );
    await _saveImported([...importedFonts(), font]);
    return font;
  }

  Future<void> deleteImported(ReaderFont font) async {
    for (final path in font.paths) {
      final file = File(path);
      if (file.existsSync()) await file.delete();
    }
    await _saveImported([
      for (final f in importedFonts())
        if (f.id != font.id) f,
    ]);
    // Back to the app default (Gentium Plus), not the theme font.
    if (selected.id == font.id) await _prefs.remove(_selectedKey);
  }
}
