import 'package:flutter/material.dart';
import 'package:now8/providers.dart';
import 'package:now8/screens/arrivals.dart';
import 'package:now8/screens/favorites.dart';
import 'package:now8/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:now8/screens/stop.dart';
import 'configure_nonweb.dart' if (dart.library.html) 'configure_web.dart';
import 'dart:developer';

class MyApp extends StatelessWidget {
  final String cityName;
  final BaseCacheManager cacheManager;
  final SharedPreferences sharedPreferences;

  const MyApp(
      {Key? key,
      required this.cityName,
      required this.cacheManager,
      required this.sharedPreferences})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => CurrentCityProvider(cityName, sharedPreferences)),
          ChangeNotifierProxyProvider<CurrentCityProvider, StopsProvider>(
              create: (_) => StopsProvider(cacheManager),
              update: (_, currentCityProvider, stopsProvider) =>
                  stopsProvider!..update(currentCityProvider)),
          ChangeNotifierProvider(
              create: (_) => FavoriteStopIdsProvider(
                  sharedPreferences: sharedPreferences)),
          ChangeNotifierProxyProvider<CurrentCityProvider, RoutesProvider>(
              create: (_) => RoutesProvider(cacheManager),
              update: (_, currentCityProvider, routesProvider) =>
                  routesProvider!..update(currentCityProvider)),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
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
          onGenerateRoute: (settings) {
            List<String> pathComponents = settings.name!.split('/');
            switch (pathComponents[1]) {
              case "arrivals":
                {
                  return MaterialPageRoute(
                    builder: (context) => const ArrivalsScreen(),
                    settings: RouteSettings(name: settings.name),
                  );
                }
              case "favorites":
                {
                  return MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                    settings: RouteSettings(name: settings.name),
                  );
                }
              case "stop":
                {
                  if (pathComponents.length > 2 &&
                      pathComponents[2].isNotEmpty) {
                    return MaterialPageRoute(
                      builder: (context) =>
                          StopScreen(stopId: pathComponents[2]),
                      settings: RouteSettings(name: settings.name),
                    );
                  }
                  break;
                }
              default:
                {
                  if (pathComponents[1] != "") {
                    log("Invalid route ${settings.name}");
                  }
                  return MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                    settings: const RouteSettings(name: "/"),
                  );
                }
            }
          },
        ));
  }
}

void main() async {
  configureApp();
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String cityName = sharedPreferences.getString("city_name") ?? "madrid";
  BaseCacheManager cacheManager = DefaultCacheManager();

  runApp(MyApp(
    cityName: cityName,
    cacheManager: cacheManager,
    sharedPreferences: sharedPreferences,
  ));
}
