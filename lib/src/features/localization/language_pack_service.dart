import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'language_pack_store.dart';

/// A UI language the app can offer.
class LanguageInfo {
  const LanguageInfo({
    required this.code,
    required this.nativeName,
    required this.englishName,
  });

  final String code;
  final String nativeName;
  final String englishName;

  factory LanguageInfo.fromJson(Map<String, dynamic> json) => LanguageInfo(
    code: json['code'] as String,
    nativeName: json['nativeName'] as String,
    englishName: (json['englishName'] as String?) ?? json['nativeName'] as String,
  );
}

/// Downloads UI language packs (ARB files) from the project's GitHub repo and
/// caches them in SharedPreferences. English is bundled and never downloaded.
class LanguagePackService {
  LanguagePackService({
    required SharedPreferences prefs,
    http.Client? client,
    String? baseUrl,
    DateTime Function()? now,
    AssetBundle? bundle,
  }) : _prefs = prefs,
       _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? defaultBaseUrl,
       _now = now ?? DateTime.now,
       _bundle = bundle ?? rootBundle;

  static const defaultBaseUrl =
      String.fromEnvironment(
        'LANGUAGE_PACK_BASE_URL',
        defaultValue:
            'https://raw.githubusercontent.com/PopGTN/basic_bible/main/lib/l10n',
      );
  static const requestTimeout = Duration(seconds: 20);
  static const refreshAfter = Duration(days: 1);

  static const _indexKey = 'l10n_index_cache';
  static String _packKey(String code) => 'l10n_pack_$code';
  static String _checkedKey(String code) => 'l10n_pack_checked_$code';

  final SharedPreferences _prefs;
  final http.Client _client;
  final String _baseUrl;
  final DateTime Function() _now;
  final AssetBundle _bundle;

  static final _codePattern = RegExp(r'^[a-z]{2,3}$');

  /// Languages to list: remote index, else last cached index, else the
  /// index bundled with the app.
  Future<List<LanguageInfo>> availableLanguages() async {
    try {
      final body = await _get('$_baseUrl/languages.json');
      final parsed = _parseIndex(body);
      await _prefs.setString(_indexKey, body);
      return parsed;
    } catch (_) {
      final cached = _prefs.getString(_indexKey);
      if (cached != null) {
        try {
          return _parseIndex(cached);
        } catch (_) {}
      }
      return _parseIndex(
        await _bundle.loadString(LanguagePackStore.bundledIndexAsset),
      );
    }
  }

  /// Languages whose pack is already usable without network.
  bool isAvailableOffline(String code) =>
      code == 'en' || _prefs.containsKey(_packKey(code));

  /// Loads the cached pack into memory without touching the network.
  /// Returns false if there is nothing cached.
  bool loadCached(String code) {
    if (code == 'en') return LanguagePackStore.has('en');
    if (LanguagePackStore.has(code)) return true;
    final raw = _prefs.getString(_packKey(code));
    if (raw == null) return false;
    try {
      LanguagePackStore.put(code, LanguagePackStore.parseArb(raw));
      return true;
    } catch (_) {
      _prefs.remove(_packKey(code));
      return false;
    }
  }

  /// Makes the pack for [code] available in memory, downloading it if it is
  /// missing or older than [refreshAfter]. A failed refresh falls back to the
  /// cached copy; throws only if nothing usable exists.
  Future<void> ensurePack(String code, {bool forceRefresh = false}) async {
    if (code == 'en') return;
    if (!_codePattern.hasMatch(code)) {
      throw ArgumentError.value(code, 'code', 'invalid language code');
    }
    final haveCached = loadCached(code);
    if (haveCached && !forceRefresh && !_isStale(code)) return;
    try {
      final body = await _get('$_baseUrl/app_$code.arb');
      final parsed = LanguagePackStore.parseArb(body);
      await _prefs.setString(_packKey(code), body);
      await _prefs.setInt(_checkedKey(code), _now().millisecondsSinceEpoch);
      LanguagePackStore.put(code, parsed);
    } catch (_) {
      if (!haveCached) rethrow;
    }
  }

  bool _isStale(String code) {
    final checked = _prefs.getInt(_checkedKey(code));
    if (checked == null) return true;
    final age = _now().difference(DateTime.fromMillisecondsSinceEpoch(checked));
    return age >= refreshAfter;
  }

  Future<String> _get(String url) async {
    final uri = Uri.parse(url);
    final local = uri.host == 'localhost' || uri.host == '127.0.0.1';
    if (uri.scheme != 'https' && !(uri.scheme == 'http' && local)) {
      throw StateError('Language packs must be fetched over https');
    }
    final response = await _client.get(uri).timeout(requestTimeout);
    if (response.statusCode != 200) {
      throw http.ClientException('HTTP ${response.statusCode}', uri);
    }
    return utf8.decode(response.bodyBytes);
  }

  List<LanguageInfo> _parseIndex(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! List) throw const FormatException('Bad language index');
    final list = [
      for (final e in decoded)
        if (e is Map<String, dynamic>) LanguageInfo.fromJson(e),
    ].where((l) => _codePattern.hasMatch(l.code)).toList();
    if (list.isEmpty) throw const FormatException('Empty language index');
    return list;
  }
}
