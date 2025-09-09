import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  setupWindow();
  runApp( ProviderScope(child: MyApp()));
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

