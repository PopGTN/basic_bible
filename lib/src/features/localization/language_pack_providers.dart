import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/shared_preferences_provider.dart';
import 'language_pack_service.dart';

final languagePackServiceProvider = Provider<LanguagePackService>(
  (ref) => LanguagePackService(prefs: ref.watch(sharedPreferencesProvider)),
);

final availableLanguagesProvider = FutureProvider<List<LanguageInfo>>(
  (ref) => ref.watch(languagePackServiceProvider).availableLanguages(),
);
