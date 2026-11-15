// Reproduces the reader's bar auto-hide chain in continuous mode:
// ScrollablePositionedList → NotificationListener → the shell's
// _handleScrollNotification logic (replicated verbatim below).
//
// Guards the fix for "bars never auto-hide in continuous mode" and
// documents ScrollablePositionedList's notification/metrics behavior.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// Replica of _BibleViewerTabState._handleScrollNotification so the widget
/// test can observe the toggle decisions. Keep in sync with
/// bible_viewer_tab.dart.
class _ChromeToggleProbe {
  double? lastScroll;
  bool isHiding = false;
  final List<bool> toggles = []; // recorded show=true / hide=false calls
  final List<double> deltas = [];

  void handle(ScrollNotification notification) {
    final current = notification.metrics.pixels;
    final max = notification.metrics.maxScrollExtent;
    final delta = current - (lastScroll ?? current);
    lastScroll = current;

    if (delta.abs() < 1) return;
    deltas.add(delta);
    if (delta.abs() > 400) return;

    if (current >= max) {
      if (isHiding) _toggle(show: true);
      return;
    }

    if (delta > 0 && !isHiding) {
      _toggle(show: false);
    } else if (delta < 0 && isHiding) {
      _toggle(show: true);
    }
  }

  void _toggle({required bool show}) {
    toggles.add(show);
    isHiding = !show;
  }
}

Widget _harness(_ChromeToggleProbe probe, {int initialScrollIndex = 0}) {
  return MaterialApp(
    home: Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          probe.handle(notification);
          return false;
        },
        child: ScrollablePositionedList.builder(
          initialScrollIndex: initialScrollIndex,
          initialAlignment: 0.02,
          itemCount: 1189,
          itemBuilder: (context, index) =>
              SizedBox(height: 600, child: Text('Chapter $index')),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('dragging down hides the bars, dragging up shows them again',
      (tester) async {
    final probe = _ChromeToggleProbe();
    await tester.pumpWidget(_harness(probe));

    // Drag content up 200px (= user scrolling down the page).
    await tester.drag(
      find.byType(ScrollablePositionedList),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    expect(
      probe.toggles,
      isNotEmpty,
      reason: 'scroll notifications never reached the chrome handler — '
          'deltas seen: ${probe.deltas}',
    );
    expect(probe.toggles.first, isFalse, reason: 'first toggle should hide');
    expect(probe.isHiding, isTrue);

    // Drag content down (= user scrolling up) → bars come back.
    await tester.drag(
      find.byType(ScrollablePositionedList),
      const Offset(0, 200),
    );
    await tester.pumpAndSettle();

    expect(probe.toggles.last, isTrue, reason: 'scrolling up should show');
    expect(probe.isHiding, isFalse);
  });

  testWidgets('auto-hide also works when anchored mid-Bible (after a jump)',
      (tester) async {
    // After chapter navigation SPL re-anchors: pixels are relative to the
    // anchored item, so content before it lives at negative offsets. The
    // delta-based logic must still work in that coordinate space.
    final probe = _ChromeToggleProbe();
    await tester.pumpWidget(_harness(probe, initialScrollIndex: 600));

    await tester.drag(
      find.byType(ScrollablePositionedList),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    expect(
      probe.toggles,
      isNotEmpty,
      reason: 'no toggles mid-Bible — deltas seen: ${probe.deltas}',
    );
    expect(probe.toggles.first, isFalse);

    await tester.drag(
      find.byType(ScrollablePositionedList),
      const Offset(0, 200),
    );
    await tester.pumpAndSettle();
    expect(probe.isHiding, isFalse);
  });
}
