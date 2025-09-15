import 'package:basic_bible/src/views/home/tabs/bibleViewerTab/widgets/ReferenceBar.dart';
import 'package:flutter/material.dart';
import 'package:basic_bible/src/providers/bible_provider.dart';
import 'widgets/ReferenceBar.dart';

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
  //TODO: Make The Text Size Changeable through Settings
  double _fontSize = 16.0;

  double? _lastScroll;
  bool _isHiding = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final current = _scrollController.position.pixels;
    final max = _scrollController.position.maxScrollExtent;
    final delta = current - (_lastScroll ?? current);
    _lastScroll = current;

    if (delta.abs() < 1) return;

    // Always show bars when at the bottom
    if (current >= max) {
      if (_isHiding) _toggleBars(show: true);
      return;
    }

    if (delta > 0 && !_isHiding) {
      _toggleBars(show: false); // scrolling down → hide
    } else if (delta < 0 && _isHiding) {
      _toggleBars(show: true); // scrolling up → show
    }
  }

  void _toggleBars({required bool show}) {
    if (show) {
      widget.showBottomNav();
      if (widget.isSmallDevice) widget.showAppBar();
    } else {
      widget.hideBottomNav();
      if (widget.isSmallDevice) widget.hideAppBar();
    }
    _isHiding = !show;
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = widget.isSmallDevice;
    final bottomPadding = _bottomNavHeight + _chapterBarHeight;
    final booksAsync = ref.watch(bibleBooksProvider);
    final currentReference = ref.watch(currentReferenceProvider);
    final chapterAsync = ref.watch(currentChapterProvider);


    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            16,
            isSmall ? 16 : _chapterBarHeight + 16,
            16,
            bottomPadding,
          ),
          itemCount: 100,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Verse line ${i + 1} — sample Bible text.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
        Align(
          alignment: isSmall ? Alignment.bottomCenter : Alignment.topCenter,
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


