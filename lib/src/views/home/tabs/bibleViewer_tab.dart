import 'package:basic_bible/src/views/home/tabs/widgets/ReferenceBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

class BibleViewerTab extends StatefulWidget {
  final VoidCallback showBottomNav;
  final VoidCallback hideBottomNav;

  const BibleViewerTab({
    super.key,
    required this.showBottomNav,
    required this.hideBottomNav,
  });

  @override
  State<BibleViewerTab> createState() => _BibleViewerTabState();
}

class _BibleViewerTabState extends State<BibleViewerTab> {
  final ScrollController _scrollController = ScrollController();
  static const double _bottomNavHeight = 56;
  static const double _chapterBarHeight = 56;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final direction = _scrollController.position.userScrollDirection;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // schedule state change in next frame to avoid layout conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Always show bottom nav if at the bottom
      if (currentScroll >= maxScroll) {
        widget.showBottomNav();
      } else if (direction == ScrollDirection.reverse) {
        widget.hideBottomNav();
      } else if (direction == ScrollDirection.forward) {
        widget.showBottomNav();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paddingBottom = _bottomNavHeight + _chapterBarHeight;

    return Stack(
      children: [
        // Bible text with padding to avoid ghost space
        ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(16, 16, 16, paddingBottom),
          itemCount: 100,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Verse line ${index + 1} — sample Bible text.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),

        // ChapterBar fixed above bottom nav
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            child: const ChapterBar(barHeight: _chapterBarHeight),
          ),
        ),
      ],
    );
  }
}
