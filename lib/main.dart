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
          // https://material.io/resources/color/#!/?view.left=0&view.right=1&primary.color=104068&secondary.color=baddf9&primary.text.color=ffffff
          theme: ThemeData(
            primaryColor: const Color(0xff104068),
            colorScheme: const ColorScheme(
                primary: Color(0xff104068),
                primaryVariant: Color(0xff001a3d),
                secondary: Color(0xffbbdefb),
                secondaryVariant: Color(0xff8aacc8),
                surface: Color(0xffe1e2e1),
                background: Color(0xfff5f5f6),
                error: Color(0xffff0000),
                onPrimary: Color(0xffffffff),
                onSecondary: Color(0xff000000),
                onSurface: Color(0xff000000),
                onBackground: Color(0xff000000),
                onError: Color(0xffffffff),
                brightness: Brightness.light),
            brightness: Brightness.light,
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
