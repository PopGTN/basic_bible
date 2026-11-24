import 'package:basic_bible/src/features/settings/application/view_models/app_launch_preferences_view_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:flutter_riverpod/legacy.dart';

/// Indexes of the home shell's tabs. Use these instead of bare numbers so
/// adding a tab can't silently send links to the wrong one.
abstract final class HomeTabs {
  static const home = 0;
  static const bible = 1;
  static const hymns = 2;
  static const menu = 3;
}

final startupHomeTabIndexProvider = Provider<int>(
  (ref) =>
      ref.read(openBibleTabByDefaultProvider) ? HomeTabs.bible : HomeTabs.home,
);

/// ViewModel for the selected tab inside the authenticated home shell.
/// Initialises to 1 (Bible tab) when the user has enabled "Open Bible Tab By
/// Default", so the correct tab is active from the very first build without
/// needing a post-construction provider mutation.
final homeTabIndexProvider = StateProvider<int>(
  (ref) => ref.read(startupHomeTabIndexProvider),
);
