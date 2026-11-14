// Guards the bug where MyApp built a brand-new GoRouter inline in build()
// (lib/src/app.dart). Since GoRouter always starts at initialLocation, any
// rebuild triggered by a watched provider — including something as
// unrelated as switching the app theme — silently reset the entire
// navigation stack back to the home route. This replicates the same shape
// (a ConsumerStatefulWidget building GoRouter once in initState, wired to a
// refreshListenable for the providers that should actually drive redirects)
// and checks that an unrelated provider change leaves the current route
// alone, while a "relevant" provider change still redirects correctly.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final _loggedInProvider = StateProvider<bool>((ref) => false);
final _unrelatedProvider = StateProvider<int>((ref) => 0);

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

class _App extends ConsumerStatefulWidget {
  const _App();

  @override
  ConsumerState<_App> createState() => _AppState();
}

class _AppState extends ConsumerState<_App> {
  final _refresh = _RouterRefreshNotifier();
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    ref.listenManual(_loggedInProvider, (_, _) => _refresh.refresh());

    _router = GoRouter(
      initialLocation: '/home',
      refreshListenable: _refresh,
      routes: [
        GoRoute(path: '/login', builder: (_, _) => const Text('Login')),
        GoRoute(
          path: '/home',
          builder: (_, _) => const Text('Home'),
          routes: [
            GoRoute(
              path: 'settings',
              builder: (_, _) => const Text('Settings'),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final loggedIn = ref.read(_loggedInProvider);
        final goingToLogin = state.uri.toString() == '/login';
        if (!loggedIn && !goingToLogin) return '/login';
        if (loggedIn && goingToLogin) return '/home';
        return null;
      },
    );
  }

  @override
  void dispose() {
    _refresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watching an unrelated provider here is the point: this must not force
    // GoRouter itself to be reconstructed on every value change.
    ref.watch(_unrelatedProvider);
    return MaterialApp.router(routerConfig: _router);
  }
}

void main() {
  testWidgets(
    'an unrelated provider change does not reset the navigation stack',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(_loggedInProvider.notifier).state = true;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _App(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);

      // Navigate to a nested route.
      final context = tester.element(find.text('Home'));
      GoRouter.of(context).go('/home/settings');
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);

      // Bump the unrelated provider — mirrors switching the app theme.
      container.read(_unrelatedProvider.notifier).state++;
      await tester.pumpAndSettle();

      expect(
        find.text('Settings'),
        findsOneWidget,
        reason: 'an unrelated provider change must not reset the route',
      );
    },
  );

  testWidgets(
    'a relevant provider change (logged out) still redirects via refreshListenable',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(_loggedInProvider.notifier).state = true;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _App(),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.text('Home'));
      GoRouter.of(context).go('/home/settings');
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);

      // Logging out without ever recreating GoRouter should still redirect,
      // because listenManual notifies refreshListenable.
      container.read(_loggedInProvider.notifier).state = false;
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    },
  );
}
