import 'package:flutter/material.dart';
import 'package:now8/domain.dart';
import 'package:now8/providers.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

class CityDropdown extends StatelessWidget {
  const CityDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentCity = Provider.of<CurrentCityProvider>(context);

    return DropdownButton<City>(
      value: currentCity.city,
      items: City.values
          .map<DropdownMenuItem<City>>((City city) => DropdownMenuItem<City>(
              value: city,
              child: Text(ReCase(city.toString().split('.').last).titleCase)))
          .toList(),
      onChanged: (value) {
        currentCity.city = value!;
      },
    );
  }
}

class ScreenTemplate extends StatelessWidget {
  final Widget body;
  final String appBarTitle;
  final List<Widget>? actions;
  final bool showDrawer;

  final Widget drawer = DefaultDrawer();

  ScreenTemplate(
      {Key? key,
      required this.body,
      required this.appBarTitle,
      this.actions,
      this.showDrawer = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
        actions: actions,
      ),
      drawer: showDrawer ? drawer : null,
      body: body,
      backgroundColor: Theme.of(context).colorScheme.background,
    );
  }
}

class RouteInfo {
  final String title;
  final String route;
  final IconData iconData;

  RouteInfo({required this.title, required this.route, required this.iconData});
}

class DefaultDrawer extends StatelessWidget {
  final List<RouteInfo> routeInfos = [
    RouteInfo(
        title: "Arrivals", route: "/arrivals", iconData: Icons.departure_board)
  ];

  DefaultDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              decoration:
                  BoxDecoration(color: Theme.of(context).colorScheme.secondary),
              child: const Center(child: CityDropdown())),
          ...routeInfos
              .map((routeInfo) => DrawerTile(routeInfo: routeInfo))
              .toList(),
        ],
      ),
    );
  }
}

class DrawerTile extends StatelessWidget {
  final RouteInfo routeInfo;

  const DrawerTile({Key? key, required this.routeInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(children: [
        Icon(routeInfo.iconData),
        Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              routeInfo.title,
              style: Theme.of(context).textTheme.subtitle1,
            ))
      ]),
      onTap: ModalRoute.of(context)?.settings.name == routeInfo.route
          ? null
          : () {
              Navigator.of(context).pushNamed(routeInfo.route);
            },
    );
  }
}
