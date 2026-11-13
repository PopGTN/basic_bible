// Issue #22: the reader re-emphasised the last navigated-to verse every time
// the Bible tab was rebuilt (tab return, restart) because it inferred focus
// from the persisted reference. Focus is now a one-shot navigation request.

import 'package:basic_bible/src/features/reader/application/view_models/reader_session_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _john316 = BibleReference(bookId: 'JHN', chapter: 3, verse: 16);

Future<ReferenceNotifier> _notifier([Map<String, Object> saved = const {}]) async {
  SharedPreferences.setMockInitialValues(saved);
  return ReferenceNotifier(await SharedPreferences.getInstance());
}

void main() {
  test('a verse restored from preferences is never re-emphasised', () async {
    final notifier = await _notifier({
      'bible_book': 'JHN',
      'bible_chapter': 3,
      'bible_verse': 16,
    });
    expect(notifier.state, _john316);
    expect(notifier.takeVerseFocusRequest(_john316), isFalse);
  });

  test('navigating to a verse is emphasised exactly once', () async {
    final notifier = await _notifier();
    await notifier.setReference(_john316);

    expect(notifier.takeVerseFocusRequest(_john316), isTrue);
    // Rebuilding the reader later (tab return) finds nothing pending.
    expect(notifier.takeVerseFocusRequest(_john316), isFalse);
  });

  test('re-anchoring updates do not request focus', () async {
    final notifier = await _notifier();
    await notifier.setReference(_john316, focusVerse: false);
    expect(notifier.takeVerseFocusRequest(_john316), isFalse);
  });

  test('a later navigation replaces an unconsumed request', () async {
    final notifier = await _notifier();
    await notifier.setReference(_john316);
    await notifier.setReference(const BibleReference(bookId: 'JHN', chapter: 4));

    expect(notifier.takeVerseFocusRequest(_john316), isFalse);
  });
}
