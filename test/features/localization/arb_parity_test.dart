import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _load(String code) =>
    jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _placeholders(String s) =>
    RegExp(r'\{(\w+)\}').allMatches(s).map((m) => m.group(1)!).toSet();

void main() {
  test('French pack covers every English key with matching placeholders', () {
    final en = _load('en');
    final fr = _load('fr');
    final keys = en.keys.where((k) => !k.startsWith('@'));
    for (final key in keys) {
      expect(fr.containsKey(key), isTrue, reason: 'fr is missing "$key"');
      expect(
        _placeholders(fr[key] as String),
        _placeholders(en[key] as String),
        reason: 'placeholder mismatch in "$key"',
      );
    }
  });

  test('language index only lists packs that exist', () {
    final index = jsonDecode(File('lib/l10n/languages.json').readAsStringSync())
        as List<dynamic>;
    for (final entry in index) {
      final code = (entry as Map<String, dynamic>)['code'] as String;
      expect(File('lib/l10n/app_$code.arb').existsSync(), isTrue);
    }
  });
}
