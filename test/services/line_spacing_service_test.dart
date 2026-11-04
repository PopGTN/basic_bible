import 'package:basic_bible/src/services/line_spacing_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(
    () => LineSpacingService.instance.notifier.value = LineSpacing.normal,
  );

  test('setSpacing persists and load restores it on next launch', () async {
    SharedPreferences.setMockInitialValues({});
    var prefs = await SharedPreferences.getInstance();
    LineSpacingService.instance.load(prefs);

    LineSpacingService.instance.setSpacing(LineSpacing.loose);
    expect(prefs.getString(LineSpacingService.prefsKey), 'loose');

    // Simulate a fresh launch.
    LineSpacingService.instance.notifier.value = LineSpacing.normal;
    prefs = await SharedPreferences.getInstance();
    LineSpacingService.instance.load(prefs);
    expect(LineSpacingService.instance.spacing, LineSpacing.loose);
  });

  test('unknown saved values fall back to normal', () async {
    SharedPreferences.setMockInitialValues({
      LineSpacingService.prefsKey: 'gigantic',
    });
    LineSpacingService.instance.load(await SharedPreferences.getInstance());
    expect(LineSpacingService.instance.spacing, LineSpacing.normal);
  });

  test('normal preserves the existing line heights', () {
    expect(LineSpacing.normal.factor, 1.0);
  });
}
