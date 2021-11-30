import 'package:flutter/material.dart';
import 'package:now8/providers.dart';
import 'package:now8/screens/arrivals.dart';
import 'package:now8/screens/welcome.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => CurrentCityProvider()),
        ],
        child: MaterialApp(
          title: "now8: public transport arrival times",
          theme: ThemeData(
            brightness: Brightness.light,
            fontFamily: 'Roboto',
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'Roboto',
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const WelcomeScreen(),
            '/arrivals': (context) => const ArrivalsScreen(),
          },
        ));
  }
}

void main() => runApp(const MyApp());
