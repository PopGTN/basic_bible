import 'dart:async';
import 'dart:io';

import 'package:basic_bible/src/features/settings/models/reader_font.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

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
/// - Picker previews go through [loadForPreview]. Requests made together
///   are read in parallel and then registered together, back to back.
///   Every registration makes the engine drop its font-lookup cache, so the
///   next frame re-resolves the family of every piece of visible text —
///   on Linux through fontconfig, which is slow with thousands of installed
///   fonts. Registering a whole screen of previews at once pays that once;
///   spreading them over frames paid it every frame (measured ~5 fps).
///   A preview registers only the family's regular face, rows that scrolled
///   away are skipped, and a memory budget caps the total, because loaded
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

  /// Most previews registered at once: the visible rows plus the rows the
  /// picker builds ahead of the viewport.
  static const maxPreviewBatch = 64;

  /// Preview requests waiting for the next batch, keyed by family.
  final _pendingPreviews = <String, _PreviewRequest>{};
  Future<void>? _activeBatch;
  int _previewBytes = 0;

  /// Families whose preview face (only) is registered, mapped to that file's
  /// path so a later full load doesn't register it twice.
  final _previewPaths = <String, String>{};

  /// Whether [font] can be used in a [TextStyle] with all its faces.
  bool isLoaded(ReaderFont font) =>
      font.family == null || _loadedFamilies.contains(font.family);

  /// Whether at least [font]'s preview face is registered, i.e. its name can
  /// be drawn in the font.
  bool hasPreview(ReaderFont font) =>
      isLoaded(font) || _previewPaths.containsKey(font.family);

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
      // The preview face is already registered under this family; adding it
      // again would only duplicate it in engine memory.
      final previewPath = _previewPaths[family];
      final files = await Future.wait([
        for (final path in font.paths)
          if (path != previewPath) _readFontFile(font, path),
      ]);
      if (files.isNotEmpty) await _register(family, files);
      _loadedFamilies.add(family);
      return true;
    } catch (e) {
      debugPrint('ReaderFontLoader: failed to load ${font.id}: $e');
      return false;
    }
  }

  Future<Uint8List> _readFontFile(ReaderFont font, String path) async {
    if (font.source != ReaderFontSource.bundled) return _readFile(path);
    final data = await rootBundle.load(path);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  /// Whether the picker may draw [font]'s name in the font itself.
  bool canPreview(ReaderFont font) {
    if (font.family == null) return false;
    if (hasPreview(font)) return true;
    return font.sizeBytes <= previewSizeLimitBytes &&
        _previewBytes + font.sizeBytes <= previewBudgetBytes;
  }

  /// Loads [font]'s preview face for a list row, paced one per frame
  /// (see the class docs). Returns false if [stillWanted] says the row
  /// scrolled away before its turn, or the preview budget is used up.
  Future<bool> loadForPreview(
    ReaderFont font, {
    required bool Function() stillWanted,
  }) {
    if (hasPreview(font)) return SynchronousFuture(true);
    if (!canPreview(font)) return SynchronousFuture(false);
    final request = _pendingPreviews.putIfAbsent(
      font.family!,
      () => _PreviewRequest(font),
    )..stillWanted.add(stillWanted);
    _drainPreviews();
    return request.completer.future;
  }

  void _drainPreviews() {
    if (_activeBatch != null) return; // The running drain picks it up.
    // Start on the next event-loop turn so every row asking in the same
    // frame lands in the same read-ahead batch.
    _activeBatch =
        Future(() async {
          while (_pendingPreviews.isNotEmpty) {
            final batch = _pendingPreviews.values
                .take(maxPreviewBatch)
                .toList();
            for (final request in batch) {
              _pendingPreviews.remove(request.font.family);
            }
            await _loadPreviewBatch(batch);
          }
        }).whenComplete(() {
          _activeBatch = null;
        });
  }

  Future<void> _loadPreviewBatch(List<_PreviewRequest> batch) async {
    final accepted = <_PreviewRequest>[];
    for (final request in batch) {
      final font = request.font;
      if (hasPreview(font)) {
        request.completer.complete(true);
      } else if (!request.isWanted || !canPreview(font)) {
        request.completer.complete(false);
      } else {
        // Reserve now so a batch can't overshoot the budget.
        _previewBytes += font.sizeBytes;
        accepted.add(request);
      }
    }
    // Read every file first (async I/O, off the UI thread), so the
    // registrations below can all happen back to back.
    final reads = {
      for (final request in accepted)
        request: _readFontFile(request.font, previewPath(request.font.paths))
            .then<Uint8List?>(
              (bytes) => bytes,
              onError: (Object e) {
                debugPrint(
                  'ReaderFontLoader: reading ${request.font.id} failed: $e',
                );
                return null;
              },
            ),
    };
    final ready = <_PreviewRequest, Uint8List>{};
    for (final request in accepted) {
      final bytes = await reads[request];
      // Re-check: the row may have scrolled away while its file was read.
      if (bytes == null || !request.isWanted) {
        _previewBytes -= request.font.sizeBytes;
        request.completer.complete(false);
      } else {
        ready[request] = bytes;
      }
    }
    await Future.wait([
      for (final entry in ready.entries)
        _registerPreview(entry.key, entry.value),
    ]);
  }

  Future<void> _registerPreview(
    _PreviewRequest request,
    Uint8List bytes,
  ) async {
    final font = request.font;
    final family = font.family!;
    try {
      await _register(family, [bytes]);
      _previewPaths[family] = previewPath(font.paths);
      if (font.paths.length == 1) _loadedFamilies.add(family);
      request.completer.complete(true);
    } catch (e) {
      _previewBytes -= font.sizeBytes;
      debugPrint('ReaderFontLoader: preview of ${font.id} failed: $e');
      request.completer.complete(false);
    }
  }

  /// The file that best represents a family in a one-line preview: its
  /// regular face if there is one, otherwise the plainest-named file.
  @visibleForTesting
  static String previewPath(List<String> paths) {
    String base(String path) => p.basename(path).toLowerCase();
    for (final path in paths) {
      if (base(path).contains('regular')) return path;
    }
    return paths.reduce((a, b) => base(b).length < base(a).length ? b : a);
  }
}

class _PreviewRequest {
  _PreviewRequest(this.font);

  final ReaderFont font;
  final completer = Completer<bool>();

  /// One callback per row asking for this family; any still-visible row keeps
  /// the request alive.
  final stillWanted = <bool Function()>[];

  bool get isWanted => stillWanted.any((wanted) => wanted());
}
