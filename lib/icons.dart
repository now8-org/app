import 'package:flutter/material.dart';
import 'package:now8/domain.dart';

IconData getIcon(TransportType? transportType) {
  switch (transportType) {
    case TransportType.bus:
      return Icons.directions_bus;
    case TransportType.intercityBus:
      return Icons.directions_bus;
    case TransportType.urbanBus:
      return Icons.directions_bus;
    case TransportType.metro:
      return Icons.subway;
    case TransportType.rail:
      return Icons.train;
    case TransportType.tram:
      return Icons.tram;
    case TransportType.ferry:
      return Icons.directions_boat;
    case TransportType.monorail:
      return Icons.directions_railway;
    case TransportType.cableTram:
      return Icons.tram;
    default:
      return Icons.commute;
  }
}
