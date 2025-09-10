// import 'package:flutter/material.dart';
// import 'tabs/bibleViewer_tab.dart';
// import 'tabs/about_tab.dart';
// import 'tabs/home_tab.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;

//   final _tabItems = [
//     {'widget': const HomeTab(), 'title': 'Home', 'icon': Icons.home},
//     {'widget': const BibleViewerTab(), 'title': 'Bible', 'icon': Icons.menu_book},
//     {'widget': const AboutTab(), 'title': 'About', 'icon': Icons.info},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final currentTab = _tabItems[_currentIndex];
//     final isWideScreen = MediaQuery.of(context).size.width >= 800;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(currentTab['title'] as String),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         foregroundColor: Theme.of(context).colorScheme.onPrimary,
//       ),
//       body: isWideScreen
//           ? Row(
//               children: [
//                 NavigationRail(
//                   selectedIndex: _currentIndex,
//                   onDestinationSelected: (index) =>
//                       setState(() => _currentIndex = index),
//                   labelType: NavigationRailLabelType.all,
//                   destinations: _tabItems
//                       .map(
//                         (tab) => NavigationRailDestination(
//                           icon: Icon(tab['icon'] as IconData),
//                           label: Text(tab['title'] as String),
//                         ),
//                       )
//                       .toList(),
//                 ),
//                 const VerticalDivider(thickness: 1, width: 1),
//                 Expanded(child: currentTab['widget'] as Widget),
//               ],
//             )
//           : currentTab['widget'] as Widget,
//       bottomNavigationBar: isWideScreen
//           ? null
//           : BottomNavigationBar(
//               currentIndex: _currentIndex,
//               onTap: (index) => setState(() => _currentIndex = index),
//               items: _tabItems
//                   .map(
//                     (tab) => BottomNavigationBarItem(
//                       icon: Icon(tab['icon'] as IconData),
//                       label: tab['title'] as String,
//                     ),
//                   )
//                   .toList(),
//             ),
//     );
//   }
// }


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

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // Access translations
    final isWideScreen = MediaQuery.of(context).size.width >= 800;

    // Tab items with localized titles
    final _tabItems = [
      {'widget': const HomeTab(), 'title': t.home, 'icon': Icons.home},
      {'widget': const BibleViewerTab(), 'title': t.bible, 'icon': Icons.menu_book},
      {'widget': const AboutTab(), 'title': t.about, 'icon': Icons.info},
    ];

    final currentTab = _tabItems[_currentIndex];

    return Scaffold(
        appBar: AppBar(
          title: Text(currentTab['title'] as String),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),      
        body: isWideScreen ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) =>
                      setState(() => _currentIndex = index),
                  labelType: NavigationRailLabelType.all,
                  destinations: _tabItems
                      .map(
                        (tab) => NavigationRailDestination(
                          icon: Icon(tab['icon'] as IconData),
                          label: Text(tab['title'] as String),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: currentTab['widget'] as Widget),
              ],
            )
          : currentTab['widget'] as Widget,
      bottomNavigationBar: isWideScreen
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: _tabItems
                  .map(
                    (tab) => BottomNavigationBarItem(
                      icon: Icon(tab['icon'] as IconData),
                      label: tab['title'] as String,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
