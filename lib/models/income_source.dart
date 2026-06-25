enum IncomeType { salary, freelance, investment, other }
enum IncomeFrequency { monthly, yearly, oneTime }

class IncomeSource {
  final String id;
  final String name;
  final double amount;
  final IncomeType type;
  final IncomeFrequency frequency;
  final int? creditDate; // Day of the month (1-31)
  DateTime? lastCredited;

  IncomeSource({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.frequency,
    this.creditDate,
    this.lastCredited,
  });

  IncomeSource copyWith({
    String? id,
    String? name,
    double? amount,
    IncomeType? type,
    IncomeFrequency? frequency,
    int? creditDate,
    DateTime? lastCredited,
  }) {
    return IncomeSource(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      creditDate: creditDate ?? this.creditDate,
      lastCredited: lastCredited ?? this.lastCredited,
    );
  }
}
