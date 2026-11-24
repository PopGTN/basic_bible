import 'package:basic_bible/src/widgets/collapsing_bottom_bar_inset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<double> bodyBottomInset(WidgetTester tester, double visible) async {
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(bottom: 34);
    addTearDown(tester.view.reset);
    late double seen;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: SizedBox(height: 56 * visible),
          body: CollapsingBottomBarInset(
            barVisibility: AlwaysStoppedAnimation(visible),
            child: Builder(
              builder: (context) {
                seen = MediaQuery.paddingOf(context).bottom;
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
    return seen;
  }

  testWidgets('bar shown: it covers the safe area, so the body gets none', (
    tester,
  ) async {
    expect(await bodyBottomInset(tester, 1), 0);
  });

  testWidgets('bar collapsed: the body gets the safe area back', (
    tester,
  ) async {
    expect(await bodyBottomInset(tester, 0), 34);
  });

  testWidgets('halfway: half of it', (tester) async {
    expect(await bodyBottomInset(tester, 0.5), 17);
  });

  testWidgets('animating the inset rebuilds only what reads it', (
    tester,
  ) async {
    // How the reader uses it: a SafeArea around the text absorbs the inset,
    // so the text (all the verses) is not rebuilt on every animation frame.
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(bottom: 34);
    addTearDown(tester.view.reset);
    final bar = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 250),
      value: 1,
    );
    addTearDown(bar.dispose);
    var textBuilds = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: const SizedBox(height: 56),
          body: CollapsingBottomBarInset(
            barVisibility: bar,
            child: SafeArea(
              top: false,
              child: Builder(
                builder: (context) {
                  textBuilds++;
                  return const SizedBox.expand(key: Key('text'));
                },
              ),
            ),
          ),
        ),
      ),
    );
    final textBox = find.byKey(const Key('text'));
    final heightShown = tester.getSize(textBox).height;

    bar.reverse(); // the bars hide
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pumpAndSettle();

    expect(textBuilds, 1);
    expect(tester.getSize(textBox).height, heightShown - 34);
  });
}
