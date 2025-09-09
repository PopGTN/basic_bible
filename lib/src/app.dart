import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/other_screen.dart';
import 'screens/settings_screen.dart';

import 'common/providers/auth_provider.dart';
import 'common/providers/theme_provider.dart' hide themeDataMap;

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);
    final appTheme = ref.watch(themeProvider);

    final router = GoRouter(
      initialLocation: isLoggedIn ? '/home' : '/login',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              isLoggedIn ? const HomeScreen() : const LoginScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'other',
              builder: (context, state) => const OtherScreen(),
            ),
            GoRoute(
              path: 'settings',
              builder: (context, state) => const SettingsScreen(),
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

    // return MaterialApp.router(
    //   debugShowCheckedModeBanner: false,
    //   routerConfig: router,
    //   title: 'Flutter GoRouter & Riverpod Demo',
    //   theme: themeDataMap[appTheme], // Apply selected theme
    // );
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'Flutter GoRouter & Riverpod Demo',
      theme: getThemeData(appTheme),
      darkTheme: appTheme == AppThemeMode.dark
          ? getThemeData(AppThemeMode.dark)
          : ThemeData.dark(), // fallback for system dark
      themeMode: mapThemeMode(appTheme),
    );
  }
}
