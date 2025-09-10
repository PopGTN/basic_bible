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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              '''This is a bible that I PopGTN has created for free use. Its a practice project for learning Flutter & Dart. This project will be used to take the things i learn and make an open source drawing bible app. Like Pencil bible but with more features and better ui. This app will hopefully have the ability to read the bible, take notes, have TTS support and more.work as nice as the YouVersion Bible app.''',
            ),
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
