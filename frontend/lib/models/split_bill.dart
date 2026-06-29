enum SplitMethod { equal, exact, percentage, shares, itemized }

class SplitPerson {
  final String id;
  String name;
  String avatarUrl;

  SplitPerson({
    required this.id,
    required this.name,
    this.avatarUrl = 'https://i.pravatar.cc/150',
  });
}

class FoodItem {
  final String id;
  String name;
  double price;
  int quantity;
  List<String> sharedByPersonIds;

  FoodItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.sharedByPersonIds = const [],
  });
  
  double get total => price * quantity;
}

class SplitItem {
  final String id;
  String name;
  double amount;
  String paidByPersonId;
  DateTime date;
  String category;
  String? notes;
  
  SplitMethod splitMethod;
  List<String> sharedByPersonIds; // For equal split
  Map<String, double> splitValues; // Raw inputs for exact, percentage, or shares
  Map<String, double> exactAmountsOwed; // Calculated final amounts owed
  List<FoodItem> foodItems; // For itemized split

  SplitItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.paidByPersonId,
    required this.date,
    required this.category,
    this.notes,
    this.splitMethod = SplitMethod.equal,
    this.sharedByPersonIds = const [],
    this.splitValues = const {},
    this.exactAmountsOwed = const {},
    this.foodItems = const [],
  });
}

class Settlement {
  final String fromPersonId;
  final String toPersonId;
  final double amount;

  Settlement({
    required this.fromPersonId,
    required this.toPersonId,
    required this.amount,
  });
}

class Trip {
  final String id;
  String name;
  String currency;
  DateTime date;
  List<SplitPerson> participants;
  List<SplitItem> expenses;
  List<Settlement> settlements;

  Trip({
    required this.id,
    required this.name,
    this.currency = '₹',
    required this.date,
    this.participants = const [],
    this.expenses = const [],
    this.settlements = const [],
  });

  double get totalExpense => expenses.fold(0, (sum, e) => sum + e.amount);
}

