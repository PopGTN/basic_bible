import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:basic_bible/l10n/app_localizations.dart';

// Screens
import 'views/login/login_screen.dart';
import 'views/home/home_screen.dart';
import 'views/other_screen.dart';
import 'views/settings/settings_screen.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart' hide themeDataMap;
import 'providers/language_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext contexht, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);
    final appTheme = ref.watch(themeProvider);
    final localelang = ref.watch(languageProvider);


    final router = GoRouter(
      initialLocation: isLoggedIn ? '/home' : '/login',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              isLoggedIn ? HomeScreen() : LoginScreen(),
        ),
        GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
        GoRoute(
          path: '/home',
          builder: (context, state) => HomeScreen(),
          routes: [
            GoRoute(path: 'other', builder: (context, state) => OtherScreen()),
            GoRoute(
              path: 'settings',
              builder: (context, state) => SettingsScreen(),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final loggedIn = ref.read(authProvider);
        final goingToLogin = state.uri.toString() == '/login';

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
      darkTheme: appTheme == AppThemeMode.dark
          ? getThemeData(AppThemeMode.dark)
          : ThemeData.dark(),
      themeMode: mapThemeMode(appTheme),
    );
  }
  
}
