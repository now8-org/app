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
      return ListView.builder(
          itemCount: favoriteStopIds.length,
          itemBuilder: (BuildContext context, int index) => StopListTile(
              stop: Provider.of<StopsProvider>(context)
                  .getStop(favoriteStopIds[index])));
    }
  }
}

class StopListTile extends StatelessWidget {
  final Stop? stop;
  const StopListTile({Key? key, required this.stop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(stop?.name ?? "..."),
    );
  }
}
