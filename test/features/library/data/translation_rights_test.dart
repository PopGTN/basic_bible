import 'package:basic_bible/src/features/library/data/bible_translation_catalog.dart';
import 'package:basic_bible/src/features/library/data/remote_translation_catalog_service.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('rightsFromCatalogJson', () {
    test('reads every rights field and resolves the notes path', () {
      final rights = rightsFromCatalogJson({
        'rightsStatus': 'public_domain',
        'allowDownload': true,
        'allowBundling': true,
        'license': 'Public Domain',
        'licenseUrl': 'https://ebible.org/publicdomain.htm',
        'copyrightNotice': ' Free to copy. ',
        'officialSourceUrl': 'https://ebible.org/Scriptures/',
        'licenseNotesPath': 'licenses/bibles/kjv.md',
      })!;

      expect(rights.isPublicDomain, isTrue);
      expect(rights.license, 'Public Domain');
      expect(rights.copyrightNotice, 'Free to copy.');
      expect(rights.sourceUrl, 'https://ebible.org/Scriptures/');
      expect(
        rights.notesUrl,
        'https://github.com/PopGTN/bible-data/blob/main/licenses/bibles/kjv.md',
      );
      expect(rights.allowDownload, isTrue);
      expect(rights.allowBundling, isTrue);
    });

    test('is null when the entry has no rights fields', () {
      expect(rightsFromCatalogJson({'id': 'x', 'name': 'X'}), isNull);
    });

    test('ignores malformed values instead of throwing', () {
      final rights = rightsFromCatalogJson({
        'license': 42,
        'copyrightNotice': {'text': 'x'},
        'officialSourceUrl': 'https://example.org/',
        'licenseNotesPath': '/licenses/bibles/x.md',
      })!;

      expect(rights.license, isEmpty);
      expect(rights.copyrightNotice, isEmpty);
      expect(rights.sourceUrl, 'https://example.org/');
      expect(
        rights.notesUrl,
        'https://github.com/PopGTN/bible-data/blob/main/licenses/bibles/x.md',
      );
    });

    test('a download ban alone is kept', () {
      final rights = rightsFromCatalogJson({'allowDownload': false})!;
      expect(rights.allowDownload, isFalse);
    });
  });

  group('merging', () {
    final builtIn = kBuiltInTranslations.firstWhere((t) => t.id == 'web');

    test('built-ins have offline rights', () {
      for (final t in kBuiltInTranslations) {
        expect(t.rights?.isPublicDomain, isTrue, reason: t.id);
      }
    });

    test('catalog rights override the built-in fallback', () {
      const remoteRights = BibleTranslationRights(license: 'Remote');
      final merged = mergeCatalogTranslation(
        builtIn: builtIn,
        remote: builtIn.copyWith(rights: remoteRights),
      );
      expect(merged.rights, remoteRights);
    });

    test('the built-in fallback survives a catalog entry without rights', () {
      final remote = BibleTranslation(
        id: 'web',
        name: 'World English Bible',
        language: 'en',
        description: '',
      );
      final merged = mergeCatalogTranslation(builtIn: builtIn, remote: remote);
      expect(merged.rights, builtIn.rights);
    });

    test('stored DB rows keep the base rights', () {
      final stored = builtIn.copyWith(isLocal: true);
      final merged = mergeStoredTranslation(
        base: builtIn,
        stored: BibleTranslation(
          id: stored.id,
          name: stored.name,
          language: stored.language,
          description: stored.description,
        ),
      );
      expect(merged.rights, builtIn.rights);
    });
  });
}
