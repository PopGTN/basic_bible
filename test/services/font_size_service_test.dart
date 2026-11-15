import 'package:basic_bible/src/services/font_size_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() => FontSizeService.instance.notifier.value = 16.0);

  test('setSize persists and load restores it on next launch', () async {
    SharedPreferences.setMockInitialValues({});
    var prefs = await SharedPreferences.getInstance();
    FontSizeService.instance.load(prefs);

    FontSizeService.instance.setSize(22);
    expect(prefs.getDouble(FontSizeService.prefsKey), 22);

    // Simulate a fresh launch.
    FontSizeService.instance.notifier.value = 16.0;
    prefs = await SharedPreferences.getInstance();
    FontSizeService.instance.load(prefs);
    expect(FontSizeService.instance.size, 22);
  });

  test('out-of-range saved values are clamped', () async {
    SharedPreferences.setMockInitialValues({FontSizeService.prefsKey: 99.0});
    FontSizeService.instance.load(await SharedPreferences.getInstance());
    expect(FontSizeService.instance.size, FontSizeService.maxSize);
  });
}
