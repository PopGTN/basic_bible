import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/app.dart';
import 'src/services/shared_preferences_provider.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

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
  if (kIsWeb) {
    // Change default factory on the web
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  setupWindow();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

const double minWindowWidth = 480;
const double minWindowHeight = 854;
// const double maxWindowWidth = 480;
// const double maxWindowHeight = 854;
void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    setWindowTitle('The Basic Bible App');

    // Minimum size
    setWindowMinSize(const Size(minWindowWidth, minWindowHeight));

    // Optional: Maximum size (can remove to allow free resizing)
    // setWindowMaxSize(const Size(maxWindowWidth, maxWindowHeight));

    // Initial window placement (optional)
    getCurrentScreen().then((screen) {
      if (screen != null) {
        setWindowFrame(
          Rect.fromCenter(
            center: screen.frame.center,
            width: 800, // use a reasonable default, not minWindow
            height: 600, // use a reasonable default
          ),
        );
      }
    });
  }
}
