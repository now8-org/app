import 'package:now8/domain.dart';
import 'package:now8/providers.dart';
import 'package:test/test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  test('Default city should be Madrid', () async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final City city = CurrentCityProvider("madrid", sharedPreferences).city;

    expect(city, City.madrid);
  });
}
