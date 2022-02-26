import 'package:flutter/material.dart' hide Route;
import 'package:now8/domain.dart';
import 'package:now8/providers.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  final Widget drawer = const DefaultDrawer();

  const ScreenTemplate(
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
  const DefaultDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<RouteInfo> routeInfos = [
      RouteInfo(
          title: AppLocalizations.of(context)!.menuHome,
          route: "/",
          iconData: Icons.home),
      RouteInfo(
          title: AppLocalizations.of(context)!.menuFavorites,
          route: "/favorites",
          iconData: Icons.stars),
      RouteInfo(
          title: AppLocalizations.of(context)!.menuArrivals,
          route: "/arrivals",
          iconData: Icons.departure_board)
    ];

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

class FavoriteIconButton extends StatefulWidget {
  const FavoriteIconButton({Key? key, required this.stop}) : super(key: key);

  final Stop stop;

  @override
  State<FavoriteIconButton> createState() => _FavoriteIconButtonState();
}

class _FavoriteIconButtonState extends State<FavoriteIconButton> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    Stop stop = widget.stop;
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder:
          (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        if (snapshot.hasData) {
          _isFavorite =
              Provider.of<FavoriteStopIdsProvider>(context, listen: false)
                  .contains(stop.id);
          return IconButton(
              onPressed: () {
                if (_isFavorite) {
                  Provider.of<FavoriteStopIdsProvider>(context, listen: false)
                      .remove(stop.id);
                } else {
                  Provider.of<FavoriteStopIdsProvider>(context, listen: false)
                      .add(stop.id);
                }
                setState(() {
                  _isFavorite = !_isFavorite;
                });
              },
              icon: _isFavorite
                  ? const Icon(Icons.star)
                  : const Icon(Icons.star_border));
        } else {
          return const Icon(Icons.star_border);
        }
      },
    );
  }
}

class StopListTile extends StatelessWidget {
  final Stop? stop;
  final bool isFavorite;

  const StopListTile({Key? key, required this.stop, this.isFavorite = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.commute),
      title: Row(children: [
        Expanded(
            flex: 3,
            child: Text('${stop?.name ?? "..."} (${stop?.code ?? "..."})')),
        Expanded(
          flex: 1,
          child: StopRoutesWidget(
              routeIds:
                  stop!.routeWays.map((element) => element.routeId).toList()),
        ),
      ]),
      trailing: SizedBox(
          width: 10, child: isFavorite ? const Icon(Icons.star) : Container()),
    );
  }
}

class StopRoutesWidget extends StatelessWidget {
  final int maxRoutes = 3;
  final List<String> routeIds;

  const StopRoutesWidget({Key? key, required this.routeIds}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Route?> routes =
        routeIds.toSet().toList().take(maxRoutes).map((element) {
      return Provider.of<RoutesProvider>(context).getRoute(element);
    }).toList();
    return Wrap(spacing: 5, children: [
      ...routes
          .map((element) => Text(
                element?.code ?? "...",
                style: TextStyle(color: element?.color ?? Colors.black),
              ))
          .toList(),
      if (routes.length == maxRoutes) const Text("...")
    ]);
  }
}
