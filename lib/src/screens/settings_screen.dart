import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current theme from ThemeNotifier
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Theme",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Generate a RadioListTile for each theme
            ...AppThemeMode.values.map(
              (themeMode) => RadioListTile<AppThemeMode>(
                value: themeMode,
                groupValue: currentTheme,
                title: Row(
                  children: [
                    // Color preview box
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: _themeColor(themeMode),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Text(_themeModeToString(themeMode)),
                  ],
                ),
                onChanged: (val) {
                  if (val != null) {
                    // Persist theme selection and apply immediately
                    ref.read(themeProvider.notifier).setTheme(val);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Convert AppThemeMode to readable string
  String _themeModeToString(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return "System";
      case AppThemeMode.light:
        return "Light";
      case AppThemeMode.dark:
        return "Dark";
      case AppThemeMode.blue:
        return "Blue Theme";
      case AppThemeMode.red:
        return "Red Theme";
    }
  }

  // Helper: Map AppThemeMode to a representative color
  Color _themeColor(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return Colors.grey;
      case AppThemeMode.light:
        return Colors.green;
      case AppThemeMode.dark:
        return Colors.black87;
      case AppThemeMode.blue:
        return Colors.blue;
      case AppThemeMode.red:
        return Colors.red;
    }
  }
}
