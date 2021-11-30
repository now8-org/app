import 'package:flutter/material.dart';
import 'package:now8/domain.dart';

class CurrentCityProvider extends ChangeNotifier {
  City city = City.madrid;

  void onChange() {
    notifyListeners();
  }
}
