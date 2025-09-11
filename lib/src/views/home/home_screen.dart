import 'package:flutter/material.dart';
import 'tabs/home_tab.dart';
import 'tabs/Menu_tab.dart';
import 'tabs/bibleViewerTab/bibleViewer_tab.dart';
import 'package:basic_bible/l10n/app_localizations.dart';

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
      {'widget': const HomeTab(), 'title': t.home, 'icon': Icons.home},
      {
        'widget': BibleViewerTab(
          showBottomNav: showBottomNav,
          hideBottomNav: hideBottomNav,
          showAppBar: showAppBar,
          hideAppBar: hideAppBar,
          isSmallDevice: isSmall,
        ),
        'title': t.bible,
        'icon': Icons.menu_book,
      },
      {'widget': const MenuTab(), 'title': t.menu, 'icon': Icons.menu},
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ActionChip(
                label: const Text("KJV"),
                avatar: const Icon(Icons.language),
                onPressed: () {},
              ),
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
