import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ReaderLayoutMode { verseList, document }

final continuousScrollingProvider =
    StateNotifierProvider<ContinuousScrollingNotifier, bool>((ref) {
      return ContinuousScrollingNotifier(
        ref.read(sharedPreferencesProvider),
      );
    });

final showBookIntroductionsProvider =
    StateNotifierProvider<ShowBookIntroductionsNotifier, bool>((ref) {
      return ShowBookIntroductionsNotifier(
        ref.read(sharedPreferencesProvider),
      );
    });

final showVerseSelectorProvider =
    StateNotifierProvider<ShowVerseSelectorNotifier, bool>((ref) {
      return ShowVerseSelectorNotifier(
        ref.read(sharedPreferencesProvider),
      );
    });

final readerLayoutModeProvider =
    StateNotifierProvider<ReaderLayoutModeNotifier, ReaderLayoutMode>((ref) {
      return ReaderLayoutModeNotifier(ref.read(sharedPreferencesProvider));
    });

class ContinuousScrollingNotifier extends StateNotifier<bool> {
  ContinuousScrollingNotifier(this._prefs)
    : super(_prefs.getBool('reader_continuous_scrolling') ?? false);

  final SharedPreferences _prefs;

  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool('reader_continuous_scrolling', enabled);
    state = enabled;
  }
}

class ShowBookIntroductionsNotifier extends StateNotifier<bool> {
  ShowBookIntroductionsNotifier(this._prefs)
    : super(
        _prefs.getBool('reader_show_book_introductions') ??
        _prefs.getBool('reader_show_chapter_headers') ??
        true,
      );

  final SharedPreferences _prefs;

  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool('reader_show_book_introductions', enabled);
    state = enabled;
  }
}

class ShowVerseSelectorNotifier extends StateNotifier<bool> {
  ShowVerseSelectorNotifier(this._prefs)
    : super(_prefs.getBool('reader_show_verse_selector') ?? true);

  final SharedPreferences _prefs;

  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool('reader_show_verse_selector', enabled);
    state = enabled;
  }
}

class ReaderLayoutModeNotifier extends StateNotifier<ReaderLayoutMode> {
  ReaderLayoutModeNotifier(this._prefs)
    : super(_parseLayoutMode(_prefs.getString('reader_layout_mode')));

  final SharedPreferences _prefs;

  static ReaderLayoutMode _parseLayoutMode(String? rawMode) {
    if (rawMode == 'paragraph') {
      return ReaderLayoutMode.document;
    }
    return ReaderLayoutMode.values.firstWhere(
      (mode) => mode.name == rawMode,
      orElse: () => ReaderLayoutMode.verseList,
    );
  }

  Future<void> setLayoutMode(ReaderLayoutMode mode) async {
    await _prefs.setString('reader_layout_mode', mode.name);
    state = mode;
  }
}
