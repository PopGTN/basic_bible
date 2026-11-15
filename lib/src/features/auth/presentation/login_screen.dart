import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/auth/application/view_models/auth_view_model.dart';
import 'package:basic_bible/src/features/sync/application/view_models/sync_view_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(googleAuthServiceProvider);
    final sync = ref.watch(syncControllerProvider);
    final canUseGoogle = auth.isSupported && auth.isConfigured;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.login)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canUseGoogle) ...[
              FilledButton.icon(
                icon: const Icon(Icons.cloud_outlined),
                label: const Text('Sign in with Google'),
                onPressed: sync.isSyncing
                    ? null
                    : () async {
                        final controller = ref.read(
                          syncControllerProvider.notifier,
                        );
                        final authController = ref.read(authProvider.notifier);
                        await controller.signIn();
                        if (!context.mounted) return;
                        // Only pass the login gate on success; errors stay
                        // visible on this screen.
                        if (ref.read(syncControllerProvider).isSignedIn) {
                          await authController.login();
                        }
                      },
              ),
              const SizedBox(height: 12),
              if (sync.phase == SyncPhase.error && sync.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    sync.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
            // Original local-only entry, kept as the no-account path.
            ElevatedButton(
              onPressed: () async {
                final authController = ref.read(authProvider.notifier);
                await authController.login();
                if (!context.mounted) return;
              },
              child: Text(AppLocalizations.of(context)!.login),
            ),
          ],
        ),
      ),
    );
  }
}
