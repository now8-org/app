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
        currentCity.onChange();
      },
    );
  }
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
