import 'dart:convert';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:now8/domain.dart';

Future<List<dynamic>> stops(String cityName) async {
  File stopsFile = await DefaultCacheManager()
      .getSingleFile("https://api.now8.systems/$cityName/v3/stop");
  String stopsJson = await stopsFile.readAsString();

  return jsonDecode(stopsJson);
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
                DateTime.parse(vehicleEstimation['estimation']!['estimation'])
                    .toLocal(),
            time: DateTime.parse(vehicleEstimation['estimation']!['time'])
                .toLocal(),
          )));
    }

    return vehicleEstimations;
  } else {
    throw Exception('Failed to load stop arrivals estimations.');
  }
}
