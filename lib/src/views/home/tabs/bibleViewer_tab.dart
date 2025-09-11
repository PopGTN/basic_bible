import 'package:basic_bible/src/views/home/tabs/widgets/ReferenceBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

class BibleViewerTab extends StatefulWidget {
  final VoidCallback showBottomNav;
  final VoidCallback hideBottomNav;
  final VoidCallback showAppBar;
  final VoidCallback hideAppBar;
  final bool isSmallDevice;

  const BibleViewerTab({
    super.key,
    required this.showBottomNav,
    required this.hideBottomNav,
    required this.showAppBar,
    required this.hideAppBar,
    required this.isSmallDevice,
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (currentScroll >= maxScroll) {
        widget.showBottomNav();
        if (widget.isSmallDevice) widget.showAppBar();
      } else if (direction == ScrollDirection.reverse) {
        widget.hideBottomNav();
        if (widget.isSmallDevice) widget.hideAppBar();
      } else if (direction == ScrollDirection.forward) {
        widget.showBottomNav();
        if (widget.isSmallDevice) widget.showAppBar();
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
    final isSmall = widget.isSmallDevice;

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            16,
            isSmall ? 16 : _chapterBarHeight + 16, // leave room for top ChapterBar on large screens
            16,
            paddingBottom,
          ),
          itemCount: 50,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Verse line ${index + 1} — sample Bible text.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
        // ChapterBar
        Align(
          alignment:
          isSmall ? Alignment.bottomCenter : Alignment.topCenter,
          child: SafeArea(
            top: !isSmall,
            bottom: isSmall,
            child: const ChapterBar(barHeight: _chapterBarHeight),
          ),
        ),
      ],
    );
  }
}
