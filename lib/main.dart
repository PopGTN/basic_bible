import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/platform/runtime_support.dart';
import 'src/services/shared_preferences_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Each Bible translation intentionally has its own TranslationDatabase
  // instance (one per SQLite file). Drift's duplicate-database check fires on
  // any second instantiation of the same generated class, which is a
  // false-positive for this multi-file architecture.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  // Bootstrap prefs before runApp so startup routing and tab selection can
  // read their persisted values synchronously instead of flashing the wrong UI.
  final prefs = await SharedPreferences.getInstance();
  await configurePlatformServices();
  setupPlatformWindow();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}
