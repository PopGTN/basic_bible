import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple application-wide service exposing a ValueNotifier for the
/// Bible text font size. This avoids adding another Riverpod provider
/// and keeps the behavior simple: change the value and listeners rebuild.
///
/// The size is persisted to SharedPreferences. Call [load] once at startup
/// (before runApp) so the saved size is applied from the first frame.
class FontSizeService {
  FontSizeService._();

  static final FontSizeService instance = FontSizeService._();

  static const prefsKey = 'reader_font_size';
  static const defaultSize = 16.0;
  static const minSize = 12.0;
  static const maxSize = 28.0;

  /// Notifier that widgets can listen to. Default is 16.0.
  final ValueNotifier<double> notifier = ValueNotifier<double>(defaultSize);

  SharedPreferences? _prefs;

  double get size => notifier.value;

  /// Restores the saved size and starts persisting future changes.
  void load(SharedPreferences prefs) {
    _prefs = prefs;
    final saved = prefs.getDouble(prefsKey);
    if (saved != null) {
      notifier.value = saved.clamp(minSize, maxSize);
    }
  }

  void setSize(double v) {
    notifier.value = v;
    _prefs?.setDouble(prefsKey, v);
  }
}
