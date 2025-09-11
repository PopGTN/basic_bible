import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChapterBar extends StatelessWidget {
  const ChapterBar({
    super.key,
    required double barHeight,
  }) : _barHeight = barHeight;

  final double _barHeight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: _barHeight,
      color: colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          // Previous chapter button (compact)
          FilledButton.tonal(
            onPressed: () => print("Previous chapter"),
            style: FilledButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              minimumSize: const Size(48, 48),
              padding: EdgeInsets.zero,
            ),
            child: const Icon(Icons.arrow_back),
          ),

          // Middle chapter button (expanded)
          Expanded(
            child: FilledButton.tonal(
              onPressed: ()  {
                print("Select chapter");
                GoRouter.of(context).go('/home/reference');
              },
              style: FilledButton.styleFrom(
                shape: const RoundedRectangleBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: const Size(0, 48), // height fixed, width flexible
              ),
              child: const Text(
                "Genesis 1",
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Next chapter button (compact)
          FilledButton.tonal(
            onPressed: () => print("Next chapter"),
            style: FilledButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              minimumSize: const Size(48, 48),
              padding: EdgeInsets.zero,
            ),
            child: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
