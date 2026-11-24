import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/hymns/data/content_reporting.dart';
import 'package:basic_bible/src/features/hymns/presentation/report_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('email reports are pre-filled with %20-encoded subject and body', () {
    final uri = buildContentReportUri(
      'mailto:$kAppTakedownEmail',
      subject: 'Copyright concern: My Book',
      body: 'Line one\nLine two',
    )!;
    expect(uri.scheme, 'mailto');
    expect(uri.path, 'contact@joshuamc.ca');
    expect(
      uri.toString(),
      contains('subject=Copyright%20concern%3A%20My%20Book'),
    );
    expect(uri.toString(), contains('body=Line%20one%0ALine%20two'));
    expect(uri.toString(), isNot(contains('+')));
  });

  test('GitHub reports pre-fill the issue title and body', () {
    final uri = buildContentReportUri(
      kAppTakedownContact,
      subject: 'Takedown request',
      body: 'x',
    )!;
    expect(uri.host, 'github.com');
    expect(uri.queryParameters['template'], 'takedown.md');
    expect(uri.queryParameters['title'], 'Takedown request');
  });

  test('placeholder or unusable contacts give no link', () {
    expect(buildContentReportUri('TODO_X', subject: 's', body: 'b'), isNull);
    expect(buildContentReportUri('ftp://x', subject: 's', body: 'b'), isNull);
    expect(
      buildContentReportUri(
        'owner@example.org',
        subject: 's',
        body: 'b',
      )!.scheme,
      'mailto',
    );
  });

  testWidgets('the report button offers email and GitHub', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  sendContentReport(context, subject: 's', body: 'b'),
              child: const Text('report'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('report'));
    await tester.pumpAndSettle();
    expect(find.text('Email contact@joshuamc.ca'), findsOneWidget);
    expect(find.text('Private. Opens your email app.'), findsOneWidget);
    expect(find.text('Open a GitHub issue'), findsOneWidget);
    expect(
      find.text('Public: anyone can read it. Needs a GitHub account.'),
      findsOneWidget,
    );
  });
}
