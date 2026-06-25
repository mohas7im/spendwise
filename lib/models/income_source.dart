enum IncomeType { salary, freelance, investment, other }
enum IncomeFrequency { monthly, yearly, oneTime }

class IncomeSource {
  final String id;
  final String name;
  final double amount;
  final IncomeType type;
  final IncomeFrequency frequency;

  IncomeSource({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.frequency,
  });
}
