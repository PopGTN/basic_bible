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
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _bottomNavController;

  @override
  void initState() {
    super.initState();
    _bottomNavController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0, // initially visible
    );
  }

  @override
  void dispose() {
    _bottomNavController.dispose();
    super.dispose();
  }

  void showBottomNav() {
    if (mounted) _bottomNavController.forward();
  }

  void hideBottomNav() {
    if (mounted) _bottomNavController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isWideScreen = MediaQuery.of(context).size.width >= 800;

    final _tabItems = [
      {'widget': const HomeTab(), 'title': t.home, 'icon': Icons.home},
      {
        'widget': BibleViewerTab(
          showBottomNav: showBottomNav,
          hideBottomNav: hideBottomNav,
        ),
        'title': t.bible,
        'icon': Icons.menu_book
      },
      {'widget': const AboutTab(), 'title': t.about, 'icon': Icons.info},
    ];

    final currentTab = _tabItems[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentTab['title'] as String),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
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
