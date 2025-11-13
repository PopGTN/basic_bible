import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Change default factory on the web
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  setupWindow();
  runApp(ProviderScope(child: MyApp()));
}

const double minWindowWidth = 480;
const double minWindowHeight = 854;
// const double maxWindowWidth = 480;
// const double maxWindowHeight = 854;
void setupWindow() {
  if (!kIsWeb &&
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
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
            width: 800,  // use a reasonable default, not minWindow
            height: 600, // use a reasonable default
          ),
        );
      }
    });
  }
}

