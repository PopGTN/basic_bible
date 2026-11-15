import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../services/shared_preferences_provider.dart';
import '../../../localization/language_pack_providers.dart';
import '../../../localization/language_pack_service.dart';
import '../../../localization/language_pack_store.dart';

const _languageCodeKey = 'languageCode';
const _languageIsSystemKey = 'languageIsSystem';

/// Languages the app ships a pack for (see lib/l10n/languages.json). Used to
/// match the device language on first launch without a network round trip.
const knownLanguageCodes = {'en', 'fr'};

/// Picks the first device locale we have a pack for, else English.
String resolveDeviceLanguage(
  List<ui.Locale> deviceLocales, {
  Set<String> supported = knownLanguageCodes,
}) {
  for (final locale in deviceLocales) {
    if (supported.contains(locale.languageCode)) return locale.languageCode;
  }
  return 'en';
}

class LanguageState {
  const LanguageState({
    required this.code,
    required this.followsDevice,
    this.downloadingCode,
    this.errorCode,
  });

  /// Language currently applied to the UI.
  final String code;

  /// True until the user picks a language manually.
  final bool followsDevice;

  /// Pack being downloaded right now, if any.
  final String? downloadingCode;

  /// Language whose last download failed, if any.
  final String? errorCode;

  LanguageState copyWith({
    String? code,
    bool? followsDevice,
    String? downloadingCode,
    bool clearDownloading = false,
    String? errorCode,
    bool clearError = false,
  }) => LanguageState(
    code: code ?? this.code,
    followsDevice: followsDevice ?? this.followsDevice,
    downloadingCode: clearDownloading
        ? null
        : (downloadingCode ?? this.downloadingCode),
    errorCode: clearError ? null : (errorCode ?? this.errorCode),
  );
}

/// Reads the persisted language synchronously (first launch follows the
/// device language) and loads any cached pack into memory. Call from main()
/// after the bundled English pack has loaded.
LanguageState loadInitialLanguageState(
  SharedPreferences prefs,
  LanguagePackService service, {
  List<ui.Locale>? deviceLocales,
}) {
  final saved = prefs.getString(_languageCodeKey);
  final followsDevice = saved == null || (prefs.getBool(_languageIsSystemKey) ?? false);
  final device = resolveDeviceLanguage(
    deviceLocales ?? ui.PlatformDispatcher.instance.locales,
  );
  var code = followsDevice ? device : saved;
  // Cached pack not available (e.g. cache cleared): English until it downloads.
  if (code != 'en' && !service.loadCached(code)) code = 'en';
  return LanguageState(code: code, followsDevice: followsDevice);
}

final initialLanguageStateProvider = Provider<LanguageState>((ref) {
  return loadInitialLanguageState(
    ref.watch(sharedPreferencesProvider),
    ref.watch(languagePackServiceProvider),
  );
});

final languageProvider = StateNotifierProvider<LanguageNotifier, LanguageState>(
  (ref) => LanguageNotifier(
    ref.watch(sharedPreferencesProvider),
    ref.watch(languagePackServiceProvider),
    ref.read(initialLanguageStateProvider),
  ),
);

class LanguageNotifier extends StateNotifier<LanguageState> {
  LanguageNotifier(this._prefs, this._service, LanguageState initial)
    : super(initial) {
    _bootstrap(initial);
  }

  final SharedPreferences _prefs;
  final LanguagePackService _service;

  /// If the device language's pack isn't cached yet (first launch), fetch it
  /// in the background and switch when it arrives; otherwise refresh stale.
  Future<void> _bootstrap(LanguageState initial) async {
    if (!initial.followsDevice) {
      if (initial.code != 'en') await _refreshQuietly(initial.code);
      return;
    }
    final device = resolveDeviceLanguage(ui.PlatformDispatcher.instance.locales);
    if (device == 'en') return;
    if (device == state.code) {
      await _refreshQuietly(device);
      return;
    }
    await _apply(device, followsDevice: true, persist: false);
  }

  Future<void> _refreshQuietly(String code) async {
    try {
      await _service.ensurePack(code);
      // Re-apply so widgets pick up refreshed strings.
      state = state.copyWith(code: code);
    } catch (_) {}
  }

  /// User picked a language manually.
  Future<bool> setLanguage(String code) =>
      _apply(code, followsDevice: false, persist: true);

  /// User chose "Device language".
  Future<bool> useDeviceLanguage() => _apply(
    resolveDeviceLanguage(ui.PlatformDispatcher.instance.locales),
    followsDevice: true,
    persist: true,
  );

  Future<bool> _apply(
    String code, {
    required bool followsDevice,
    required bool persist,
  }) async {
    state = state.copyWith(downloadingCode: code, clearError: true);
    try {
      await _service.ensurePack(code);
    } catch (_) {
      if (mounted) {
        state = state.copyWith(clearDownloading: true, errorCode: code);
      }
      return false;
    }
    if (persist || followsDevice) {
      await _prefs.setString(_languageCodeKey, code);
      await _prefs.setBool(_languageIsSystemKey, followsDevice);
    }
    if (mounted) {
      state = LanguageState(code: code, followsDevice: followsDevice);
    }
    return true;
  }
}

/// Used by main() so the first frame already has strings.
Future<LanguagePackService> bootstrapLanguagePacks(SharedPreferences prefs) async {
  await LanguagePackStore.loadBundledEnglish();
  return LanguagePackService(prefs: prefs);
}
