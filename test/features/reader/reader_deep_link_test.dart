// Issue #40: links that open the reader at a chapter/verse.

import 'package:basic_bible/src/features/home/application/view_models/home_navigation_view_model.dart';
import 'package:basic_bible/src/features/home/application/view_models/reader_link_opener.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_session_view_models.dart';
import 'package:basic_bible/src/features/reader/models/reader_deep_link.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

ReaderDeepLink? _parse(String link) => ReaderDeepLink.tryParse(Uri.parse(link));

void main() {
  group('parsing', () {
    test('full custom-scheme link with verse and translation', () {
      expect(
        _parse('basicbible://bible/JHN/3/16?translation=KJV'),
        const ReaderDeepLink(
          reference: BibleReference(bookId: 'JHN', chapter: 3, verse: 16),
          translationId: 'kjv',
        ),
      );
    });

    test('path-only forms the OS or web hands to the router', () {
      const john3 = BibleReference(bookId: 'JHN', chapter: 3);
      expect(_parse('/bible/John/3')?.reference, john3);
      expect(_parse('/JHN/3')?.reference, john3);
      expect(_parse('/read/John/3')?.reference, john3);
      expect(
        _parse('/bible/JHN.3.16')?.reference,
        const BibleReference(bookId: 'JHN', chapter: 3, verse: 16),
      );
      expect(_parse('/bible/1%20Corinthians/13?t=web')?.translationId, 'web');
    });

    test('app routes and junk are not links', () {
      for (final route in [
        '/',
        '/home',
        '/home/notes',
        '/home/settings/advanced',
        '/login',
        '/coming-soon/audio',
        '/bible/Xyz/1',
        '/bible/John/zero',
        '/bible/John/0',
        '/bible/John/3/x',
      ]) {
        expect(_parse(route), isNull, reason: route);
      }
    });

    test('toUri round-trips', () {
      const link = ReaderDeepLink(
        reference: BibleReference(bookId: 'PSA', chapter: 23, verse: 1),
        translationId: 'web',
      );
      expect(link.toUri().toString(), 'basicbible://bible/PSA/23/1?translation=web');
      expect(ReaderDeepLink.tryParse(link.toUri()), link);
    });
  });

  group('opening', () {
    late ProviderContainer container;
    setUp(() async {
      SharedPreferences.setMockInitialValues({'bible_translation': 'kjv'});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          availableTranslationsProvider.overrideWith(
            (ref) async => const [
              BibleTranslation(
                id: 'kjv',
                name: 'KJV',
                language: 'en',
                description: '',
                isLocal: true,
              ),
              BibleTranslation(
                id: 'web',
                name: 'WEB',
                language: 'en',
                description: '',
                sourceType: BibleSourceType.download,
                isLocal: true,
              ),
              BibleTranslation(
                id: 'asv',
                name: 'ASV',
                language: 'en',
                description: '',
                sourceType: BibleSourceType.download,
              ), // not downloaded
            ],
          ),
          homeTabIndexProvider.overrideWith((ref) => 0),
        ],
      );
    });
    tearDown(() => container.dispose());

    test('switches translation, reference (with focus) and tab', () async {
      await container
          .read(readerLinkOpenerProvider)
          .open(_parse('basicbible://bible/JHN/3/16?translation=web')!);

      expect(container.read(currentTranslationProvider), 'web');
      const john316 = BibleReference(bookId: 'JHN', chapter: 3, verse: 16);
      expect(container.read(currentReferenceProvider), john316);
      expect(
        container
            .read(currentReferenceProvider.notifier)
            .takeVerseFocusRequest(john316),
        isTrue,
      );
      expect(container.read(homeTabIndexProvider), 1);
    });

    test('a translation that is not installed keeps the current one', () async {
      await container
          .read(readerLinkOpenerProvider)
          .open(_parse('/bible/PSA/23?t=asv')!);
      expect(container.read(currentTranslationProvider), 'kjv');
      expect(
        container.read(currentReferenceProvider),
        const BibleReference(bookId: 'PSA', chapter: 23),
      );
    });
  });
}
