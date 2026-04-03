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
import 'features/settings/application/app_preferences_provider.dart';
import 'views/other_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'views/placeholder/coming_soon_screen.dart';

// Providers
import 'features/auth/application/auth_provider.dart';
import 'providers/theme_provider.dart' hide themeDataMap;
import 'providers/language_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext contexht, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);
    final requireDummyLogin = ref.watch(requireDummyLoginProvider);
    final appTheme = ref.watch(themeProvider);
    final localelang = ref.watch(languageProvider);

    final router = GoRouter(
      initialLocation: requireDummyLogin && !isLoggedIn ? '/login' : '/home',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => requireDummyLogin && !isLoggedIn
              ? const LoginScreen()
              : const HomeScreen(),
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
            ),
            GoRoute(
              path: 'notes',
              builder: (context, state) => const NotesScreen(),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final loggedIn = ref.read(authProvider);
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

    return MaterialApp.router(
      title: 'The Basic Bible App',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
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
