import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

enum City { madrid }

void main() => runApp(const MyApp());

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
        currentCity.onChange();
      },
    );
  }
}

class CurrentCityProvider extends ChangeNotifier {
  City city = City.madrid;

  void onChange() {
    notifyListeners();
  }
}

class VehicleEstimationsError implements Exception {
  String cause;
  VehicleEstimationsError(this.cause);
}

class ScreenTemplate extends StatelessWidget {
  final Widget body;
  final String appBarTitle;
  final bool showDrawer;

  final Widget drawer = const DefaultDrawer();

  const ScreenTemplate(
      {Key? key,
      required this.body,
      required this.appBarTitle,
      this.showDrawer = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
      ),
      drawer: showDrawer ? drawer : null,
      body: body,
    );
  }
}

class DefaultDrawer extends StatelessWidget {
  const DefaultDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Center(child: CityDropdown())),
          ListTile(
            title: const Text("Arrivals"),
            onTap: ModalRoute.of(context)?.settings.name == "/arrivals"
                ? null
                : () {
                    Navigator.of(context).pushNamed('/arrivals');
                  },
          ),
        ],
      ),
    );
  }
}

class WelcomeScreenBody extends StatelessWidget {
  const WelcomeScreenBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(40.0),
        child: ListView(children: [
          Text("Welcome to now8!",
              style: Theme.of(context).textTheme.headline4!,
              textAlign: TextAlign.center),
          Container(
              margin: const EdgeInsets.only(top: 40),
              child: Text(
                "now8 is a public transport app that provides "
                "improved vehicle arrival time estimations "
                "using Machine Learning.",
                style: Theme.of(context).textTheme.headline6!,
              ))
        ]));
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ScreenTemplate(
      body: WelcomeScreenBody(),
      appBarTitle: "now8",
    );
  }
}

class ArrivalsScreen extends StatelessWidget {
  const ArrivalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ScreenTemplate(
      body: ArrivalsScreenBody(),
      appBarTitle: "Arrivals",
    );
  }
}

Future<List<dynamic>> stops() async {
  File stopsFile = await DefaultCacheManager()
      .getSingleFile("https://api.now8.systems/madrid/v3/stop");
  String stopsJson = await stopsFile.readAsString();

  return jsonDecode(stopsJson);
}

class ArrivalsScreenBody extends StatelessWidget {
  const ArrivalsScreenBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: stops(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Column(children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                child: DropdownSearch<dynamic>(
                    mode: Mode.BOTTOM_SHEET,
                    showSearchBox: true,
                    dropdownBuilder: (BuildContext context, dynamic stop) {
                      if (stop == null) {
                        return Container();
                      }
                      return ListTile(
                          title: Text('${stop["name"]} (${stop["id"]})'));
                    },
                    popupItemBuilder: (BuildContext context, dynamic stop, _) {
                      if (stop == null) {
                        return Container();
                      }
                      return ListTile(
                          title: Text('${stop["name"]} (${stop["id"]})'));
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
            padding: const EdgeInsets.all(5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(line,
                          style: Theme.of(context).textTheme.headline5)),
                ),
                ...estimations
                    .map((estimation) => Expanded(
                          flex: 2,
                          child: Card(
                              child: Column(
                            children: [
                              Container(
                                child:
                                    Text(DateFormat('kk:mm').format(estimation),
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        )),
                                padding: const EdgeInsets.all(5.0),
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                          )),
                        ))
                    .toList()
              ],
            )));
  }
}

class Stop {
  final String id;
  final String? transportType;
  final String? name;

  Stop({
    required this.id,
    this.transportType,
    this.name,
  });
}

class Line {
  final String id;
  final String transportType;
  final String name;

  Line({
    required this.id,
    required this.transportType,
    required this.name,
  });
}

class Vehicle {
  final String id;
  final Line line;
  final String name;

  Vehicle({
    required this.id,
    required this.line,
    required this.name,
  });
}

class Estimation {
  final DateTime estimation;
  final DateTime time;

  Estimation({
    required this.estimation,
    required this.time,
  });
}

class VehicleEstimation {
  final Vehicle vehicle;
  final Estimation estimation;

  VehicleEstimation(this.vehicle, this.estimation);
}

Future<List<VehicleEstimation>> fetchVehicleEstimations(
    String cityName, String stopCode) async {
  final response = await http.get(Uri.parse(
      'https://api.now8.systems/$cityName/v3/stop/$stopCode/estimation'));

  if (response.statusCode == 200) {
    List<dynamic> json = jsonDecode(response.body);
    List<VehicleEstimation> vehicleEstimations = [];

    for (final vehicleEstimation in json) {
      vehicleEstimations.add(VehicleEstimation(
          Vehicle(
              id: vehicleEstimation['vehicle']!['id'],
              line: Line(
                id: vehicleEstimation['vehicle']!['line']!['id'],
                transportType: vehicleEstimation['vehicle']!['line']
                    ['transport_type'],
                name: vehicleEstimation['vehicle']!['line']['name'],
              ),
              name: vehicleEstimation['vehicle']!['name']),
          Estimation(
            estimation:
                DateTime.parse(vehicleEstimation['estimation']!['estimation']),
            time: DateTime.parse(vehicleEstimation['estimation']!['time']),
          )));
    }

    return vehicleEstimations;
  } else {
    throw Exception('Failed to load stop arrivals estimations.');
  }
}
