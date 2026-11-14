// The full-Bible notifier is only a command object for the reader; it must
// not load every verse just because something read its `.notifier` or the
// translation changed (that cost ~1.2 s and the whole text in memory).

import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_books_notifier.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Has no data layer: any attempt to load fails loudly.
class _NoDataRepository implements AppBibleRepository {
  final peeked = <String>[];

  @override
  List<BibleBook>? peekLoadedTranslation(String translationId) {
    peeked.add(translationId);
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('creating the notifier and switching translations loads nothing',
      () async {
    final repository = _NoDataRepository();
    final notifier = BibleBooksNotifier(
      repository,
      'kjv',
      onResolvedTranslationChanged: (_, {persist = true}) async {},
    );
    addTearDown(notifier.dispose);

    await notifier.changeTranslation('web');
    await Future<void>.delayed(Duration.zero);

    // A load would have thrown inside the fake and surfaced as an error.
    expect(notifier.debugState, isA<AsyncLoading<List<BibleBook>>>());
    expect(repository.peeked, ['kjv', 'web']);
  });
}
