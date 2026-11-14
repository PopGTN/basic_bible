import 'package:basic_bible/src/features/settings/application/view_models/theme_view_model.dart';
import 'package:flutter/material.dart';

/// A tappable live-preview card for one [AppThemeMode] — shows the theme's
/// own background/foreground colors with a small mocked reading layout and a
/// selection ring, instead of a plain labeled chip. Shared between the quick
/// Bible-viewer settings sheet and the full Settings screen so both present
/// theme choices identically.
class ThemePreviewCard extends StatelessWidget {
  const ThemePreviewCard({
    super.key,
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final AppThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preview = themePreviewForMode(mode);
    final colors = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: colors.onSurfaceVariant,
      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        width: 84,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 78,
              height: 112,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: preview.background,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected
                      ? colors.onSurface
                      : preview.outline ?? Colors.transparent,
                  width: selected ? 2.2 : 1.4,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : const [],
              ),
              child: Column(
                children: [
                  for (var i = 0; i < 4; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Container(
                        height: 3,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: preview.foreground.withValues(
                            alpha: i == 0 ? 0.95 : 0.6,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  const Spacer(),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: preview.foreground.withValues(alpha: 0.7),
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? Icon(Icons.check, size: 18, color: preview.foreground)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              preview.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            ),
          ],
        ),
      ),
    );
  }
}

/// Colors + label used to render [ThemePreviewCard] for a given mode.
class ThemePreview {
  const ThemePreview({
    required this.label,
    required this.background,
    required this.foreground,
    this.outline,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color? outline;
}

ThemePreview themePreviewForMode(AppThemeMode mode) {
  return switch (mode) {
    AppThemeMode.system => const ThemePreview(
      label: 'System',
      background: Color(0xFFF8F6F1),
      foreground: Color(0xFF1C1A17),
      outline: Color(0x22000000),
    ),
    AppThemeMode.light => const ThemePreview(
      label: 'Light',
      background: Color(0xFFF4EEE6),
      foreground: Color(0xFF3A3028),
      outline: Color(0x22000000),
    ),
    AppThemeMode.dark => const ThemePreview(
      label: 'Dark',
      background: Color(0xFF181614),
      foreground: Color(0xFFF3EEE8),
    ),
    AppThemeMode.softDark => const ThemePreview(
      label: 'Soft',
      background: Color(0xFF1B1D22),
      foreground: Color(0xFFF2F4F7),
    ),
    AppThemeMode.black => const ThemePreview(
      label: 'Black',
      background: Color(0xFF000000),
      foreground: Color(0xFFF5F5F5),
    ),
    AppThemeMode.white => const ThemePreview(
      label: 'White',
      background: Color(0xFFFFFFFF),
      foreground: Color(0xFF111111),
      outline: Color(0x33000000),
    ),
    AppThemeMode.blue => const ThemePreview(
      label: 'Blue',
      background: Color(0xFF1E2D42),
      foreground: Color(0xFFF2F6FB),
    ),
    AppThemeMode.red => const ThemePreview(
      label: 'Red',
      background: Color(0xFF35211D),
      foreground: Color(0xFFFAF1EC),
    ),
  };
}
