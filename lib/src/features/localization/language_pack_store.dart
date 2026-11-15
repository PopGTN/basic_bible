import 'dart:convert';

import 'package:flutter/services.dart';

/// In-memory store of UI string packs (language code -> key -> text).
/// English is bundled as an asset; other languages are downloaded by
/// [LanguagePackService] and put here.
class LanguagePackStore {
  LanguagePackStore._();

  static const bundledEnglishAsset = 'lib/l10n/app_en.arb';
  static const bundledIndexAsset = 'lib/l10n/languages.json';

  static final Map<String, Map<String, String>> _packs = {};

  static Map<String, String> strings(String languageCode) =>
      _packs[languageCode] ?? const {};

  static bool has(String languageCode) => _packs.containsKey(languageCode);

  static void put(String languageCode, Map<String, String> pack) {
    _packs[languageCode] = pack;
  }

  static Future<void> loadBundledEnglish([AssetBundle? bundle]) async {
    final raw = await (bundle ?? rootBundle).loadString(bundledEnglishAsset);
    _packs['en'] = parseArb(raw);
  }

  /// Parses ARB/JSON into plain string entries (metadata keys are dropped).
  /// Throws [FormatException] for anything that isn't a JSON object.
  static Map<String, String> parseArb(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Language pack is not a JSON object');
    }
    final result = <String, String>{};
    decoded.forEach((key, value) {
      if (key is String && !key.startsWith('@') && value is String) {
        result[key] = value;
      }
    });
    if (result.isEmpty) {
      throw const FormatException('Language pack has no strings');
    }
    return result;
  }
}
