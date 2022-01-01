import 'package:flutter/material.dart';
import 'package:now8/screens/common.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:now8/screens/favorites.dart';
import 'package:now8/screens/welcome.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder:
            (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (snapshot.hasData) {
            SharedPreferences prefs = snapshot.data!;
            if (prefs.getStringList("favorite_stop_ids") != null) {
              return const FavoritesScreen();
            } else {
              return const WelcomeScreen();
            }
          } else {
            return ScreenTemplate(body: Container(), appBarTitle: "now8");
          }
        });
  }
}
