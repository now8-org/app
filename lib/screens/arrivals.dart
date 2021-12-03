import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:intl/intl.dart';
import 'package:now8/data.dart';
import 'package:now8/domain.dart';
import 'package:now8/providers.dart';
import 'package:now8/screens/common.dart';
import 'package:provider/provider.dart';

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
        future: stops(Provider.of<CurrentCityProvider>(context)
            .city
            .toString()
            .split('.')
            .last),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Column(children: [
              Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Stop:",
                        style: Theme.of(context).textTheme.headline5,
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
                        leading: const Icon(Icons.directions_bus_filled),
                        title: Text(stop["name"]),
                        trailing: Text(stop["id"]),
                      );
                    },
                    popupItemBuilder: (BuildContext context, dynamic stop, _) {
                      if (stop == null) {
                        return Container();
                      }
                      return ListTile(
                        leading: const Icon(Icons.directions_bus_filled),
                        title: Text(stop["name"]),
                        trailing: Text(stop["id"]),
                      );
                    },
                    isFilteredOnline: true,
                    onFind: (String? filter) async {
                      final fuzzyStops = Fuzzy(snapshot.data ?? [],
                          options: FuzzyOptions(
                              threshold: 0.4,
                              findAllMatches: true,
                              shouldNormalize: true,
                              shouldSort: true,
                              tokenize: true,
                              keys: [
                                WeightedKey(
                                    name: "id",
                                    getter: (dynamic stop) => stop["id"],
                                    weight: 1),
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
                          builder: (context) => ArrivalsScreenStop(
                              stop: Stop(id: stop["id"], name: stop["name"])),
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
      appBarTitle: '${stop.name} (${stop.id})',
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
        future: futureVehicleEstimations,
        builder: (context, AsyncSnapshot<List<VehicleEstimation>> snapshot) {
          if (!snapshot.hasData & !snapshot.hasError) {
            return const Center(child: CircularProgressIndicator());
          } else {
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
                    children: generateArrivalCards(snapshot.data ?? []),
                    physics: const AlwaysScrollableScrollPhysics(),
                  ),
                  triggerMode: RefreshIndicatorTriggerMode.anywhere,
                ));
          }
        });
  }
}

List<ArrivalCard> generateArrivalCards(
    List<VehicleEstimation> vehicleEstimations) {
  const int nEstimations = 3;
  List<ArrivalCard> arrivalCards = [];
  Map<String, List<DateTime>> cardContent = {};

  for (VehicleEstimation vehicleEstimation in vehicleEstimations) {
    cardContent.putIfAbsent(vehicleEstimation.vehicle.line.id, () => []);
    cardContent.update(vehicleEstimation.vehicle.line.id,
        (value) => [...value, vehicleEstimation.estimation.estimation]);
  }

  cardContent.forEach((key, value) {
    arrivalCards.add(
        ArrivalCard(line: key, estimations: value.take(nEstimations).toList()));
  });

  return arrivalCards;
}

class ArrivalCard extends StatelessWidget {
  final String line;
  final List<DateTime> estimations;

  const ArrivalCard({Key? key, required this.line, required this.estimations})
      : super(key: key);

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
                      const Icon(Icons.directions_bus),
                      Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(line,
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
