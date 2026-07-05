import 'package:courtly_client/domain/pricing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('price is pricePerHour times duration', () {
    expect(calculatePrice(pricePerHour: 30, durationHours: 2), 60);
  });

  test('throws on non-positive duration', () {
    expect(
      () => calculatePrice(pricePerHour: 30, durationHours: 0),
      throwsArgumentError,
    );
  });
}
