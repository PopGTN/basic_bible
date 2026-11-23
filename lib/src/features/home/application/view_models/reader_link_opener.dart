import 'package:basic_bible/src/features/home/application/view_models/home_navigation_view_model.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_session_view_models.dart';
import 'package:basic_bible/src/features/reader/models/reader_deep_link.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final readerLinkOpenerProvider = Provider<ReaderLinkOpener>(
  ReaderLinkOpener.new,
);

/// Applies a [ReaderDeepLink] (#40): optional translation, then the
/// reference (verse emphasised when given), then the Bible tab.
class ReaderLinkOpener {
  ReaderLinkOpener(this._ref);

  final Ref _ref;

  Future<void> open(ReaderDeepLink link) async {
    final translationId = link.translationId;
    if (translationId != null &&
        translationId != _ref.read(currentTranslationProvider)) {
      // Only switch to a translation that can be read right now; otherwise
      // stay on the last-used one (the issue's stated default) rather than
      // opening an empty reader.
      final available = await _ref.read(availableTranslationsProvider.future);
      final target = available
          .where((t) => t.id == translationId && t.isReadableNow)
          .firstOrNull;
      if (target != null) {
        await _ref
            .read(currentTranslationProvider.notifier)
            .setTranslation(
              target.id,
              persist: target.sourceType != BibleSourceType.session,
            );
      }
    }
    await _ref
        .read(currentReferenceProvider.notifier)
        .setReference(link.reference);
    _ref.read(homeTabIndexProvider.notifier).state = 1;
  }
}
