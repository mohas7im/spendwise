import 'package:flutter/material.dart';
import '../models/fuel_entry.dart';

class FuelProvider with ChangeNotifier {
  final List<FuelEntry> _entries = [];

  List<FuelEntry> get entries => List.unmodifiable(_entries..sort((a, b) => b.date.compareTo(a.date)));

  FuelEntry? get lastEntry => _entries.isEmpty ? null : entries.first;

  // Average mileage (km/l) calculated from consecutive fill-ups
  double get averageMileage {
    if (_entries.length < 2) return 0.0;
    final sorted = [..._entries]..sort((a, b) => a.date.compareTo(b.date));
    double totalKm = 0;
    double totalLiters = 0;
    for (int i = 1; i < sorted.length; i++) {
      final kmDriven = sorted[i].odometer - sorted[i - 1].odometer;
      if (kmDriven > 0) {
        totalKm += kmDriven;
        totalLiters += sorted[i].liters;
      }
    }
    if (totalLiters == 0) return 0.0;
    return totalKm / totalLiters;
  }

  double get totalFuelSpend => _entries.fold(0, (s, e) => s + e.totalCost);

  double get totalLitersFilled => _entries.fold(0, (s, e) => s + e.liters);

  // Mileage for the most recent segment
  double get lastMileage {
    if (_entries.length < 2) return 0.0;
    final sorted = [..._entries]..sort((a, b) => a.date.compareTo(b.date));
    final last = sorted.last;
    final prev = sorted[sorted.length - 2];
    final km = last.odometer - prev.odometer;
    if (km <= 0 || last.liters <= 0) return 0.0;
    return km / last.liters;
  }

  void addEntry(FuelEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  void deleteEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
