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

class Stop {
  late String id;
  late String code;
  late String name;
  late double longitude;
  late double latitude;
  late String zone;
  late Map<String, Line> lines;

  Stop({
    required this.id,
    required this.code,
    required this.name,
    required this.longitude,
    required this.latitude,
    required this.zone,
    required this.lines,
  });

  Stop.fromJson(Map json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    zone = json['zone'];
    lines = {
      for (var entry in json['lines'].entries)
        entry.key: Line.fromJson({
          ...{"id": entry.key},
          ...entry.value,
        }),
    };
  }
}

class Line {
  late String id;
  late String code;
  late TransportType transportType;
  late String name;
  late Way? way;
  late Color? color;

  Line({
    required this.id,
    required this.code,
    required this.transportType,
    required this.name,
    this.way,
    this.color,
  });

  Line.fromJson(Map json) {
    id = json['id'];
    code = json['code'];
    transportType = TransportType.values[json['transport_type']];
    name = json['name'];
    way = Way.values[json['way']];
    color =
        Color(int.parse(json['color'].substring(1, 7), radix: 16) + 0xFF000000);
  }
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
