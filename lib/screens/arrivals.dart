import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:fuzzy/fuzzy.dart';
import 'package:intl/intl.dart';
import 'package:now8/data.dart';
import 'package:now8/domain.dart';
import 'package:now8/providers.dart';
import 'package:now8/icons.dart';
import 'package:now8/screens/common.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'dart:developer';

final cacheManager = DefaultCacheManager();

class ArrivalsScreen extends StatelessWidget {
  const ArrivalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      body: const ArrivalsScreenBody(),
      appBarTitle: "Arrivals",
    );
  }
}

class ArrivalsScreenBody extends StatelessWidget {
  const ArrivalsScreenBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: stops(
            Provider.of<CurrentCityProvider>(context)
                .city
                .toString()
                .split('.')
                .last,
            cacheManager),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            List<dynamic> stops = [];
            snapshot.data.forEach((key, value) => stops.add(value));
            return Column(children: [
              Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Stop:",
                        style: Theme.of(context).textTheme.headline6,
                      ))),
              Container(
                padding: const EdgeInsets.all(20.0),
                child: DropdownSearch<dynamic>(
                    mode: Mode.BOTTOM_SHEET,
                    dropdownSearchDecoration: InputDecoration(
                      hintText: "Select a stop...",
                      hintStyle: Theme.of(context).textTheme.bodyText1,
                    ),
                    showSearchBox: true,
                    dropdownBuilder: (BuildContext context, dynamic stop) {
                      if (stop == null) {
                        return Container();
                      }
                      return ListTile(
                        leading: const Icon(Icons.commute),
                        title: Text(stop["name"]),
                        trailing: Text(stop["code"]),
                      );
                    },
                    popupItemBuilder: (BuildContext context, dynamic stop, _) {
                      if (stop == null) {
                        return Container();
                      }
                      return ListTile(
                        leading: const Icon(Icons.commute),
                        title: Text(stop["name"]),
                        trailing: Text(stop["code"]),
                      );
                    },
                    isFilteredOnline: true,
                    onFind: (String? filter) async {
                      final fuzzyStops = Fuzzy(stops,
                          options: FuzzyOptions(
                              threshold: 0.4,
                              findAllMatches: true,
                              shouldNormalize: true,
                              shouldSort: true,
                              tokenize: false,
                              keys: [
                                WeightedKey(
                                    name: "code",
                                    getter: (dynamic stop) => stop["code"],
                                    weight: 10),
                                WeightedKey(
                                    name: "name",
                                    getter: (dynamic stop) => stop["name"],
                                    weight: 1)
                              ]));
                      final List<dynamic> filteredStopsFuzzy =
                          fuzzyStops.search(filter ?? '');

                      return Future.value(
                          filteredStopsFuzzy.map((r) => r.item).toList());
                    },
                    onChanged: (dynamic stop) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ArrivalsScreenStop(stop: Stop.fromJson(stop)),
                        ),
                      );
                    }),
              )
            ]);
          }
        });
  }
}

class ArrivalsScreenStop extends StatelessWidget {
  const ArrivalsScreenStop({Key? key, required this.stop}) : super(key: key);

  final Stop stop;

  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      body: ArrivalsScreenStopBody(
        stop: stop,
      ),
      appBarTitle: '${stop.name} (${stop.code})',
      showDrawer: false,
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
    String cityName = Provider.of<CurrentCityProvider>(context)
        .city
        .toString()
        .split('.')
        .last;

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
  Map<Route, List<DateTime>> cardContent = {
    for (RouteWay routeWay in stop.routeWays)
      Route.fromJson(routes[routeWay.routeId]): []
  };

  for (VehicleEstimation vehicleEstimation in vehicleEstimations) {
    var key = cardContent.keys.firstWhere(
        (element) => element.id == vehicleEstimation.vehicle.routeWay.routeId,
        orElse: () =>
            Route.fromJson(routes[vehicleEstimation.vehicle.routeWay.routeId]));
    cardContent.update(
        key, (value) => [...value, vehicleEstimation.estimation.estimation],
        ifAbsent: () => [vehicleEstimation.estimation.estimation]);
  }

  cardContent.removeWhere((key, value) {
    for (var entry in cardContent.entries) {
      if (key != entry.key &&
          key.code == entry.key.code &&
          (value.length < entry.value.length || value.isEmpty)) {
        return true;
      }
    }
    return false;
  });

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
