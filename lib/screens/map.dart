import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:now8/providers.dart';
import 'package:now8/screens/common.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      body: const MapScreenBody(),
      appBarTitle: AppLocalizations.of(context)!.menuMap,
    );
  }
}

class MapScreenBody extends StatelessWidget {
  const MapScreenBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic>? stops = Provider.of<StopsProvider>(context).stops;
    if (stops == null) {
      return const Center(child: CircularProgressIndicator());
    }
    var markers = stops
        .map((var stop) => Marker(
              point: LatLng(stop["latitude"], stop["longitude"]),
              builder: (ctx) => Icon(Icons.pin_drop),
            ))
        .toList();
    //var markers = [
    //  Marker(
    //    anchorPos: AnchorPos.align(AnchorAlign.center),
    //    height: 30,
    //    width: 30,
    //    point: LatLng(53.3498, -6.2603),
    //    builder: (ctx) => Icon(Icons.pin_drop),
    //  ),
    //];
    return FlutterMap(
      options: MapOptions(
        center: LatLng(40.4165, -3.70256),
        zoom: 13.0,
        plugins: [
          MarkerClusterPlugin(),
        ],
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
          attributionBuilder: (_) {
            return Text("© OpenStreetMap contributors");
          },
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(40.4165, -3.70256),
              builder: (ctx) => Container(
                child: FlutterLogo(),
              ),
            ),
          ],
        ),
        MarkerClusterLayerOptions(
          maxClusterRadius: 120,
          size: Size(40, 40),
          fitBoundsOptions: FitBoundsOptions(
            padding: EdgeInsets.all(50),
          ),
          markers: markers,
          polygonOptions: PolygonOptions(
              borderColor: Colors.blueAccent,
              color: Colors.black12,
              borderStrokeWidth: 3),
          builder: (context, markers) {
            return FloatingActionButton(
              child: Text(markers.length.toString()),
              onPressed: null,
            );
          },
        ),
      ],
    );
  }
}
