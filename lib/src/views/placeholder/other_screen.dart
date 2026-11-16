import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:basic_bible/src/widgets/app_back_button.dart';

class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(AppLocalizations.of(context)!.otherPageTitle),
      ),
      body: Center(child: Text(AppLocalizations.of(context)!.otherPageBody)),
    );
  }
}
