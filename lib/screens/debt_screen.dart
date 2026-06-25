import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../services/dummy_data_service.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> with SingleTickerProviderStateMixin {
  late List<DebtModel> debts;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    debts = DummyDataService.getDummyDebts();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<DebtModel> get iOweList => debts.where((d) => d.type == DebtType.iOwe && !d.isPaid).toList();
  List<DebtModel> get theyOweList => debts.where((d) => d.type == DebtType.theyOwe && !d.isPaid).toList();

  double get totalIOwe => iOweList.fold(0, (sum, d) => sum + d.amount);
  double get totalTheyOwe => theyOweList.fold(0, (sum, d) => sum + d.amount);
  double get netBalance => totalTheyOwe - totalIOwe;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Text('Debt Tracker', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    onPressed: _showAddDebtModal,
                    icon: const Icon(Icons.add_circle, color: Color(0xFF10B981), size: 28),
                  ),
                ],
              ),
            ),

            // Net Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _buildNetSummaryCard(),
            ),

            // Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF10B981),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: 'They Owe Me (${theyOweList.length})'),
                    Tab(text: 'I Owe (${iOweList.length})'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDebtList(theyOweList, DebtType.theyOwe),
                  _buildDebtList(iOweList, DebtType.iOwe),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetSummaryCard() {
    final isPositive = netBalance >= 0;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('They Owe Me', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('+₹${totalTheyOwe.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('I Owe', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('-₹${totalIOwe.toStringAsFixed(0)}', style: const TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isPositive ? Colors.green.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isPositive ? Colors.green.withOpacity(0.3) : Colors.redAccent.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Net', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                '${isPositive ? '+' : ''}₹${netBalance.toStringAsFixed(0)}',
                style: TextStyle(color: isPositive ? Colors.green : Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDebtList(List<DebtModel> list, DebtType type) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(type == DebtType.theyOwe ? '🎉' : '✅', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              type == DebtType.theyOwe ? "No one owes you money" : "You don't owe anyone",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      itemCount: list.length,
      itemBuilder: (context, index) => _buildDebtCard(list[index]),
    );
  }

  Widget _buildDebtCard(DebtModel debt) {
    final isTheyOwe = debt.type == DebtType.theyOwe;
    final color = isTheyOwe ? Colors.green : Colors.redAccent;
    final daysSince = DateTime.now().difference(debt.date).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Text(
              debt.personName[0].toUpperCase(),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(debt.personName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                if (debt.note != null)
                  Text(debt.note!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text('$daysSince days ago', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isTheyOwe ? '+' : '-'}₹${debt.amount.toStringAsFixed(0)}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => setState(() => debt.isPaid = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Mark Paid', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddDebtModal() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    bool isIOwe = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setModalState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.7,
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text('Add Debt', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
              const SizedBox(height: 24),
              // Who type toggle
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => isIOwe = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isIOwe ? Colors.green.withOpacity(0.15) : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: !isIOwe ? Colors.green : Colors.transparent),
                        ),
                        child: Center(child: Text('They Owe Me', style: TextStyle(color: !isIOwe ? Colors.green : Colors.grey, fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => isIOwe = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isIOwe ? Colors.redAccent.withOpacity(0.15) : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isIOwe ? Colors.redAccent : Colors.transparent),
                        ),
                        child: Center(child: Text('I Owe', style: TextStyle(color: isIOwe ? Colors.redAccent : Colors.grey, fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Person Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.person_outline))),
              const SizedBox(height: 16),
              TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Amount', prefixText: '₹ ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 16),
              TextField(controller: noteController, decoration: InputDecoration(labelText: 'Note (optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.notes_outlined))),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
                      setState(() {
                        debts.add(DebtModel(
                          id: DateTime.now().toString(),
                          personName: nameController.text,
                          amount: double.tryParse(amountController.text) ?? 0,
                          type: isIOwe ? DebtType.iOwe : DebtType.theyOwe,
                          date: DateTime.now(),
                          note: noteController.text.isEmpty ? null : noteController.text,
                        ));
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Add Debt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
