import 'package:basic_bible/src/views/home/tabs/widgets/ReferenceBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

/// Tab that displays the Bible text with:
/// - Scrollable Bible content
/// - ChapterBar that hides on scroll down and reappears on scroll up / bottom
class BibleViewerTab extends StatefulWidget {
  const BibleViewerTab({super.key});

  @override
  State<BibleViewerTab> createState() => _BibleViewerTabState();
}

class _BibleViewerTabState extends State<BibleViewerTab> {
  final ScrollController _scrollController = ScrollController();
  bool _showChapterBar = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final direction = _scrollController.position.userScrollDirection;

    if (direction == ScrollDirection.reverse && _showChapterBar) {
      // Scrolling down → hide bar
      setState(() => _showChapterBar = false);
    } else if (direction == ScrollDirection.forward && !_showChapterBar) {
      // Scrolling up → show bar
      setState(() => _showChapterBar = true);
    } else if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      // Reached bottom → ensure bar is visible
      if (!_showChapterBar) {
        setState(() => _showChapterBar = true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Bible text content (scrollable)
          _BibleTextView(controller: _scrollController),

          // ChapterBar pinned to bottom with hide/show animation
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              offset: _showChapterBar ? Offset.zero : const Offset(0, 1),
              child: SafeArea(
                top: false,
                child: const ChapterBar(barHeight: 56),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example Bible text content with scroll
class _BibleTextView extends StatelessWidget {
  const _BibleTextView({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: 50, // Example: 50 verses
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "Verse line ${index + 1} — sample Bible text.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      },
    );
  }
}
