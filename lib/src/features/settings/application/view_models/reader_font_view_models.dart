import 'package:basic_bible/src/features/settings/data/reader_font_loader.dart';
import 'package:basic_bible/src/features/settings/data/reader_font_repository.dart';
import 'package:basic_bible/src/features/settings/models/reader_font.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Overridden from `main()` with a repository whose saved font is already
/// loaded, so the first frame uses it. Falls back to a plain repository
/// (default font) anywhere it isn't overridden, e.g. in widget tests.
final readerFontRepositoryProvider = Provider<ReaderFontRepository>((ref) {
  return ReaderFontRepository(ref.watch(sharedPreferencesProvider));
});

/// Engine font loading, used by the picker rows for their previews.
final readerFontLoaderProvider = Provider<ReaderFontLoader>((ref) {
  return ref.watch(readerFontRepositoryProvider).loader;
});

/// Fonts shipped in `assets/fonts/` (only those whose files are present).
final bundledReaderFontsProvider = FutureProvider<List<ReaderFont>>((ref) {
  return ref.watch(readerFontRepositoryProvider).bundledFonts();
});

/// An installed font paired with its lower-cased name, so search doesn't
/// re-lowercase a few hundred names on every keystroke.
typedef SearchableFont = ({ReaderFont font, String searchKey});

/// Fonts installed on the device. The scan runs off the UI thread and is
/// cached by the repository for the session, so reopening the picker is free.
final deviceReaderFontsProvider = FutureProvider<List<SearchableFont>>((
  ref,
) async {
  final fonts = await ref.watch(readerFontRepositoryProvider).scanner.fonts();
  return [
    for (final font in fonts) (font: font, searchKey: font.name.toLowerCase()),
  ];
});

/// What went wrong, as data — the screen turns it into localized text.
enum ReaderFontErrorKind {
  /// The font's files are missing or unreadable.
  loadFailed,

  /// Import: not a `.ttf` / `.otf` file.
  unsupportedType,

  /// Import: the file isn't a font.
  notAFont,

  /// Import: the engine refused the font.
  unloadable,

  /// Import: an unexpected I/O failure.
  importFailed,

  /// Removing an imported font failed.
  deleteFailed,
}

class ReaderFontError {
  const ReaderFontError(this.kind, {this.fontName});

  final ReaderFontErrorKind kind;

  /// The font involved, for messages like "Lora could not be loaded".
  final String? fontName;
}

class ReaderFontState {
  const ReaderFontState({
    required this.selected,
    this.imported = const [],
    this.busy = false,
    this.error,
  });

  final ReaderFont selected;
  final List<ReaderFont> imported;
  final bool busy;
  final ReaderFontError? error;

  ReaderFontState copyWith({
    ReaderFont? selected,
    List<ReaderFont>? imported,
    bool? busy,
    ReaderFontError? error,
    bool clearError = false,
  }) {
    return ReaderFontState(
      selected: selected ?? this.selected,
      imported: imported ?? this.imported,
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ReaderFontController extends StateNotifier<ReaderFontState> {
  ReaderFontController(this._repository)
    : super(
        ReaderFontState(
          selected: _repository.selected,
          imported: _repository.importedFonts(),
        ),
      );

  final ReaderFontRepository _repository;

  /// Incremented per [select] call so a slow load that finishes after a newer
  /// tap can't overwrite the newer choice.
  int _selectRequest = 0;

  /// Applies [font] to the reader. The family is loaded before the state
  /// changes so the reader never renders a not-yet-loaded font.
  Future<bool> select(ReaderFont font) async {
    final request = ++_selectRequest;
    if (state.selected == font) {
      if (state.busy) state = state.copyWith(busy: false);
      return true;
    }
    // Only show progress when there's real work: tapping an already-loaded
    // font (every previewed row) should switch instantly, with one rebuild.
    final loader = _repository.loader;
    if (!loader.isLoaded(font)) {
      state = state.copyWith(busy: true, clearError: true);
    }
    final ok = await loader.ensureLoaded(font);
    if (!mounted || request != _selectRequest) return ok;
    if (!ok) {
      state = state.copyWith(
        busy: false,
        error: ReaderFontError(
          ReaderFontErrorKind.loadFailed,
          fontName: font.name,
        ),
      );
      return false;
    }
    await _repository.saveSelected(font);
    if (!mounted || request != _selectRequest) return true;
    state = state.copyWith(selected: font, busy: false, clearError: true);
    return true;
  }

  /// Imports a font file's bytes. Returns the new font, or null on failure
  /// (the reason is in [ReaderFontState.error]).
  Future<ReaderFont?> import({
    required String fileName,
    required Uint8List bytes,
  }) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final font = await _repository.importFont(
        fileName: fileName,
        bytes: bytes,
      );
      if (!mounted) return font;
      state = state.copyWith(
        busy: false,
        imported: _repository.importedFonts(),
      );
      return font;
    } on InvalidFontFileException catch (e) {
      if (mounted) {
        state = state.copyWith(
          busy: false,
          error: ReaderFontError(switch (e.reason) {
            InvalidFontReason.unsupportedType =>
              ReaderFontErrorKind.unsupportedType,
            InvalidFontReason.notAFont => ReaderFontErrorKind.notAFont,
            InvalidFontReason.unloadable => ReaderFontErrorKind.unloadable,
          }),
        );
      }
    } catch (e) {
      debugPrint('ReaderFontController: import failed: $e');
      if (mounted) {
        state = state.copyWith(
          busy: false,
          error: const ReaderFontError(ReaderFontErrorKind.importFailed),
        );
      }
    }
    return null;
  }

  Future<void> deleteImported(ReaderFont font) async {
    try {
      await _repository.deleteImported(font);
    } catch (e) {
      debugPrint('ReaderFontController: delete failed: $e');
      if (mounted) {
        state = state.copyWith(
          error: ReaderFontError(
            ReaderFontErrorKind.deleteFailed,
            fontName: font.name,
          ),
        );
      }
      return;
    }
    if (!mounted) return;
    state = state.copyWith(
      imported: _repository.importedFonts(),
      selected: state.selected == font ? ReaderFont.systemDefault : null,
    );
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final readerFontProvider =
    StateNotifierProvider<ReaderFontController, ReaderFontState>((ref) {
      return ReaderFontController(ref.watch(readerFontRepositoryProvider));
    });
