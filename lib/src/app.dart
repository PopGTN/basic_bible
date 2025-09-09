import 'package:basic_bible/src/screens/HomeScreen.dart';
import 'package:basic_bible/src/screens/MyHomePage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


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
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Bible App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  
}