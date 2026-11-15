#!/usr/bin/env python3
"""Generates lib/l10n/app_localizations.dart from lib/l10n/app_en.arb.

Strings are looked up at runtime (downloaded language pack -> bundled English
-> key), so languages can be added without recompiling. Run after editing
app_en.arb:  python3 tool/gen_l10n.py
"""
import json, re, pathlib

root = pathlib.Path(__file__).resolve().parent.parent
arb = json.loads((root / 'lib/l10n/app_en.arb').read_text(encoding='utf-8'))
out = []
for key, value in arb.items():
    if key.startswith('@') or not isinstance(value, str):
        continue
    meta = arb.get('@' + key, {})
    phs = meta.get('placeholders', {}) if isinstance(meta, dict) else {}
    used = re.findall(r'\{(\w+)\}', value)
    names = list(dict.fromkeys(list(phs.keys()) + used))
    doc = value.replace('\n', ' ')
    if len(doc) > 100:
        doc = doc[:97] + '...'
    if not names:
        out.append(f"  /// {doc}\n  String get {key} => _t('{key}');\n")
    else:
        params = ', '.join(f"{'int' if phs.get(n, {}).get('type') == 'int' else 'Object'} {n}" for n in names)
        args = ', '.join(f"'{n}': {n}" for n in names)
        out.append(f"  /// {doc}\n  String {key}({params}) => _t('{key}', {{{args}}});\n")

header = '''// GENERATED FILE - DO NOT EDIT. Run `python3 tool/gen_l10n.py`.
// Source: lib/l10n/app_en.arb
import 'package:basic_bible/src/features/localization/language_pack_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Runtime-resolved UI strings. Lookup order: downloaded language pack,
/// bundled English, then the key itself.
class AppLocalizations {
  AppLocalizations(this.locale)
    : _strings = LanguagePackStore.strings(locale.languageCode),
      _fallback = LanguagePackStore.strings('en');

  final Locale locale;
  final Map<String, String> _strings;
  final Map<String, String> _fallback;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// Locales the framework (Material/Cupertino) widgets can be built for.
  /// App strings themselves are not limited to this list.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('es'),
    Locale('de'),
    Locale('zh'),
  ];

  static AppLocalizations? of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  String _t(String key, [Map<String, Object>? args]) {
    var text = _strings[key] ?? _fallback[key] ?? key;
    if (args != null) {
      args.forEach((name, value) {
        text = text.replaceAll('{$name}', '$value');
      });
    }
    return text;
  }

'''
footer = '''}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  // Packs can finish downloading after the first load.
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => true;
}
'''
(root / 'lib/l10n/app_localizations.dart').write_text(header + '\n'.join(out) + footer, encoding='utf-8')
print(len(out), 'strings')
