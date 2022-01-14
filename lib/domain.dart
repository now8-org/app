import 'package:flutter/material.dart';

enum City { madrid }

enum TransportType {
  tram,
  metro,
  rail,
  bus,
  ferry,
  cableTram,
  aerialLift,
  funicular,
  intercityBus,
  urbanBus,
  undefined10,
  trolleyBus,
  monorail
}

enum Way { outbound, inbound }

class RouteWay {
  late String routeId;
  late Way? way;

  RouteWay({
    required this.routeId,
    this.way,
  });

  RouteWay.fromJson(Map json) {
    routeId = json['id'];
    way = json['way'] != null ? Way.values[json['way']] : null;
  }
}

class Stop {
  late String id;
  late String code;
  late String name;
  late double longitude;
  late double latitude;
  late String? zone;
  late List<RouteWay> routeWays;

  Stop({
    required this.id,
    required this.code,
    required this.name,
    required this.longitude,
    required this.latitude,
    this.zone,
    required this.routeWays,
  });

  Stop.fromJson(Map json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    zone = json['zone'];
    routeWays = List<RouteWay>.from(
        json['route_ways'].map((var value) => RouteWay.fromJson(value)));
  }
}

class Route {
  late String id;
  late String code;
  late TransportType transportType;
  late String name;
  late Color? color;

  Route({
    required this.id,
    required this.code,
    required this.transportType,
    required this.name,
    this.color,
  });

  Route.fromJson(Map json) {
    id = json['id'];
    code = json['code'];
    transportType = TransportType.values[json['transport_type']];
    name = json['name'];
    color =
        Color(int.parse(json['color'].substring(0, 6), radix: 16) + 0xFF000000);
  }
}

class Vehicle {
  late String? id;
  late RouteWay routeWay;
  late String? name;

  Vehicle({
    this.id,
    required this.routeWay,
    this.name,
  });

  Vehicle.fromJson(Map json) {
    id = json['id'];
    routeWay = RouteWay.fromJson(json["route_way"]);
    name = json['name'];
  }
}

class Estimation {
  late DateTime estimation;
  late DateTime time;

  Estimation({
    required this.estimation,
    required this.time,
  });

  Estimation.fromJson(Map json) {
    estimation = DateTime.parse(json['estimation']).toLocal();
    time = DateTime.parse(json['time']).toLocal();
  }
}

class VehicleEstimation {
  late Vehicle vehicle;
  late Estimation estimation;

  VehicleEstimation({required this.vehicle, required this.estimation});

  VehicleEstimation.fromJson(Map json) {
    vehicle = Vehicle.fromJson(json['vehicle']);
    estimation = Estimation.fromJson(json['estimation']);
  }
}
