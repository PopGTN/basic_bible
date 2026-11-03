import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:basic_bible/l10n/app_localizations.dart';

// Screens
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/library/presentation/versions_screen.dart';
import 'features/annotations/presentation/notes_screen.dart';
import 'features/settings/application/view_models/app_launch_preferences_view_models.dart';
import 'views/placeholder/other_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/settings/presentation/advanced_settings_screen.dart';
import 'views/placeholder/coming_soon_screen.dart';

// Providers
import 'features/auth/application/view_models/auth_view_model.dart';
import 'features/settings/application/view_models/theme_view_model.dart'
    hide themeDataMap;
import 'features/settings/application/view_models/language_view_model.dart';
import 'features/sync/application/view_models/sync_view_models.dart';
import 'services/app_database.dart';
import 'services/shared_preferences_provider.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _routerRefresh = _RouterRefreshNotifier();
  late final GoRouter _router;
  late final AppLifecycleListener _appLifecycleListener;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool? _hadNetwork;

  static const _retentionLastRunKey = 'notesRetentionLastRunAt';
  static const _retentionInterval = Duration(hours: 24);

  /// Purges old tombstones at most once a day. Runs on startup/resume only —
  /// a timer would be pointless (suspended apps don't tick) and wasteful.
  Future<void> _runRetentionCleanupIfDue() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final lastRaw = prefs.getString(_retentionLastRunKey);
      final last = lastRaw == null ? null : DateTime.tryParse(lastRaw);
      final now = DateTime.now();
      if (last != null && now.difference(last) < _retentionInterval) return;
      await prefs.setString(_retentionLastRunKey, now.toIso8601String());
      await ref.read(appDatabaseProvider).runLocalRetentionCleanup();
    } catch (_) {
      // Local cleanup is best-effort; it should never block the app.
    }
  }

  void _scheduleAutoSync() {
    if (ref.read(syncModeProvider) == SyncMode.manual) return;
    if (!ref.read(syncControllerProvider).isSignedIn) return;
    // Throttling/backoff is applied by SyncController.requestAutoSync.
    ref.read(autoSyncSchedulerProvider).schedule();
  }

  /// Only listens while the app is in the foreground, and only reacts to an
  /// offline → online transition (not Wi-Fi ↔ cellular handoffs, and not the
  /// initial status some platforms emit on subscribe).
  void _startConnectivityListener() {
    if (_connectivitySubscription != null) return;
    _hadNetwork = null;
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      final hasNetwork = results.any((r) => r != ConnectivityResult.none);
      final restored = _hadNetwork == false && hasNetwork;
      _hadNetwork = hasNetwork;
      if (restored) _scheduleAutoSync();
    });
  }

  void _stopConnectivityListener() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  @override
  void initState() {
    super.initState();
    _startConnectivityListener();
    _appLifecycleListener = AppLifecycleListener(
      onResume: () {
        _startConnectivityListener();
        _runRetentionCleanupIfDue();
        _scheduleAutoSync();
      },
      onHide: _stopConnectivityListener,
    );
    // Keep the redirect logic reactive to auth/login-requirement changes via
    // refreshListenable instead of rebuilding the whole GoRouter on every
    // MyApp rebuild. A previous version built GoRouter inline in build(),
    // which discarded the entire navigation stack back to initialLocation on
    // *any* watched-provider change — including a harmless theme or language
    // switch while sitting on, say, the Settings screen.
    ref.listenManual(authProvider, (_, _) => _routerRefresh.refresh());
    ref.listenManual(
      requireDummyLoginProvider,
      (_, _) => _routerRefresh.refresh(),
    );
    // Only sign-in changes affect routing; sync phase changes must not
    // re-run redirects on every sync.
    ref.listenManual(
      syncControllerProvider.select((s) => s.isSignedIn),
      (_, _) => _routerRefresh.refresh(),
    );

    final isLoggedIn = isAppAuthenticated(
      localLoggedIn: ref.read(authProvider),
      syncState: ref.read(syncControllerProvider),
    );
    final requireDummyLogin = ref.read(requireDummyLoginProvider);

    _router = GoRouter(
      initialLocation: requireDummyLogin && !isLoggedIn ? '/login' : '/home',
      refreshListenable: _routerRefresh,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            final isLoggedIn = isAppAuthenticated(
              localLoggedIn: ref.read(authProvider),
              syncState: ref.read(syncControllerProvider),
            );
            return ref.read(requireDummyLoginProvider) && !isLoggedIn
                ? const LoginScreen()
                : const HomeScreen();
          },
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/coming-soon/:feature',
          builder: (context, state) => ComingSoonScreen(
            featureKey: state.pathParameters['feature'] ?? 'feature',
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(path: 'other', builder: (context, state) => OtherScreen()),
            GoRoute(
              path: 'translations',
              builder: (context, state) => const VersionsScreen(),
            ),
            GoRoute(
              path: 'settings',
              builder: (context, state) => SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'advanced',
                  builder: (context, state) => const AdvancedSettingsScreen(),
                ),
              ],
            ),
            GoRoute(
              path: 'notes',
              builder: (context, state) => const NotesScreen(),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final loggedIn = isAppAuthenticated(
          localLoggedIn: ref.read(authProvider),
          syncState: ref.read(syncControllerProvider),
        );
        final requireLogin = ref.read(requireDummyLoginProvider);
        final goingToLogin = state.uri.toString() == '/login';

        if (!requireLogin) {
          if (goingToLogin) return '/home';
          return null;
        }

        if (!loggedIn && !goingToLogin) return '/login';
        if (loggedIn && goingToLogin) return '/home';
        return null;
      },
    );
    Future.microtask(_runRetentionCleanupIfDue);
  }

  @override
  void dispose() {
    _stopConnectivityListener();
    _appLifecycleListener.dispose();
    _routerRefresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = ref.watch(themeProvider);
    final localelang = ref.watch(languageProvider);

    return MaterialApp.router(
      title: 'The Basic Bible App',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      //Languages
      locale: Locale(localelang),

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      theme: getThemeData(appTheme),
      darkTheme: getDarkThemeData(appTheme),
      themeMode: mapThemeMode(appTheme),
    );
  }
}

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
