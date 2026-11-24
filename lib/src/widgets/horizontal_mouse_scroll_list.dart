import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Horizontal list that also scrolls with a mouse wheel and mouse-drag.
/// Flutter's default [ScrollBehavior] only maps touch/stylus/trackpad to
/// drag-to-scroll, and a plain [ListView] never forwards mouse-wheel
/// [PointerScrollEvent]s (which report a vertical delta) to a horizontal
/// scroll position, so a bare horizontal ListView is stuck touch/trackpad
/// only on desktop.
///
/// Needs a bounded height (it is a [ListView]); for a row that should size
/// itself to its children use [HorizontalMouseScrollView].
class HorizontalMouseScrollList extends StatefulWidget {
  const HorizontalMouseScrollList({super.key, required this.children});

  final List<Widget> children;

  @override
  State<HorizontalMouseScrollList> createState() =>
      _HorizontalMouseScrollListState();
}

class _HorizontalMouseScrollListState
    extends _HorizontalMouseScrollState<HorizontalMouseScrollList> {
  @override
  Widget buildScrollable(ScrollController controller) => ListView(
    controller: controller,
    scrollDirection: Axis.horizontal,
    children: widget.children,
  );
}

/// Same mouse-wheel / mouse-drag support as [HorizontalMouseScrollList], for
/// a single [child] (usually a [Row]) whose height comes from its content —
/// e.g. the reader's verse-selection action buttons.
class HorizontalMouseScrollView extends StatefulWidget {
  const HorizontalMouseScrollView({super.key, required this.child});

  final Widget child;

  @override
  State<HorizontalMouseScrollView> createState() =>
      _HorizontalMouseScrollViewState();
}

class _HorizontalMouseScrollViewState
    extends _HorizontalMouseScrollState<HorizontalMouseScrollView> {
  @override
  Widget buildScrollable(ScrollController controller) => SingleChildScrollView(
    controller: controller,
    scrollDirection: Axis.horizontal,
    child: widget.child,
  );
}

/// Shared wheel/drag handling for the horizontal scrollers above.
abstract class _HorizontalMouseScrollState<T extends StatefulWidget>
    extends State<T> {
  final _controller = ScrollController();

  Widget buildScrollable(ScrollController controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_controller.hasClients) return;
    // Mouse wheels report their delta on dy; trackpads (already handled by
    // native drag) may report dx instead when scrolled sideways — forward
    // whichever axis actually moved.
    final delta = event.scrollDelta.dy.abs() >= event.scrollDelta.dx.abs()
        ? event.scrollDelta.dy
        : event.scrollDelta.dx;
    final position = _controller.position;
    final target = (_controller.offset + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    _controller.jumpTo(target);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            ...ScrollConfiguration.of(context).dragDevices,
            PointerDeviceKind.mouse,
          },
        ),
        child: buildScrollable(_controller),
      ),
    );
  }
}
