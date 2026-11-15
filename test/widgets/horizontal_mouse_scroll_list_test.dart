// Guards mouse-wheel scrolling on HorizontalMouseScrollList (used by the
// theme picker in both the Settings screen and the home screen's quick
// settings). A plain horizontal ListView ignores PointerScrollEvent (which
// reports a vertical delta) entirely on desktop — this test drives a real
// mouse-wheel gesture and checks the list actually moved.

import 'package:basic_bible/src/widgets/horizontal_mouse_scroll_list.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mouse wheel scrolls a horizontal list', (tester) async {
    final controllerFinder = find.byType(ListView);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 100,
            child: HorizontalMouseScrollList(
              children: [
                for (var i = 0; i < 30; i++)
                  Container(width: 100, height: 100, color: Colors.primaries[i % Colors.primaries.length]),
              ],
            ),
          ),
        ),
      ),
    );

    final listView = tester.widget<ListView>(controllerFinder);
    final controller = listView.controller!;
    expect(controller.offset, 0);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: tester.getCenter(controllerFinder));
    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: tester.getCenter(controllerFinder),
        scrollDelta: const Offset(0, 200),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(controller.offset, greaterThan(0));

    // Scrolling the other way moves it back down, clamped at zero.
    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: tester.getCenter(controllerFinder),
        scrollDelta: const Offset(0, -1000),
      ),
    );
    await tester.pumpAndSettle();
    expect(controller.offset, 0);
  });
}
