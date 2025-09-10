import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Example language list
  final List<String> languages = ['English', 'Spanish', 'French', 'German'];
  String selectedLanguage = 'English'; // default

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Theme",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...AppThemeMode.values.map(
              (themeMode) => RadioListTile<AppThemeMode>(
                value: themeMode,
                groupValue: currentTheme,
                title: Row(
                  children: [
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
                    ref.read(themeProvider.notifier).setTheme(val);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),

            // Language Section
            const Text(
              "Language",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedLanguage,
              items: languages
                  .map((lang) => DropdownMenuItem(
                        value: lang,
                        child: Text(lang),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedLanguage = val;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

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
