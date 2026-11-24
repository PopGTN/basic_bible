import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/application/view_models/home_navigation_view_model.dart';
import 'view_models/hymnal_view_models.dart';

/// Opens [number] in [bookId] on the Hymns tab (deep link target). Runs
/// from a router redirect, so it only updates providers; the redirect then
/// sends the user to /home, which shows the Hymns tab.
void openHymnFromLink(ProviderContainer container, String bookId, int number) {
  container.read(selectedHymnalIdProvider.notifier).select(bookId);
  container.read(hymnQueryProvider.notifier).set('');
  container.read(hymnFavoritesOnlyProvider.notifier).set(false);
  container.read(openHymnNumberProvider.notifier).open(number);
  container.read(homeTabIndexProvider.notifier).state = HomeTabs.hymns;
}
