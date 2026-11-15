import 'package:basic_bible/src/features/annotations/application/view_models/annotation_data_view_models.dart';
import 'package:basic_bible/src/features/auth/application/view_models/auth_view_model.dart';
import 'package:basic_bible/src/features/settings/application/view_models/theme_view_model.dart';
import 'package:basic_bible/src/features/sync/application/view_models/sync_view_models.dart';
import 'package:basic_bible/src/features/sync/data/google_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'theme interpolation remains stable with button and input text styles',
    () {
      final lightTheme = getThemeData(AppThemeMode.light);
      final darkTheme = getThemeData(AppThemeMode.black);

      expect(() => ThemeData.lerp(lightTheme, darkTheme, 0.5), returnsNormally);
    },
  );

  test('startup auth treats a restored Google session as authenticated', () {
    final syncState = const SyncState(
      account: GoogleAccount(email: 'user@example.com'),
    );

    expect(
      isAppAuthenticated(localLoggedIn: false, syncState: syncState),
      isTrue,
    );
  });

  testWidgets('switching themes does not throw with TextButton text styles', (
    tester,
  ) async {
    final lightTheme = getThemeData(AppThemeMode.light);
    final darkTheme = getThemeData(AppThemeMode.black);

    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: AnimatedTheme(
          data: lightTheme,
          duration: const Duration(milliseconds: 200),
          child: const Scaffold(
            body: Center(
              child: TextButton(onPressed: null, child: Text('Sign out')),
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: darkTheme,
        home: AnimatedTheme(
          data: darkTheme,
          duration: const Duration(milliseconds: 200),
          child: const Scaffold(
            body: Center(
              child: TextButton(onPressed: null, child: Text('Sign out')),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });

  testWidgets('empty annotation streams keep the notes sheet open', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userAnnotationsProvider.overrideWith((_) => Stream.value(const [])),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return FilledButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      builder: (sheetContext) {
                        return Consumer(
                          builder: (context, ref, child) {
                            final annotations =
                                ref.watch(userAnnotationsProvider).value ??
                                const [];
                            return SafeArea(
                              child: DraggableScrollableSheet(
                                expand: false,
                                initialChildSize: 0.5,
                                minChildSize: 0.18,
                                maxChildSize: 0.96,
                                builder: (context, controller) {
                                  return ListView(
                                    controller: controller,
                                    children: [
                                      const Text('Saved Annotations'),
                                      if (annotations.isEmpty)
                                        const Text('No notes yet'),
                                    ],
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  child: const Text('Open notes'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open notes'));
    await tester.pumpAndSettle();

    expect(find.text('Saved Annotations'), findsOneWidget);
    expect(find.text('No notes yet'), findsOneWidget);
  });
}
