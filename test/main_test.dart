// Import the test package and Counter class
import 'package:test/test.dart';
import 'package:now8/main.dart';

void main() {
  test('Default city should be Madrid', () {
    final City city = CurrentCityProvider().city;

    expect(city, City.madrid);
  });
}
