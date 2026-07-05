/// Total price for a booking. Kept in domain so the rule has one home.
double calculatePrice({
  required double pricePerHour,
  required int durationHours,
}) {
  if (durationHours < 1) {
    throw ArgumentError.value(durationHours, 'durationHours', 'must be >= 1');
  }
  return pricePerHour * durationHours;
}
