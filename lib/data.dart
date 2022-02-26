import 'dart:convert';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:now8/domain.dart';

const String apiBaseUrl = 'https://api.now8.systems';
const String apiVersion = 'v5';

/// Get a map of stop ids to stop info maps..
Future<dynamic> stops(String cityName, BaseCacheManager cacheManager) async {
  File stopsFile = await cacheManager
      .getSingleFile("$apiBaseUrl/$cityName/$apiVersion/stop");
  String stopsJson = await stopsFile.readAsString();

  return jsonDecode(stopsJson);
}

/// Get a map of route ids to route info maps..
Future<dynamic> routes(String cityName, BaseCacheManager cacheManager) async {
  File routesFile = await cacheManager
      .getSingleFile("$apiBaseUrl/$cityName/$apiVersion/route");
  String routesJson = await routesFile.readAsString();

  return jsonDecode(routesJson);
}

Future<List<VehicleEstimation>> fetchVehicleEstimations(
    String cityName, String stopCode) async {
  final response = await http.get(
      Uri.parse('$apiBaseUrl/$cityName/$apiVersion/stop/$stopCode/estimation'));

  if (response.statusCode == 200) {
    List<dynamic> json = jsonDecode(response.body);
    List<VehicleEstimation> vehicleEstimations = [];

    for (final vehicleEstimation in json) {
      vehicleEstimations.add(VehicleEstimation.fromJson(vehicleEstimation));
    }

    return vehicleEstimations;
  } else {
    throw Exception('Failed to load stop arrivals estimations.');
  }
}
