import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reader line-spacing presets.
///
/// [factor] multiplies each reader view's base line height (1.7 for document
/// mode, 1.5 for the verse list, …), so [normal] keeps today's look and the
/// other presets scale every view consistently.
enum LineSpacing {
  compact(0.85),
  normal(1.0),
  relaxed(1.2),
  loose(1.45);

  const LineSpacing(this.factor);

  final double factor;
}

/// App-wide reader line spacing, mirroring [FontSizeService]: a
/// [ValueNotifier] that the reader listens to, persisted to
/// SharedPreferences. Call [load] once before runApp.
class LineSpacingService {
  LineSpacingService._();

  static final LineSpacingService instance = LineSpacingService._();

  static const prefsKey = 'reader_line_spacing';

  final ValueNotifier<LineSpacing> notifier = ValueNotifier(LineSpacing.normal);

  SharedPreferences? _prefs;

  LineSpacing get spacing => notifier.value;

  /// Restores the saved preset (unknown values fall back to normal) and starts
  /// persisting future changes.
  void load(SharedPreferences prefs) {
    _prefs = prefs;
    final saved = prefs.getString(prefsKey);
    notifier.value = LineSpacing.values.firstWhere(
      (spacing) => spacing.name == saved,
      orElse: () => LineSpacing.normal,
    );
  }

  void setSpacing(LineSpacing spacing) {
    notifier.value = spacing;
    _prefs?.setString(prefsKey, spacing.name);
  }
}
