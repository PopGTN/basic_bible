import 'package:basic_bible/src/features/reader/application/view_models/split_view_view_models.dart';
import 'package:basic_bible/src/features/reader/presentation/split_view/secondary_reader_pane.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wraps the main reader and, when split view is on (#84), adds the second
/// reading pane: side by side when there's room, stacked on narrow screens.
class SplitReaderLayout extends ConsumerWidget {
  const SplitReaderLayout({super.key, required this.primary});

  /// The main reader. Kept as the same widget instance either way so turning
  /// split view on/off doesn't rebuild it from scratch.
  final Widget primary;

  /// Below this width each pane would be too narrow to read side by side.
  static const double sideBySideMinWidth = 700;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(splitViewEnabledProvider);
    if (!enabled) return primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth >= sideBySideMinWidth;
        final divider = sideBySide
            ? const VerticalDivider(width: 1)
            : const Divider(height: 1);
        final children = [
          Expanded(child: primary),
          divider,
          const Expanded(child: SecondaryReaderPane()),
        ];
        return sideBySide
            ? Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: children)
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
      },
    );
  }
}
