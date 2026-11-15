import 'package:basic_bible/src/features/sync/application/view_models/sync_view_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'manual sync mode persists to preferences and defaults to automatic',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final controller = SyncModeController(prefs);

      expect(controller.state, SyncMode.automatic);

      await controller.setMode(SyncMode.manual);

      expect(controller.state, SyncMode.manual);
      expect(prefs.getString('sync_mode'), 'manual');
    },
  );
}
