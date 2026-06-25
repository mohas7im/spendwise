import 'package:flutter/material.dart';
import '../models/split_bill.dart';

class SplitProvider extends ChangeNotifier {
  final List<SplitPerson> _people = [];
  final List<SplitItem> _items = [];
  List<Settlement> _settlements = [];

  List<SplitPerson> get people => _people;
  List<SplitItem> get items => _items;
  List<Settlement> get settlements => _settlements;

  // Pre-seed for demo
  SplitProvider() {
    _people.add(SplitPerson(id: 'me', name: 'Me'));
  }

  void addPerson(String name) {
    _people.add(SplitPerson(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name));
    notifyListeners();
  }

  void removePerson(String id) {
    if (id == 'me') return; // Cannot remove self
    _people.removeWhere((p) => p.id == id);
    // Remove person from all items too
    for (var item in _items) {
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
    _items.add(item);
    _calculateSettlements();
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((i) => i.id == id);
    _calculateSettlements();
    notifyListeners();
  }

  // The engine that calculates who owes whom
  void _calculateSettlements() {
    // 1. Calculate net balance for each person
    Map<String, double> netBalances = {for (var p in _people) p.id: 0.0};

    for (var item in _items) {
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
    _settlements = _simplifyDebts(netBalances);
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
    try {
      return _people.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
