import 'package:flutter/material.dart';

class ChapterBar extends StatelessWidget {
  const ChapterBar({
    super.key,
    required double barHeight,
  }) : _barHeight = barHeight;

  final double _barHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _barHeight,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => print("Previous chapter"),
          ),
          Expanded(
            child: TextButton(
              onPressed: () {
                // TODO: open reference picker
              },
              child: const Text("Genesis 1"),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => print("Next chapter"),
          ),
        ],
      ),
    );
  }
}