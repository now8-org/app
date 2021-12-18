import 'package:test/test.dart';
import 'package:now8/data.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:now8/domain.dart';

void main() {
  group('stops', () {
    test(
        'GIVEN cityName = Madrid WHEN function is called THEN check result type.',
        () async {
      var result = await stops("madrid", DefaultCacheManager());
      expect(result, const TypeMatcher<Map<String, dynamic>>());
      result.forEach((key, value) => Stop.fromJson(value));
    });
  });

  group('routes', () {
    test(
        'GIVEN cityName = Madrid WHEN function is called THEN check result type.',
        () async {
      var result = await routes("madrid", DefaultCacheManager());
      expect(result, const TypeMatcher<Map<String, dynamic>>());
      result.forEach((key, value) => Route.fromJson(value));
    });
  });

  group('estimations', () {
    test(
        'GIVEN cityName = Madrid and stopCode = par_5_11 WHEN fetchVehicleEstimations is called THEN check result type.',
        () async {
      var result = await fetchVehicleEstimations("madrid", "par_5_11");
      expect(result, const TypeMatcher<List>());
    });
  });
}
