import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Translations that have a complete SQLite database on this device and can
/// therefore be exported from Advanced settings.
///
/// The export list used to show every translation the app knows about,
/// including remote catalog entries that were never downloaded, so most rows
/// offered an Export button that could only fail (issue #64).
final exportableTranslationsProvider = FutureProvider<List<BibleTranslation>>((
  ref,
) async {
  final translations = await ref.watch(availableTranslationsProvider.future);
  final repository = ref.watch(bibleRepositoryProvider);

  // Catalog-only entries can't have a file; skip the disk check for them.
  final candidates = [
    for (final translation in translations)
      if (translation.availability !=
          BibleTranslationAvailability.downloadable)
        translation,
  ];
  final cached = await Future.wait(
    candidates.map((translation) => repository.isCached(translation.id)),
  );
  return [
    for (var i = 0; i < candidates.length; i++)
      if (cached[i]) candidates[i],
  ];
});
