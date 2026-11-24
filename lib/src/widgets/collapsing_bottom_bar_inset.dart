import 'package:flutter/widgets.dart';

/// Use as a Scaffold body when the bottom navigation bar can collapse.
///
/// Scaffold removes the screen's bottom safe area (gesture bar / home
/// indicator) from its body whenever it has a bottomNavigationBar, even one
/// collapsed to nothing. This gives it back in proportion to how hidden the
/// bar is ([barVisibility]: 1 shown, 0 hidden), so bottom controls in the body
/// keep their distance from the screen edge.
class CollapsingBottomBarInset extends StatelessWidget {
  const CollapsingBottomBarInset({
    super.key,
    required this.barVisibility,
    required this.child,
  });

  final Animation<double> barVisibility;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // From the view itself: the inherited MediaQuery has it removed already.
    final inset = MediaQueryData.fromView(View.of(context)).viewPadding.bottom;
    if (inset == 0) return child;
    return AnimatedBuilder(
      animation: barVisibility,
      child: child,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final bottom = inset * (1 - barVisibility.value);
        return MediaQuery(
          data: media.copyWith(
            padding: media.padding.copyWith(bottom: bottom),
            viewPadding: media.viewPadding.copyWith(bottom: bottom),
          ),
          child: child!,
        );
      },
    );
  }
}
