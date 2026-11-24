// Removing a translation moves every reader showing it (the main reader and
// the split-view pane, #84) to the next translation on the device, and the
// last one on the device can't be removed.

import 'package:basic_bible/src/features/reader/application/view_models/reader_session_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/split_view_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/translation_actions_view_model.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

BibleTranslation _translation(
  String id,
  BibleSourceType sourceType, {
  bool isLocal = true,
}) => BibleTranslation(
  id: id,
  name: id.toUpperCase(),
  language: 'en',
  description: '',
  isLocal: isLocal,
  sourceType: sourceType,
);

void main() {
  group('localFallbackTranslation', () {
    final kjv = _translation('kjv', BibleSourceType.asset);
    final web = _translation('web', BibleSourceType.download);
    final remote = _translation(
      'asv',
      BibleSourceType.download,
      isLocal: false,
    );
    final session = _translation('bbe', BibleSourceType.session);
    final imported = _translation('mine', BibleSourceType.import);

    test('picks the next translation on the device after the removed one', () {
      expect(
        localFallbackTranslation([
          kjv,
          web,
          remote,
          session,
          imported,
        ], 'web')?.id,
        'mine',
      );
    });

    test('wraps round to the start of the list', () {
      expect(localFallbackTranslation([kjv, web, imported], 'mine')?.id, 'kjv');
    });

    test('never picks one that is only downloadable or session-only', () {
      expect(
        localFallbackTranslation([web, remote, session, kjv], 'web')?.id,
        'kjv',
      );
    });

    test('is null for the last translation on the device', () {
      expect(localFallbackTranslation([web, remote, session], 'web'), isNull);
    });
  });

  group('ReaderTranslationFallback', () {
    Future<ProviderContainer> root(Map<String, Object> prefs) async {
      SharedPreferences.setMockInitialValues({
        'bible_book': 'GEN',
        'bible_chapter': 1,
        ...prefs,
      });
      final sp = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(sp)],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('moves both readers off the removed translation', () async {
      final main = await root({'bible_translation': 'web'});
      final pane = main.read(splitPaneContainerProvider);
      expect(pane.read(currentTranslationProvider), 'web');

      await main
          .read(readerTranslationFallbackProvider)
          .moveReadersOff((id) => id == 'web', 'kjv');

      expect(main.read(currentTranslationProvider), 'kjv');
      expect(pane.read(currentTranslationProvider), 'kjv');
    });

    test('works from the pane too, and leaves other readers alone', () async {
      final main = await root({
        'bible_translation': 'kjv',
        'split_view_translation': 'web',
      });
      final pane = main.read(splitPaneContainerProvider);

      await pane
          .read(readerTranslationFallbackProvider)
          .moveReadersOff((id) => id == 'web', 'asv');

      expect(main.read(currentTranslationProvider), 'kjv');
      expect(pane.read(currentTranslationProvider), 'asv');
    });

    test(
      'updates the pane saved for later if split view never opened',
      () async {
        final main = await root({
          'bible_translation': 'kjv',
          'split_view_translation': 'web',
        });

        await main
            .read(readerTranslationFallbackProvider)
            .moveReadersOff((id) => id == 'web', 'kjv');

        expect(main.exists(splitPaneContainerProvider), isFalse);
        expect(
          main
              .read(sharedPreferencesProvider)
              .getString('split_view_translation'),
          'kjv',
        );
        expect(
          main
              .read(splitPaneContainerProvider)
              .read(currentTranslationProvider),
          'kjv',
        );
      },
    );
  });
}
