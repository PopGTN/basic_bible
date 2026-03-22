import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).go('/home/other');
            },
            child: const Text('Go to Other Page'),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.secondaryContainer,
              foregroundColor: colors.onSecondaryContainer,
            ),
            onPressed: () => context.go('/home/settings'),
            icon: const Icon(Icons.settings),
            label: const Text('Open Settings'),
            iconAlignment: IconAlignment.start,
          ),
        ],
      ),
    );
  }
}
