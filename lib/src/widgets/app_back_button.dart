import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.fallbackRoute = '/home'});

  final String fallbackRoute;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Back',
      onPressed: () {
        if (context.canPop()) {
          context.pop();
          return;
        }

        // Some placeholder/settings routes are opened with direct navigation
        // rather than a push stack. Fall back to the main home flow so the
        // user always has a predictable exit path.
        context.go(fallbackRoute);
      },
    );
  }
}
