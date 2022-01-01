import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:now8/domain.dart';
import 'package:now8/data.dart' as data;
import 'package:shared_preferences/shared_preferences.dart';

class CurrentCityProvider extends ChangeNotifier {
  late SharedPreferences _sharedPreferences;
  late City _city;

  CurrentCityProvider(String cityName, SharedPreferences sharedPreferences) {
    this.cityName = cityName;
    _sharedPreferences = sharedPreferences;
  }

  String get cityName {
    return _city.name;
  }

  City get city => _city;

  set city(City city) {
    _city = city;
    onChange();
  }

  set cityName(String cityName) {
    _city = City.values.firstWhere((e) => e.name == cityName);
  }

  void onChange() {
    _sharedPreferences.setString("city_name", cityName);
    notifyListeners();
  }
}

class StopsProvider extends ChangeNotifier {
  Map? _stops;
  String? _cityName;
  final BaseCacheManager _cacheManager;

  StopsProvider(this._cacheManager);

  void update(CurrentCityProvider currentCityProvider) {
    _cityName = currentCityProvider.cityName;
    _fetch();
  }

  void _fetch() async {
    _stops = _cityName == null
        ? null
        : Map.from(await data.stops(_cityName!, _cacheManager));
    onChange();
  }

  List<dynamic>? get stops {
    return _stops?.values.toList();
  }

  Stop? getStop(String stopId) {
    if (_stops == null) {
      return null;
    }

    return _stops!.containsKey(stopId) ? Stop.fromJson(_stops![stopId]) : null;
  }

  void onChange() {
    notifyListeners();
  }
}

class FavoriteStopIdsProvider extends ChangeNotifier {
  List<String> favortiteStopIds = [];
  late SharedPreferences _sharedPreferences;
  final String _key = "favorite_stop_ids";

  FavoriteStopIdsProvider({required SharedPreferences sharedPreferences}) {
    _sharedPreferences = sharedPreferences;
    setup();
  }

  void setup() {
    favortiteStopIds = _sharedPreferences.getStringList(_key) ?? [];
    notifyListeners();
  }

  void add(String item) {
    favortiteStopIds.add(item);
    onChange();
  }

  void remove(String item) {
    favortiteStopIds.remove(item);
    onChange();
  }

  bool contains(String item) {
    return favortiteStopIds.contains(item);
  }

  void onChange() {
    _sharedPreferences.setStringList(_key, favortiteStopIds);
    notifyListeners();
  }
}
