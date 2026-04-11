import 'package:flutter/material.dart';
import 'package:basic_bible/src/widgets/app_back_button.dart';

class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Other Page'),
      ),
      body: Center(child: Text('This page is not part of the bottom tabs')),
    );
  }
}
