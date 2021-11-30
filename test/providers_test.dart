import 'package:now8/domain.dart';
import 'package:now8/providers.dart';
import 'package:test/test.dart';

void main() {
  test('Default city should be Madrid', () {
    final City city = CurrentCityProvider().city;

    expect(city, City.madrid);
  });
}
