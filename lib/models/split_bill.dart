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

class SplitItem {
  final String id;
  String name;
  double amount;
  String paidByPersonId;
  
  bool isEquallySplit;
  // If equal split, just track who was involved
  List<String> sharedByPersonIds;
  
  // If unequal split, track exact amount each person owes for this item
  Map<String, double> exactAmountsOwed;

  SplitItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.paidByPersonId,
    this.isEquallySplit = true,
    this.sharedByPersonIds = const [],
    this.exactAmountsOwed = const {},
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
