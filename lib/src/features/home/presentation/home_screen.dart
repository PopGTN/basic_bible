import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/features/menu/presentation/menu_tab.dart';
import 'package:basic_bible/src/features/reader/application/bible_provider.dart';
import 'package:basic_bible/src/features/reader/presentation/bible_viewer_tab.dart';
import 'package:basic_bible/src/providers/theme_provider.dart';
import 'package:basic_bible/src/services/font_size_service.dart';

import 'home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0; // currently selected tab index

  // Animation controllers for BottomNav + AppBar show/hide
  late final AnimationController _bottomNavController;
  late final AnimationController _appBarController;

  @override
  void initState() {
    super.initState();
    _bottomNavController = _createController();
    _appBarController = _createController();
  }

  // Factory method for creating consistent controllers
  AnimationController _createController() => AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
    value: 1.0, // start fully visible
  );

  @override
  void dispose() {
    _bottomNavController.dispose();
    _appBarController.dispose();
    super.dispose();
  }

  // === Animation helpers for child widgets (BibleViewerTab) ===
  void showBottomNav() => _bottomNavController.forward();

  void hideBottomNav() => _bottomNavController.reverse();

  void showAppBar() => _appBarController.forward();

  void hideAppBar() => _appBarController.reverse();

  void _showBibleViewerSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, child) {
            final themeMode = ref.watch(themeProvider);
            final layoutMode = ref.watch(readerLayoutModeProvider);
            final showBookIntroductions = ref.watch(
              showBookIntroductionsProvider,
            );

            return _BibleViewerSettingsSheet(
              themeMode: themeMode,
              layoutMode: layoutMode,
              continuousScrolling: ref.watch(continuousScrollingProvider),
              showBookIntroductions: showBookIntroductions,
              onDecreaseFont: () {
                final nextSize = (FontSizeService.instance.size - 2).clamp(
                  12.0,
                  28.0,
                );
                FontSizeService.instance.setSize(nextSize);
              },
              onIncreaseFont: () {
                final nextSize = (FontSizeService.instance.size + 2).clamp(
                  12.0,
                  28.0,
                );
                FontSizeService.instance.setSize(nextSize);
              },
              onThemeSelected: (mode) {
                ref.read(themeProvider.notifier).setTheme(mode);
              },
              onLayoutSelected: (mode) {
                ref.read(readerLayoutModeProvider.notifier).setLayoutMode(mode);
              },
              onContinuousScrollingChanged: (value) {
                ref
                    .read(continuousScrollingProvider.notifier)
                    .setEnabled(value);
              },
              onShowBookIntroductionsChanged: (value) {
                ref
                    .read(showBookIntroductionsProvider.notifier)
                    .setEnabled(value);
              },
              onOpenAllSettings: () {
                Navigator.of(sheetContext).pop();
                context.go('/home/settings');
              },
            );
          },
        );
      },
    );
  }

  void _handleBibleViewerMenuAction(
    BuildContext context,
    WidgetRef ref,
    _BibleViewerMenuAction action,
  ) {
    switch (action) {
      case _BibleViewerMenuAction.relatedContent:
        context.go('/coming-soon/related-content');
      case _BibleViewerMenuAction.fontsAndSettings:
        _showBibleViewerSettings(context, ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    // Responsive checks
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 1100; // large screen breakpoint
    final isSmall = !isWide;

    // Adjust animation duration for small vs wide
    final duration = isSmall
        ? const Duration(milliseconds: 250)
        : Duration.zero;
    _bottomNavController.duration = duration;
    _appBarController.duration = duration;

    // Tab configuration (widgets, titles, icons)
    final tabs = [
      {
        'widget': const HomeTab(),
        'title': t.home,
        'icon': FontAwesomeIcons.house,
      },
      {
        'widget': BibleViewerTab(
          showBottomNav: showBottomNav,
          hideBottomNav: hideBottomNav,
          showAppBar: showAppBar,
          hideAppBar: hideAppBar,
          isSmallDevice: isSmall,
        ),
        'title': t.bible,
        'icon': FontAwesomeIcons.book,
      },
      {
        'widget': const MenuTab(),
        'title': t.menu,
        'icon': FontAwesomeIcons.bars,
      },
    ];

    final current = tabs[_currentIndex]; // currently selected tab
    final isBibleTab = _currentIndex == 1; // check if Bible tab is active

    return Scaffold(
      // Top bar changes depending on device size + tab
      appBar: _buildAppBar(current, isWide, isBibleTab),

      // Main content
      body: isWide
          ? Row(
              children: [
                // Side navigation for wide screens
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (i) =>
                      setState(() => _currentIndex = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: tabs
                      .map(
                        (tab) => NavigationRailDestination(
                          icon: Icon(tab['icon'] as IconData),
                          label: Text(tab['title'] as String),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: current['widget'] as Widget),
              ],
            )
          : current['widget'] as Widget,

      // Bottom navigation only for small screens
      bottomNavigationBar: isWide
          ? null
          : SizeTransition(
              sizeFactor: _bottomNavController.drive(
                CurveTween(curve: Curves.easeInOut),
              ),
              axisAlignment: -1,
              child: Theme(
                // The bottom tabs should switch immediately without the
                // default Material ripple since this shell is being styled
                // more like a static app dock than a tappable card row.
                data: Theme.of(context).copyWith(
                  splashFactory: NoSplash.splashFactory,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),
                  items: tabs
                      .map(
                        (tab) => BottomNavigationBarItem(
                          icon: Icon(tab['icon'] as IconData),
                          label: tab['title'] as String,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
    );
  }

  /// Builds the AppBar depending on screen size & active tab
  PreferredSizeWidget _buildAppBar(
    Map<String, Object> tab,
    bool isWide,
    bool isBible,
  ) {
    final title = Text(tab['title'] as String);

    // Extra buttons only appear on Bible tab
    final actions = isBible
        ? [
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () {},
              tooltip: 'Play Audio',
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
              tooltip: 'Search',
            ),
            Consumer(
              builder: (context, ref, child) {
                final colors = Theme.of(context).colorScheme;
                return PopupMenuButton<_BibleViewerMenuAction>(
                  color: colors.surfaceContainerHigh,
                  tooltip: 'Reader options',
                  onSelected: (action) =>
                      _handleBibleViewerMenuAction(context, ref, action),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _BibleViewerMenuAction.relatedContent,
                      child: Row(
                        children: [
                          Icon(
                            Icons.library_books_outlined,
                            color: colors.onSurface,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Related Content',
                            style: TextStyle(color: colors.onSurface),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _BibleViewerMenuAction.fontsAndSettings,
                      child: Row(
                        children: [
                          Icon(Icons.text_fields, color: colors.onSurface),
                          const SizedBox(width: 12),
                          Text(
                            'Fonts & Settings',
                            style: TextStyle(color: colors.onSurface),
                          ),
                        ],
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_horiz),
                );
              },
            ),
            // Translation entry point for the dedicated Versions screen.
            Consumer(
              builder: (context, ref, child) {
                final currentTranslation = ref.watch(
                  currentTranslationProvider,
                );
                final translationsAsync = ref.watch(
                  availableTranslationsProvider,
                );
                final colors = Theme.of(context).colorScheme;
                final translations =
                    translationsAsync.value ??
                    AppBibleRepository.builtInTranslations;
                String? currentTranslationLabel;
                for (final translation in translations) {
                  if (translation.id == currentTranslation) {
                    currentTranslationLabel = translation.id.toUpperCase();
                    break;
                  }
                }
                return Card(
                  color: colors.secondary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => context.push('/home/translations'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.language, color: colors.onSecondary),
                          const SizedBox(width: 6),
                          Text(
                            currentTranslationLabel ??
                                currentTranslation.toUpperCase(),
                            style: TextStyle(color: colors.onSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ]
        : null;

    // === Wide screen → static AppBar ===
    if (isWide) {
      return AppBar(
        title: title,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: actions,
      );
    }

    // === Small screen → animated AppBar (show/hide on scroll) ===
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: SizeTransition(
        sizeFactor: _appBarController.drive(
          CurveTween(curve: Curves.easeInOut),
        ),
        axisAlignment: -1,
        child: AppBar(
          title: title,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          actions: actions,
        ),
      ),
    );
  }
}

enum _BibleViewerMenuAction { relatedContent, fontsAndSettings }

class _BibleViewerSettingsSheet extends StatelessWidget {
  const _BibleViewerSettingsSheet({
    required this.themeMode,
    required this.layoutMode,
    required this.continuousScrolling,
    required this.showBookIntroductions,
    required this.onDecreaseFont,
    required this.onIncreaseFont,
    required this.onThemeSelected,
    required this.onLayoutSelected,
    required this.onContinuousScrollingChanged,
    required this.onShowBookIntroductionsChanged,
    required this.onOpenAllSettings,
  });

  final AppThemeMode themeMode;
  final ReaderLayoutMode layoutMode;
  final bool continuousScrolling;
  final bool showBookIntroductions;
  final VoidCallback onDecreaseFont;
  final VoidCallback onIncreaseFont;
  final ValueChanged<AppThemeMode> onThemeSelected;
  final ValueChanged<ReaderLayoutMode> onLayoutSelected;
  final ValueChanged<bool> onContinuousScrollingChanged;
  final ValueChanged<bool> onShowBookIntroductionsChanged;
  final VoidCallback onOpenAllSettings;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<double>(
              valueListenable: FontSizeService.instance.notifier,
              builder: (context, size, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _FontAdjustButton(
                          label: 'A',
                          fontSize: 18,
                          onPressed: onDecreaseFont,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 54,
                        color: colors.outlineVariant.withValues(alpha: 0.5),
                      ),
                      Expanded(
                        child: _FontAdjustButton(
                          label: 'A',
                          fontSize: 32,
                          onPressed: onIncreaseFont,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _SettingsRow(
                    title: 'Font',
                    value: 'System Default',
                    icon: Icons.chevron_right,
                    onTap: onOpenAllSettings,
                  ),
                  Divider(
                    height: 1,
                    color: colors.outlineVariant.withValues(alpha: 0.7),
                  ),
                  _ToggleSettingsRow(
                    title: 'Continuous Scrolling',
                    value: continuousScrolling,
                    onChanged: onContinuousScrollingChanged,
                  ),
                  Divider(
                    height: 1,
                    color: colors.outlineVariant.withValues(alpha: 0.7),
                  ),
                  _ToggleSettingsRow(
                    title: 'Document Mode',
                    value: layoutMode == ReaderLayoutMode.document,
                    onChanged: (value) {
                      onLayoutSelected(
                        value
                            ? ReaderLayoutMode.document
                            : ReaderLayoutMode.verseList,
                      );
                    },
                  ),
                  Divider(
                    height: 1,
                    color: colors.outlineVariant.withValues(alpha: 0.7),
                  ),
                  _ToggleSettingsRow(
                    title: 'Show Introductions',
                    value: showBookIntroductions,
                    onChanged: onShowBookIntroductionsChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('Theme', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final mode in AppThemeMode.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _ThemePreviewCard(
                        mode: mode,
                        selected: mode == themeMode,
                        onTap: () => onThemeSelected(mode),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: onOpenAllSettings,
                icon: const Icon(Icons.settings),
                label: const Text('All Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FontAdjustButton extends StatelessWidget {
  const _FontAdjustButton({
    required this.label,
    required this.fontSize,
    required this.onPressed,
  });

  final String label;
  final double fontSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: 56,
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontSize: fontSize, color: colors.onSurface),
          ),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
            Icon(icon, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _ToggleSettingsRow extends StatelessWidget {
  const _ToggleSettingsRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  const _ThemePreviewCard({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final AppThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preview = _themePreview(mode);
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 78,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: preview.background,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 2,
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
    );
  }

  _ThemePreview _themePreview(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.system => const _ThemePreview(
        background: Color(0xFFF8F6F1),
        foreground: Color(0xFF1C1A17),
      ),
      AppThemeMode.light => const _ThemePreview(
        background: Color(0xFFF4EEE6),
        foreground: Color(0xFF3A3028),
      ),
      AppThemeMode.dark => const _ThemePreview(
        background: Color(0xFF181614),
        foreground: Color(0xFFF3EEE8),
      ),
      AppThemeMode.softDark => const _ThemePreview(
        background: Color(0xFF1B1D22),
        foreground: Color(0xFFF2F4F7),
      ),
      AppThemeMode.black => const _ThemePreview(
        background: Color(0xFF000000),
        foreground: Color(0xFFF5F5F5),
      ),
      AppThemeMode.white => const _ThemePreview(
        background: Color(0xFFFFFFFF),
        foreground: Color(0xFF111111),
      ),
      AppThemeMode.blue => const _ThemePreview(
        background: Color(0xFF1E2D42),
        foreground: Color(0xFFF2F6FB),
      ),
      AppThemeMode.red => const _ThemePreview(
        background: Color(0xFF35211D),
        foreground: Color(0xFFFAF1EC),
      ),
    };
  }
}

class _ThemePreview {
  const _ThemePreview({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
