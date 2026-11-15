import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/services/additional_licenses.dart';
import 'src/platform/runtime_support.dart';
import 'src/features/settings/application/view_models/language_view_model.dart';
import 'src/services/font_size_service.dart';
import 'src/services/shared_preferences_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Each Bible translation intentionally has its own TranslationDatabase
  // instance (one per SQLite file). Drift's duplicate-database check fires on
  // any second instantiation of the same generated class, which is a
  // false-positive for this multi-file architecture.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  // Licenses Flutter can't collect from pub (e.g. sql.js on web), #88.
  registerAdditionalLicenses();
  // Bootstrap prefs before runApp so startup routing and tab selection can
  // read their persisted values synchronously instead of flashing the wrong UI.
  final prefs = await SharedPreferences.getInstance();
  FontSizeService.instance.load(prefs);
  // English is bundled; a cached pack for the saved/device language is loaded
  // by languageProvider before the first frame (no network on the startup path).
  await bootstrapLanguagePacks(prefs);
  await configurePlatformServices();
  setupPlatformWindow();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}
