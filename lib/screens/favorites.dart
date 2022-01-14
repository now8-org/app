import 'package:flutter/material.dart';
import 'package:now8/providers.dart';
import 'package:now8/screens/common.dart';
import 'package:provider/provider.dart';
import 'package:now8/domain.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      body: const FavoritesScreenBody(),
      appBarTitle: "Favorites",
    );
  }
}

class FavoritesScreenBody extends StatelessWidget {
  const FavoritesScreenBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> favoriteStopIds =
        Provider.of<FavoriteStopIdsProvider>(context).favortiteStopIds;
    if (favoriteStopIds.isEmpty) {
      return const Center(
          child: Text("You don't have any favorite stops yet."));
    } else {
      return Container(
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
            itemCount: favoriteStopIds.length,
            itemBuilder: favoriteStopListItemBuilder,
          ));
    }
  }
}

Widget favoriteStopListItemBuilder(BuildContext context, int index) {
  List<String> favoriteStopIds =
      Provider.of<FavoriteStopIdsProvider>(context).favortiteStopIds;
  Stop? stop =
      Provider.of<StopsProvider>(context).getStop(favoriteStopIds[index]);
  return Card(
      child: InkWell(
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: (stop != null)
          ? StopListTile(
              stop: stop,
            )
          : Container(),
    ),
    onTap: () {
      Navigator.pushNamed(
        context,
        "/stop/${stop?.id ?? ""}",
      );
    },
  ));
}
