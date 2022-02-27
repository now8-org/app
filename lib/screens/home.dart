import 'package:flutter/material.dart';
import 'package:now8/screens/common.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:now8/screens/welcome.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder:
            (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (snapshot.hasData) {
            return const WelcomeScreen();
          } else {
            return ScreenTemplate(
                body: Container(),
                appBarTitle: AppLocalizations.of(context)!.titleShort);
          }
        });
  }
}
