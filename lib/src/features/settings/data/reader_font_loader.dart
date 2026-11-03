import 'dart:io';

import 'package:basic_bible/src/features/settings/models/reader_font.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Registers font bytes under a family name with the engine. Injectable so
/// tests don't need real font data.
typedef FontRegistrar =
    Future<void> Function(String family, List<Uint8List> fontFiles);

Future<void> _registerWithEngine(
  String family,
  List<Uint8List> fontFiles,
) async {
  final loader = FontLoader(family);
  for (final bytes in fontFiles) {
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

/// Gets reader fonts into the engine so a [TextStyle] can use them.
///
/// - Each family is loaded at most once per session; concurrent requests for
///   the same family share one load.
/// - Picker previews go through [loadForPreview]: one at a time, skipped for
///   rows that scrolled away, and capped by a memory budget, because loaded
///   fonts stay in engine memory until the app exits.
class ReaderFontLoader {
  ReaderFontLoader({
    FontRegistrar? registrar,
    Future<Uint8List> Function(String path)? fileReader,
  }) : _register = registrar ?? _registerWithEngine,
       _readFile = fileReader ?? ((path) => File(path).readAsBytes());

  /// Fonts bigger than this aren't previewed in the picker list (selecting
  /// them still works; only the "name drawn in its own font" is skipped).
  static int get previewSizeLimitBytes =>
      _isMobile ? 768 * 1024 : 2 * 1024 * 1024;

  /// Total bytes of fonts loaded just for list previews. On phones this caps
  /// what scrolling through a few hundred system fonts can cost.
  static int get previewBudgetBytes =>
      _isMobile ? 12 * 1024 * 1024 : 48 * 1024 * 1024;

  static bool get _isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  final FontRegistrar _register;
  final Future<Uint8List> Function(String path) _readFile;

  final _loadedFamilies = <String>{};

  /// In-flight loads keyed by family, so the picker tiles, the preview card
  /// and `select` asking for the same font at once share one engine load.
  final _pendingLoads = <String, Future<bool>>{};

  /// Preview loads run one at a time so a fast fling can't queue hundreds of
  /// file reads + font parses on the UI thread at once.
  Future<void> _previewQueue = Future.value();
  int _previewBytes = 0;

  bool isLoaded(ReaderFont font) =>
      font.family == null || _loadedFamilies.contains(font.family);

  /// Makes [font] usable in a [TextStyle]. Returns false if its files are
  /// missing or unreadable.
  Future<bool> ensureLoaded(ReaderFont font) {
    final family = font.family;
    if (family == null || _loadedFamilies.contains(family)) {
      return SynchronousFuture(true);
    }
    if (font.paths.isEmpty) return SynchronousFuture(false);
    return _pendingLoads.putIfAbsent(
      family,
      // Block body on purpose: `remove` returns this same future, and
      // whenComplete would await it — a self-deadlock.
      () => _load(family, font).whenComplete(() {
        _pendingLoads.remove(family);
      }),
    );
  }

  /// Registers already-read bytes (an import) under [family]. Throws if the
  /// engine rejects them.
  Future<void> registerBytes(String family, Uint8List bytes) async {
    await _register(family, [bytes]);
    _loadedFamilies.add(family);
  }

  Future<bool> _load(String family, ReaderFont font) async {
    try {
      final files = <Uint8List>[];
      for (final path in font.paths) {
        if (font.source == ReaderFontSource.bundled) {
          final data = await rootBundle.load(path);
          files.add(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          );
        } else {
          files.add(await _readFile(path));
        }
      }
      await _register(family, files);
      _loadedFamilies.add(family);
      return true;
    } catch (e) {
      debugPrint('ReaderFontLoader: failed to load ${font.id}: $e');
      return false;
    }
  }

  /// Whether the picker may draw [font]'s name in the font itself.
  bool canPreview(ReaderFont font) {
    if (font.family == null) return false;
    if (isLoaded(font)) return true;
    return font.sizeBytes <= previewSizeLimitBytes &&
        _previewBytes + font.sizeBytes <= previewBudgetBytes;
  }

  /// Loads [font] for a list preview: queued behind other previews, and
  /// skipped (returns false) if [stillWanted] says the row has scrolled away
  /// by the time its turn comes, or the preview budget is used up.
  Future<bool> loadForPreview(
    ReaderFont font, {
    required bool Function() stillWanted,
  }) {
    if (isLoaded(font)) return SynchronousFuture(true);
    if (!canPreview(font)) return SynchronousFuture(false);
    final result = _previewQueue.then((_) async {
      if (isLoaded(font)) return true;
      if (!stillWanted() || !canPreview(font)) return false;
      final ok = await ensureLoaded(font);
      if (ok) _previewBytes += font.sizeBytes;
      return ok;
    });
    _previewQueue = result.then((_) {}, onError: (_) {});
    return result;
  }
}
