// Words of Jesus are red; bold is an opt-in extra (off by default).

import 'package:basic_bible/src/features/settings/application/view_models/reader_display_preferences_view_models.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
}

void main() {
  test('off by default', () async {
    final c = await _container({});
    addTearDown(c.dispose);
    expect(c.read(boldWordsOfJesusProvider), isFalse);
  });

  test('turning it on persists across launches', () async {
    final c = await _container({});
    addTearDown(c.dispose);
    await c.read(boldWordsOfJesusProvider.notifier).setEnabled(true);
    expect(c.read(boldWordsOfJesusProvider), isTrue);

    final prefs = c.read(sharedPreferencesProvider);
    expect(prefs.getBool('reader_bold_words_of_jesus'), isTrue);

    final relaunched = await _container({'reader_bold_words_of_jesus': true});
    addTearDown(relaunched.dispose);
    expect(relaunched.read(boldWordsOfJesusProvider), isTrue);
  });
}
