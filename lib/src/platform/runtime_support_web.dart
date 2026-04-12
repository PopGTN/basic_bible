import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

const bool isWebRuntime = true;
const bool isDesktopRuntime = false;
const bool isMobileRuntime = false;

Future<void> configurePlatformServices() async {
  databaseFactory = databaseFactoryFfiWeb;
}

void setupPlatformWindow() {}
