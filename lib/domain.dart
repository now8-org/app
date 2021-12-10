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

class Stop {
  final String id;
  final String? code;
  final String? transportType;
  final String? name;

  Stop({
    required this.id,
    this.code,
    this.transportType,
    this.name,
  });
}

class Line {
  final String id;
  final TransportType transportType;
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
