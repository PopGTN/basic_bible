import 'package:flutter/material.dart';
import 'tabs/bibleViewer_tab.dart';
import 'tabs/about_tab.dart';
import 'tabs/home_tab.dart';
import 'package:basic_bible/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  late final AnimationController _bottomNavController;
  late final AnimationController _appBarController;

  @override
  void initState() {
    super.initState();

    // Determine duration based on device
    // We will update the duration dynamically in build
    _bottomNavController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
      value: 1.0,
    );

    _appBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _bottomNavController.dispose();
    _appBarController.dispose();
    super.dispose();
  }

  // Animation helpers
  void showBottomNav() => _bottomNavController.forward();
  void hideBottomNav() => _bottomNavController.reverse();
  void showAppBar() => _appBarController.forward();
  void hideAppBar() => _appBarController.reverse();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final isWideScreen = width >= 1100;
    final isSmallDevice = !isWideScreen;

    // Update animation duration depending on device
    final animationDuration =
    isSmallDevice ? const Duration(milliseconds: 50) : Duration.zero;
    _bottomNavController.duration = animationDuration;
    _appBarController.duration = animationDuration;

    final _tabItems = [
      {'widget': const HomeTab(), 'title': t.home, 'icon': Icons.home},
      {
        'widget': BibleViewerTab(
          showBottomNav: showBottomNav,
          hideBottomNav: hideBottomNav,
          showAppBar: showAppBar,
          hideAppBar: hideAppBar,
          isSmallDevice: isSmallDevice,
        ),
        'title': t.bible,
        'icon': Icons.menu_book
      },
      {'widget': const AboutTab(), 'title': t.about, 'icon': Icons.info},
    ];

    final currentTab = _tabItems[_currentIndex];

    final preferredAppBar = isWideScreen
        ? AppBar(
      title: Text(currentTab['title'] as String),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    )
        : PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: SizeTransition(
        sizeFactor: _appBarController,
        axisAlignment: -1,
        child: AppBar(
          title: Text(currentTab['title'] as String),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );

    return Scaffold(
      appBar: preferredAppBar as PreferredSizeWidget?,
      body: isWideScreen
          ? Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) =>
                setState(() => _currentIndex = index),
            labelType: NavigationRailLabelType.all,
            destinations: _tabItems
                .map((tab) => NavigationRailDestination(
              icon: Icon(tab['icon'] as IconData),
              label: Text(tab['title'] as String),
            ))
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: currentTab['widget'] as Widget),
        ],
      )
          : currentTab['widget'] as Widget,
      bottomNavigationBar: isWideScreen
          ? null
          : SizeTransition(
        sizeFactor: _bottomNavController,
        axisAlignment: -1,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: _tabItems
              .map((tab) => BottomNavigationBarItem(
            icon: Icon(tab['icon'] as IconData),
            label: tab['title'] as String,
          ))
              .toList(),
        ),
      ),
    );
  }
}
