import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:fuzzy/fuzzy.dart';
import 'package:now8/domain.dart';
import 'package:now8/providers.dart';
import 'package:now8/screens/common.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    List<dynamic>? stops = Provider.of<StopsProvider>(context).stops;
    if (stops == null) {
      return const Center(child: CircularProgressIndicator());
    }
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
              return StopListTile(
                stop: Stop.fromJson(stop),
                isFavorite: Provider.of<FavoriteStopIdsProvider>(context)
                    .contains(stop["id"]),
              );
            },
            popupItemBuilder: (BuildContext context, dynamic stop, _) {
              if (stop == null) {
                return Container();
              }
              return StopListTile(
                stop: Stop.fromJson(stop),
                isFavorite: Provider.of<FavoriteStopIdsProvider>(context)
                    .contains(stop["id"]),
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
              Navigator.pushNamed(
                context,
                "/stop/${stop['id']}",
              );
            }),
      )
    ]);
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
