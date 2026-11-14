// Regression coverage for issue #91: a translation download that finished
// after the Versions screen was closed never switched the reader to it or
// refreshed the translation list, because the follow-up work lived in the
// widget and bailed out on `!context.mounted`. TranslationActions now owns
// that work, so these tests drive it with no widget at all.

import 'dart:async';

import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_session_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/translation_actions_view_model.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeBooksNotifier extends StateNotifier<AsyncValue<List<BibleBook>>>
    implements BibleBooksNotifier {
  _FakeBooksNotifier() : super(const AsyncValue.data([]));

  Completer<void> download = Completer<void>();
  final downloadedIds = <String>[];
  DownloadProgressCallback? lastProgress;

  @override
  Future<void> downloadTranslation(
    String translationId, {
    DownloadProgressCallback? onProgress,
  }) {
    downloadedIds.add(translationId);
    lastProgress = onProgress;
    return download.future;
  }

  @override
  Future<void> changeTranslation(String translationId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _translation = BibleTranslation(
  id: 'web',
  name: 'World English Bible',
  language: 'en',
  description: '',
);

void main() {
  late ProviderContainer container;
  late _FakeBooksNotifier books;
  late int translationListLoads;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'bible_translation': 'kjv'});
    final prefs = await SharedPreferences.getInstance();
    books = _FakeBooksNotifier();
    translationListLoads = 0;
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        bibleBooksProvider.overrideWith((ref) => books),
        availableTranslationsProvider.overrideWith((ref) async {
          translationListLoads++;
          return const <BibleTranslation>[];
        }),
      ],
    );
    // Keep the list provider alive so invalidation triggers a reload we can
    // count, just like the Versions screen watching it.
    container.listen(availableTranslationsProvider, (_, _) {});
    await container.read(availableTranslationsProvider.future);
  });

  tearDown(() => container.dispose());

  test('finishing a download switches translation and refreshes the list '
      'with no screen attached', () async {
    final actions = container.read(translationActionsProvider);

    final pending = actions.download(_translation);
    expect(container.read(translationDownloadsProvider).keys, ['web']);
    expect(
      container.read(translationDownloadsProvider)['web']!.name,
      'World English Bible',
    );

    books.download.complete();
    expect(await pending, isTrue);

    expect(container.read(currentTranslationProvider), 'web');
    expect(container.read(translationDownloadsProvider), isEmpty);
    await container.read(availableTranslationsProvider.future);
    expect(translationListLoads, 2);
  });

  test('a second tap while downloading is ignored', () async {
    final actions = container.read(translationActionsProvider);

    final first = actions.download(_translation);
    expect(await actions.download(_translation), isFalse);
    expect(books.downloadedIds, ['web']);

    books.download.complete();
    expect(await first, isTrue);
  });

  test('a failed download clears the spinner, keeps the current translation '
      'and reports the error', () async {
    final actions = container.read(translationActionsProvider);

    final pending = actions.download(_translation);
    books.download.completeError(Exception('offline'));

    await expectLater(pending, throwsException);
    expect(container.read(currentTranslationProvider), 'kjv');
    expect(container.read(translationDownloadsProvider), isEmpty);

    // A retry is allowed once the first attempt has failed.
    books.download = Completer<void>()..complete();
    expect(await actions.download(_translation), isTrue);
  });

  test('download progress is reported, coalesced, then indeterminate '
      'while installing (#55)', () async {
    final actions = container.read(translationActionsProvider);
    final pending = actions.download(_translation);
    final notify = books.lastProgress!;
    double? fraction() =>
        container.read(translationDownloadsProvider)['web']?.fraction;

    var updates = 0;
    container.listen(translationDownloadsProvider, (_, _) => updates++);

    notify(0, 1000);
    expect(fraction(), 0);
    notify(4, 1000); // still 0%: no rebuild
    notify(5, 1000);
    expect(updates, 1);
    notify(500, 1000);
    expect(fraction(), 0.5);
    notify(1000, 1000); // all bytes in -> installing (indeterminate)
    expect(fraction(), isNull);
    expect(container.read(translationDownloadsProvider), contains('web'));

    books.download.complete();
    await pending;
    expect(container.read(translationDownloadsProvider), isEmpty);
  });

  test('unknown size stays indeterminate', () async {
    final actions = container.read(translationActionsProvider);
    final pending = actions.download(_translation);
    books.lastProgress!(12345, null);
    expect(container.read(translationDownloadsProvider)['web']!.fraction, isNull);
    books.download.complete();
    await pending;
  });
}
