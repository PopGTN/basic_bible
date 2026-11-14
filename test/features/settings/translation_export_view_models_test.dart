// Issue #64: the Advanced-settings export list showed every known
// translation, including catalog entries that were never downloaded.

import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/settings/application/view_models/translation_export_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements AppBibleRepository {
  _FakeRepository(this.cachedIds);

  final Set<String> cachedIds;
  final checkedIds = <String>[];

  @override
  Future<bool> isCached(String translationId) async {
    checkedIds.add(translationId);
    return cachedIds.contains(translationId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

BibleTranslation _t(String id, BibleSourceType source, {bool local = false}) =>
    BibleTranslation(
      id: id,
      name: id.toUpperCase(),
      language: 'en',
      description: '',
      sourceType: source,
      isLocal: local,
    );

void main() {
  test('only translations with a database on the device are exportable', () async {
    final repository = _FakeRepository({'kjv', 'web', 'mine'});
    final container = ProviderContainer(
      overrides: [
        bibleRepositoryProvider.overrideWithValue(repository),
        availableTranslationsProvider.overrideWith(
          (ref) async => [
            _t('kjv', BibleSourceType.asset),
            _t('web', BibleSourceType.download, local: true),
            _t('asv', BibleSourceType.download), // catalog only
            _t('bsb', BibleSourceType.session), // opened, never saved
            _t('mine', BibleSourceType.import),
          ],
        ),
      ],
    );
    addTearDown(container.dispose);

    final exportable = await container.read(
      exportableTranslationsProvider.future,
    );

    expect(exportable.map((t) => t.id), ['kjv', 'web', 'mine']);
    // Catalog-only entries are filtered without touching the disk.
    expect(repository.checkedIds, isNot(contains('asv')));
  });
}
