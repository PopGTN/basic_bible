import 'package:flutter/foundation.dart';

/// Simple application-wide service exposing a ValueNotifier for the
/// Bible text font size. This avoids adding another Riverpod provider
/// and keeps the behavior simple: change the value and listeners rebuild.
class FontSizeService {
  FontSizeService._();

  static final FontSizeService instance = FontSizeService._();

  /// Notifier that widgets can listen to. Default is 16.0.
  final ValueNotifier<double> notifier = ValueNotifier<double>(16.0);

  double get size => notifier.value;

  void setSize(double v) => notifier.value = v;
}
