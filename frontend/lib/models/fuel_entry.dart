class FuelEntry {
  final String id;
  final DateTime date;
  final double liters;
  final double pricePerLiter;
  final double odometer; // km at time of fill-up
  final String? notes;

  FuelEntry({
    required this.id,
    required this.date,
    required this.liters,
    required this.pricePerLiter,
    required this.odometer,
    this.notes,
  });

  double get totalCost => liters * pricePerLiter;
}
