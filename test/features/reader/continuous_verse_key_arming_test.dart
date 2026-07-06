// Guards the fix for "continuous mode never scrolls to the exact verse".
//
// ScrollablePositionedList briefly renders its scrollTo()/initialScrollIndex
// target in two internal viewports while resolving position for items with
// unknown extents. A GlobalKey present in both trees at once throws "Multiple
// widgets used the same GlobalKey". The reader avoids this by only attaching
// a real GlobalKey to the one "armed" section, and only once navigation has
// fully settled (see _armedVerseSectionIndex / _verseKeySuppressed in
// bible_viewer_tab_state_core.dart).
//
// This test drives a minimal ScrollablePositionedList harness with the same
// shape of key-gating and checks the two halves of that claim directly:
//   1. Keying the scrollTo() target *before* it settles risks the crash.
//   2. Keying it only *after* settling works and attaches a live anchor.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class _KeyedListHarness extends StatefulWidget {
  const _KeyedListHarness({super.key, required this.itemCount});

  final int itemCount;

  @override
  State<_KeyedListHarness> createState() => _KeyedListHarnessState();
}

class _KeyedListHarnessState extends State<_KeyedListHarness> {
  final Map<int, GlobalKey> _keys = {};
  final ItemScrollController itemScrollController = ItemScrollController();
  int? armedIndex;

  GlobalKey _keyFor(int index) => _keys.putIfAbsent(index, GlobalKey.new);

  BuildContext? contextFor(int index) => _keyFor(index).currentContext;

  void arm(int index) => setState(() => armedIndex = index);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ScrollablePositionedList.builder(
          initialScrollIndex: 0,
          itemScrollController: itemScrollController,
          itemCount: widget.itemCount,
          itemBuilder: (context, index) {
            return SizedBox(
              key: index == armedIndex ? _keyFor(index) : null,
              height: 400,
              child: Text('Item $index'),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
    'a real anchor attaches once armed after scrollTo has settled',
    (tester) async {
      final key = GlobalKey<_KeyedListHarnessState>();
      await tester.pumpWidget(_KeyedListHarness(key: key, itemCount: 200));
      await tester.pumpAndSettle();

      // Reposition first, entirely unkeyed, then let the animation settle.
      unawaited(
        key.currentState!.itemScrollController.scrollTo(
          index: 10,
          duration: const Duration(milliseconds: 50),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Only now attach the real key — mirrors _armVerseSectionAfterSettle
      // running after scrollTo()'s Future completes.
      key.currentState!.arm(10);
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(
        key.currentState!.contextFor(10),
        isNotNull,
        reason: 'armed index should have a live GlobalKey context once settled',
      );
    },
  );

  testWidgets(
    'a large jump (key-reset via initialScrollIndex) also settles cleanly '
    'before arming',
    (tester) async {
      final key = GlobalKey<_KeyedListHarnessState>();
      await tester.pumpWidget(_KeyedListHarness(key: key, itemCount: 1200));
      await tester.pumpAndSettle();

      unawaited(
        key.currentState!.itemScrollController.scrollTo(
          index: 900,
          duration: const Duration(milliseconds: 50),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      key.currentState!.arm(900);
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(key.currentState!.contextFor(900), isNotNull);
    },
  );

  testWidgets(
    're-navigating away from an armed section and back settles cleanly when '
    'the key is cleared before the second reposition',
    (tester) async {
      final key = GlobalKey<_KeyedListHarnessState>();
      await tester.pumpWidget(_KeyedListHarness(key: key, itemCount: 200));
      await tester.pumpAndSettle();

      unawaited(
        key.currentState!.itemScrollController.scrollTo(
          index: 10,
          duration: const Duration(milliseconds: 50),
        ),
      );
      await tester.pumpAndSettle();
      key.currentState!.arm(10);
      await tester.pump();
      expect(key.currentState!.contextFor(10), isNotNull);

      // Disarm (matches _scheduleChapterFocus clearing the previous armed
      // section) before starting the next reposition, then re-arm the new
      // target once it settles.
      key.currentState!.arm(-1);
      await tester.pump();
      unawaited(
        key.currentState!.itemScrollController.scrollTo(
          index: 50,
          duration: const Duration(milliseconds: 50),
        ),
      );
      await tester.pumpAndSettle();
      key.currentState!.arm(50);
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Now navigate back to index 10 — the scenario that would throw the
      // duplicate-GlobalKey assertion if the old key were left attached
      // while SPL re-resolves index 10's position during this scrollTo.
      key.currentState!.arm(-1);
      await tester.pump();
      unawaited(
        key.currentState!.itemScrollController.scrollTo(
          index: 10,
          duration: const Duration(milliseconds: 50),
        ),
      );
      await tester.pumpAndSettle();
      key.currentState!.arm(10);
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(key.currentState!.contextFor(10), isNotNull);
    },
  );
}
