// import 'package:basic_bible/src/screens/HomeScreen.dart';
// import 'package:basic_bible/src/screens/MyHomePage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'features/home/home_page.dart';
import 'features/home/about_page.dart';


// class MyApp extends StatelessWidget {
//   MyApp({super.key});

//   // Define routes with go_router
//   final GoRouter _router = GoRouter(
//     routes: [
//       GoRoute(
//         path: '/',
//         builder: (context, state) => const HomeScreen(),
//       ),

//     ],
//   );

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       title: 'My Flutter App',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
//         // primarySwatch: Colors.blue,
//       ),
//       routerConfig: _router,
//     );
//   }
// }


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
        final GoRouter router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutPage(),
        ),
      ],
    );
    
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Bible App Test',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),

        ),
        routerConfig: router,
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  
}


// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final GoRouter router = GoRouter(
//       routes: [
//         GoRoute(
//           path: '/',
//           builder: (context, state) => const HomePage(),
//         ),
//         GoRoute(
//           path: '/about',
//           builder: (context, state) => const AboutPage(),
//         ),
//       ],
//     );

//     return MaterialApp.router(
//       debugShowCheckedModeBanner: false,
//       title: 'Bible App Test',
//       theme: ThemeData(
//         primarySwatch: Colors.indigo,
//       ),
//       routerConfig: router,
//     );
//   }
// }
