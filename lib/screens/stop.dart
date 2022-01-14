import 'package:provider/provider.dart';
import 'package:now8/providers.dart';
import 'package:now8/screens/common.dart';
import 'package:now8/domain.dart';
import 'package:now8/data.dart';
import 'package:flutter/material.dart' hide Route;
import 'dart:developer';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'package:now8/icons.dart';

final cacheManager = DefaultCacheManager();

class StopScreen extends StatelessWidget {
  final String stopId;
  const StopScreen({Key? key, required this.stopId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Stop stop = Provider.of<StopsProvider>(context).getStop(stopId) ??
        Stop(
            id: "...",
            code: "...",
            name: "...",
            latitude: 0.0,
            longitude: 0.0,
            routeWays: [],
            zone: "...");

    return ScreenTemplate(
      body: ArrivalsScreenStopBody(
        stop: stop,
      ),
      appBarTitle: '${stop.name} (${stop.code})',
      showDrawer: false,
      actions: [FavoriteIconButton(stop: stop)],
    );
  }
}

class ArrivalsScreenStopBody extends StatefulWidget {
  const ArrivalsScreenStopBody({Key? key, required this.stop})
      : super(key: key);

  final Stop stop;

  @override
  State<ArrivalsScreenStopBody> createState() => _ArrivalsScreenStopBodyState();
}

class _ArrivalsScreenStopBodyState extends State<ArrivalsScreenStopBody> {
  @override
  Widget build(BuildContext context) {
    String cityName = Provider.of<CurrentCityProvider>(context).cityName;

    Future<List<VehicleEstimation>> futureVehicleEstimations =
        fetchVehicleEstimations(cityName, widget.stop.id);

    return FutureBuilder(
        future: Future.wait(
            [futureVehicleEstimations, routes(cityName, cacheManager)]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasError) {
            log(
              snapshot.error.toString(),
              name: 'screens.arrivals._ArrivalsScreenStopBodyState',
            );
            return const Center(
                child: Text("Error fetching arrival times. Try again later."));
          } else if (snapshot.hasData) {
            return Container(
                padding: const EdgeInsets.all(10.0),
                child: RefreshIndicator(
                  onRefresh: () async {
                    List<VehicleEstimation> vehicleEstimations =
                        await fetchVehicleEstimations(cityName, widget.stop.id);
                    setState(() {
                      futureVehicleEstimations =
                          Future.value(vehicleEstimations);
                    });
                  },
                  child: ListView(
                    children: generateArrivalCards(
                        snapshot.data![0], widget.stop, snapshot.data![1]),
                    physics: const AlwaysScrollableScrollPhysics(),
                  ),
                  triggerMode: RefreshIndicatorTriggerMode.anywhere,
                ));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}

List<ArrivalCard> generateArrivalCards(
    List<VehicleEstimation> vehicleEstimations, Stop stop, dynamic routes) {
  const int nEstimations = 3;
  List<ArrivalCard> arrivalCards = [];
  Map<Route, List<DateTime>> cardContent = {};

  for (VehicleEstimation vehicleEstimation in vehicleEstimations) {
    var key = cardContent.keys.firstWhere(
        (element) => element.id == vehicleEstimation.vehicle.routeWay.routeId,
        orElse: () =>
            Route.fromJson(routes[vehicleEstimation.vehicle.routeWay.routeId]));
    cardContent.update(
        key, (value) => [...value, vehicleEstimation.estimation.estimation],
        ifAbsent: () => [vehicleEstimation.estimation.estimation]);
  }

  // The following code would add routes that don't have estimations
  // at the moment. It's commented out because `stop` contains routes
  // that it shouldn't.
  /*for (RouteWay routeWay in stop.routeWays) {
    if (cardContent.keys
            .firstWhereOrNull((element) => element.id == routeWay.routeId) ==
        null) {
      cardContent.putIfAbsent(
          Route.fromJson(routes[routeWay.routeId]), () => []);
    }
  }*/

  cardContent.forEach((key, value) {
    arrivalCards.add(ArrivalCard(
      route: key.code,
      estimations: value.take(nEstimations).toList(),
      icon: getIcon(key.transportType),
      iconColor: key.color,
    ));
  });

  return arrivalCards;
}

class ArrivalCard extends StatelessWidget {
  final String route;
  final List<DateTime> estimations;
  final IconData icon;
  final Color? iconColor;

  const ArrivalCard({
    Key? key,
    required this.route,
    required this.estimations,
    required this.icon,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    flex: 3,
                    child: Row(children: [
                      Icon(icon, color: iconColor),
                      Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(route,
                              style: Theme.of(context).textTheme.headline5)),
                    ])),
                ...estimations
                    .map(
                      (estimation) => Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Container(
                                child: Text(
                                  DateFormat('kk:mm').format(estimation),
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                                padding: const EdgeInsets.all(5.0),
                              ),
                              Container(
                                child: Text(
                                  "-",
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                                padding: const EdgeInsets.all(5.0),
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                          )),
                    )
                    .toList()
              ],
            )));
  }
}
