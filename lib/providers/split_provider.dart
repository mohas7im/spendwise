import 'package:flutter/material.dart';
import '../models/split_bill.dart';

class SplitProvider extends ChangeNotifier {
  final List<Trip> _trips = [];
  String? _activeTripId;

  SplitProvider() {
    // Pre-seed a demo trip
    final demoTrip = Trip(
      id: 'demo_trip_1',
      name: 'Weekend Getaway',
      date: DateTime.now(),
      participants: [SplitPerson(id: 'me', name: 'Me')],
    );
    _trips.add(demoTrip);
    _activeTripId = demoTrip.id;
  }

  List<Trip> get trips => _trips;
  
  Trip? get activeTrip {
    if (_activeTripId == null) return null;
    try {
      return _trips.firstWhere((t) => t.id == _activeTripId);
    } catch (_) {
      return null;
    }
  }

  List<SplitPerson> get people => activeTrip?.participants ?? [];
  List<SplitItem> get items => activeTrip?.expenses ?? [];
  List<Settlement> get settlements => activeTrip?.settlements ?? [];

  void setActiveTrip(String id) {
    _activeTripId = id;
    notifyListeners();
  }

  void createTrip(String name, String currency) {
    final trip = Trip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      currency: currency,
      date: DateTime.now(),
      participants: [SplitPerson(id: 'me', name: 'Me')],
    );
    _trips.add(trip);
    notifyListeners();
  }

  void deleteTrip(String id) {
    _trips.removeWhere((t) => t.id == id);
    if (_activeTripId == id) {
      _activeTripId = _trips.isNotEmpty ? _trips.first.id : null;
    }
    notifyListeners();
  }

  void addPerson(String name) {
    if (activeTrip == null) return;
    activeTrip!.participants.add(SplitPerson(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name));
    notifyListeners();
  }

  void editPerson(String id, String newName) {
    if (activeTrip == null) return;
    final index = activeTrip!.participants.indexWhere((p) => p.id == id);
    if (index != -1) {
      activeTrip!.participants[index].name = newName;
      notifyListeners();
    }
  }

  void removePerson(String id) {
    if (activeTrip == null || id == 'me') return; // Cannot remove self
    activeTrip!.participants.removeWhere((p) => p.id == id);
    // Remove person from all items too
    for (var item in activeTrip!.expenses) {
      if (item.paidByPersonId == id) {
        item.paidByPersonId = 'me';
      }
      item.sharedByPersonIds.remove(id);
      item.exactAmountsOwed.remove(id);
    }
    _calculateSettlements();
    notifyListeners();
  }

  void addItem(SplitItem item) {
    if (activeTrip == null) return;
    activeTrip!.expenses.add(item);
    _calculateSettlements();
    notifyListeners();
  }

  void updateItem(SplitItem item) {
    if (activeTrip == null) return;
    final index = activeTrip!.expenses.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      activeTrip!.expenses[index] = item;
      _calculateSettlements();
      notifyListeners();
    }
  }

  void removeItem(String id) {
    if (activeTrip == null) return;
    activeTrip!.expenses.removeWhere((i) => i.id == id);
    _calculateSettlements();
    notifyListeners();
  }

  // The engine that calculates who owes whom
  void _calculateSettlements() {
    if (activeTrip == null) return;
    final trip = activeTrip!;

    // 1. Calculate net balance for each person
    Map<String, double> netBalances = {for (var p in trip.participants) p.id: 0.0};

    for (var item in trip.expenses) {
      // Add to the payer's balance (they are owed this amount)
      if (netBalances.containsKey(item.paidByPersonId)) {
        netBalances[item.paidByPersonId] = netBalances[item.paidByPersonId]! + item.amount;
      }

      // Subtract from the sharers' balances (they owe this amount)
      item.exactAmountsOwed.forEach((personId, owedAmount) {
        if (netBalances.containsKey(personId)) {
          netBalances[personId] = netBalances[personId]! - owedAmount;
        }
      });
    }

    // 2. Simplify Debts
    trip.settlements = _simplifyDebts(netBalances);
  }

  List<Settlement> _simplifyDebts(Map<String, double> balances) {
    List<Settlement> result = [];
    
    // Separate into debtors (negative balance) and creditors (positive balance)
    List<MapEntry<String, double>> debtors = balances.entries.where((e) => e.value < -0.01).toList();
    List<MapEntry<String, double>> creditors = balances.entries.where((e) => e.value > 0.01).toList();

    // Sort by amount to settle largest debts first
    debtors.sort((a, b) => a.value.compareTo(b.value));
    creditors.sort((a, b) => b.value.compareTo(a.value));

    int i = 0; // debtors index
    int j = 0; // creditors index

    while (i < debtors.length && j < creditors.length) {
      String debtorId = debtors[i].key;
      double debtAmount = -debtors[i].value;

      String creditorId = creditors[j].key;
      double creditAmount = creditors[j].value;

      double settlementAmount = debtAmount < creditAmount ? debtAmount : creditAmount;

      result.add(Settlement(
        fromPersonId: debtorId,
        toPersonId: creditorId,
        amount: settlementAmount,
      ));

      // Update balances
      debtors[i] = MapEntry(debtorId, -(debtAmount - settlementAmount));
      creditors[j] = MapEntry(creditorId, creditAmount - settlementAmount);

      if (-debtors[i].value < 0.01) i++;
      if (creditors[j].value < 0.01) j++;
    }

    return result;
  }

  SplitPerson? getPerson(String id) {
    if (activeTrip == null) return null;
    try {
      return activeTrip!.participants.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
