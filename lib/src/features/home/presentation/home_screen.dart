import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/features/menu/presentation/menu_tab.dart';
import 'package:basic_bible/src/features/reader/application/bible_provider.dart';
import 'package:basic_bible/src/features/reader/presentation/bible_viewer_tab.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/font_size_service.dart';

import 'home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  static const String _importTranslationMenuValue = '__import_translation__';
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

  Future<void> _importBibleFile(WidgetRef ref) async {
    const xmlTypeGroup = XTypeGroup(
      label: 'Bible XML',
      extensions: <String>['xml', 'usfx', 'osis'],
    );
    final file = await openFile(acceptedTypeGroups: [xmlTypeGroup]);
    if (file == null) return;

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final importedTranslation = await ref
          .read(bibleBooksProvider.notifier)
          .importTranslation(file.path);
      await ref
          .read(currentTranslationProvider.notifier)
          .setTranslation(importedTranslation.id);
      ref.invalidate(availableTranslationsProvider);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Imported ${importedTranslation.name}.')),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Import failed: $error')));
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
              icon: const Icon(Icons.search),
              onPressed: () {},
              tooltip: 'Search',
            ),
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () {},
              tooltip: 'Play Audio',
            ),
            Consumer(
              builder: (context, ref, child) {
                final layoutMode = ref.watch(readerLayoutModeProvider);
                final colors = Theme.of(context).colorScheme;
                return Card(
                  color: colors.secondary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: PopupMenuButton<ReaderLayoutMode>(
                    color: colors.surface,
                    tooltip: 'Reader layout',
                    onSelected: (mode) {
                      ref
                          .read(readerLayoutModeProvider.notifier)
                          .setLayoutMode(mode);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: ReaderLayoutMode.verseList,
                        child: Text('Verse List'),
                      ),
                      PopupMenuItem(
                        value: ReaderLayoutMode.document,
                        child: Text('Document'),
                      ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.view_stream, color: colors.onSecondary),
                          const SizedBox(width: 6),
                          Text(
                            layoutMode == ReaderLayoutMode.verseList
                                ? 'List'
                                : 'Document',
                            style: TextStyle(color: colors.onSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // Translation selector (moves the popup from the viewer into the top AppBar)
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
                String? currentTranslationName;
                for (final translation in translations) {
                  if (translation.id == currentTranslation) {
                    currentTranslationName = translation.name;
                    break;
                  }
                }
                return Card(
                  color: colors.secondary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: PopupMenuButton<String>(
                    color: colors.surface, // menu background
                    padding: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.translate, color: colors.onSecondary),
                          const SizedBox(width: 4),
                          Text(
                            currentTranslationName ?? currentTranslation,
                            style: TextStyle(color: colors.onSecondary),
                          ),
                        ],
                      ),
                    ),
                    onSelected: (translationId) async {
                      if (translationId == _importTranslationMenuValue) {
                        Future.microtask(() => _importBibleFile(ref));
                        return;
                      }

                      // Defer the heavy provider work until after the
                      // popup route has been dismissed. If we trigger
                      // state changes synchronously here we can cause
                      // the widget that opened the popup to be
                      // deactivated while the popup is still resolving
                      // its ancestors which leads to the exception:
                      // "Looking up a deactivated widget's ancestor is unsafe."
                      // Using a microtask (or Future.delayed(Duration.zero))
                      // schedules the work after the current frame so the
                      // PopupMenuRoute can finish closing safely.
                      Future.microtask(() async {
                        await ref
                            .read(currentTranslationProvider.notifier)
                            .setTranslation(translationId);
                        await ref
                            .read(bibleBooksProvider.notifier)
                            .changeTranslation(translationId);
                      });
                    },
                    itemBuilder: (context) {
                      final textStyle = TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      );
                      return [
                        for (final translation in translations)
                          PopupMenuItem(
                            value: translation.id,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    translation.name,
                                    style: textStyle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _translationSourceLabel(translation),
                                  style: textStyle.copyWith(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: _importTranslationMenuValue,
                          child: Row(
                            children: [
                              const Icon(Icons.upload_file),
                              const SizedBox(width: 8),
                              Text('Import Bible XML', style: textStyle),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                );
              },
            ),
            // Font size selector for Bible text (uses shared service)
            ValueListenableBuilder<double>(
              valueListenable: FontSizeService.instance.notifier,
              builder: (context, size, child) {
                final choices = <double>[12, 14, 16, 18, 20, 22, 24];
                final colors = Theme.of(context).colorScheme;
                return Card(
                  color: colors.secondary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: PopupMenuButton<double>(
                    color: colors.surface,
                    tooltip: 'Bible text size',
                    initialValue: size,
                    onSelected: (v) => FontSizeService.instance.setSize(v),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.text_fields, color: colors.onSecondary),
                          const SizedBox(width: 6),
                          Text(
                            '${size.toInt()}',
                            style: TextStyle(color: colors.onSecondary),
                          ),
                        ],
                      ),
                    ),
                    itemBuilder: (context) => choices
                        .map(
                          (s) => PopupMenuItem(
                            value: s,
                            child: Text(
                              '${s.toInt()}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        )
                        .toList(),
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

  String _translationSourceLabel(BibleTranslation translation) {
    return switch (translation.sourceType) {
      BibleSourceType.asset => 'Bundled',
      BibleSourceType.download => 'Downloaded',
      BibleSourceType.import => 'Imported',
    };
  }
}
