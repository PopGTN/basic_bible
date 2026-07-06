import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Horizontal list that also scrolls with a mouse wheel and mouse-drag.
/// Flutter's default [ScrollBehavior] only maps touch/stylus/trackpad to
/// drag-to-scroll, and a plain [ListView] never forwards mouse-wheel
/// [PointerScrollEvent]s (which report a vertical delta) to a horizontal
/// scroll position, so a bare horizontal ListView is stuck touch/trackpad
/// only on desktop.
class HorizontalMouseScrollList extends StatefulWidget {
  const HorizontalMouseScrollList({super.key, required this.children});

  final List<Widget> children;

  @override
  State<HorizontalMouseScrollList> createState() =>
      _HorizontalMouseScrollListState();
}

class _HorizontalMouseScrollListState
    extends State<HorizontalMouseScrollList> {
  final _controller = ScrollController();

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
        child: ListView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          children: widget.children,
        ),
      ),
    );
  }
}
