import 'package:basic_bible/src/common/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('This is the about page'),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => context.go('/'),
            child: const Text('Back to Home'),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => context.go('/home/settings'),
            icon: const Icon(Icons.settings),
            label: const Text('Settings'),
            iconAlignment: IconAlignment.start,
          ),
          const SizedBox(height: 20),
          // Logout button wrapped with Consumer to access Riverpod
          Consumer(
            builder: (context, ref, child) {
              return ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Log the user out
                  ref.read(authProvider.notifier).logout();
                  // Navigate to login page
                  context.go('/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                iconAlignment: IconAlignment.start,
              );
            },
          ),
        ],
      ),
    );
  }
}
