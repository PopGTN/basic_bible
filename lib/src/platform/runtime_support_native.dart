import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_size/window_size.dart';

const bool isWebRuntime = false;
bool get isDesktopRuntime =>
    Platform.isWindows || Platform.isLinux || Platform.isMacOS;
bool get isMobileRuntime => Platform.isAndroid || Platform.isIOS;

Future<void> configurePlatformServices() async {
  if (isDesktopRuntime) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

const double _minWindowWidth = 480;
const double _minWindowHeight = 854;

void setupPlatformWindow() {
  if (!isDesktopRuntime) return;

  setWindowTitle('The Basic Bible App');
  setWindowMinSize(const Size(_minWindowWidth, _minWindowHeight));

  getCurrentScreen().then((screen) {
    if (screen == null) return;
    setWindowFrame(
      Rect.fromCenter(center: screen.frame.center, width: 800, height: 600),
    );
  });
}
