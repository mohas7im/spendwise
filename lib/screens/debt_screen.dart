import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/debt.dart';
import '../providers/finance_provider.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final debts = financeProvider.debts;

    final iOweList = debts.where((d) => d.type == DebtType.iOwe && !d.isPaid).toList();
    final theyOweList = debts.where((d) => d.type == DebtType.theyOwe && !d.isPaid).toList();

    final totalIOwe = iOweList.fold(0.0, (sum, d) => sum + d.remainingAmount);
    final totalTheyOwe = theyOweList.fold(0.0, (sum, d) => sum + d.remainingAmount);
    final netBalance = totalTheyOwe - totalIOwe;

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
                    onPressed: () => _showAddDebtModal(financeProvider),
                    icon: const Icon(Icons.add_circle, color: Color(0xFF10B981), size: 28),
                  ),
                ],
              ),
            ),

            // Net Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _buildNetSummaryCard(totalTheyOwe, totalIOwe, netBalance),
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
                  _buildDebtList(theyOweList, DebtType.theyOwe, financeProvider),
                  _buildDebtList(iOweList, DebtType.iOwe, financeProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetSummaryCard(double totalTheyOwe, double totalIOwe, double netBalance) {
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
                Text('+₹${totalTheyOwe.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
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
                Text('-₹${totalIOwe.toStringAsFixed(0)}', style: const TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
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
                '${isPositive ? '+' : ''}₹${netBalance.abs().toStringAsFixed(0)}',
                style: TextStyle(color: isPositive ? Colors.green : Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDebtList(List<DebtModel> list, DebtType type, FinanceProvider provider) {
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
      itemBuilder: (context, index) => _buildDebtCard(list[index], provider),
    );
  }

  Widget _buildDebtCard(DebtModel debt, FinanceProvider provider) {
    final isTheyOwe = debt.type == DebtType.theyOwe;
    final color = isTheyOwe ? Colors.green : Colors.redAccent;
    final daysSince = DateTime.now().difference(debt.date).inDays;

    final percentPaid = debt.amount > 0 ? (debt.repaidAmount / debt.amount).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
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
                    '${isTheyOwe ? '+' : '-'}₹${debt.remainingAmount.toStringAsFixed(0)}',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _showRepayDialog(debt, provider),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Record Payment', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (debt.repaidAmount > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Repaid', style: TextStyle(color: Colors.grey, fontSize: 10)),
                Text('₹${debt.repaidAmount.toStringAsFixed(0)} / ₹${debt.amount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentPaid,
                minHeight: 4,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ]
        ],
      ),
    );
  }

  void _showRepayDialog(DebtModel debt, FinanceProvider provider) {
    final controller = TextEditingController(text: debt.remainingAmount.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Record Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: '₹ ',
            border: OutlineInputBorder(),
            labelText: 'Payment Amount',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0.0;
              if (amount > 0) {
                provider.recordDebtPayment(debt.id, amount);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddDebtModal(FinanceProvider provider) {
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
                      provider.addDebt(DebtModel(
                        id: DateTime.now().toString(),
                        personName: nameController.text,
                        amount: double.tryParse(amountController.text) ?? 0,
                        type: isIOwe ? DebtType.iOwe : DebtType.theyOwe,
                        date: DateTime.now(),
                        note: noteController.text.isEmpty ? null : noteController.text,
                      ));
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
