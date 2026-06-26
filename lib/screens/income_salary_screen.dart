import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/income_source.dart';
import '../providers/finance_provider.dart';

class IncomeSalaryScreen extends StatelessWidget {
  const IncomeSalaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final incomes = provider.incomeSources;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income & Salary', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: incomes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('💸', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text('No income sources yet', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('Add your salary or freelance income to track it.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: incomes.length,
              itemBuilder: (context, index) {
                final inc = incomes[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: (Theme.of(context).primaryColor).withValues(alpha: 0.1),
                        child: Icon(_getIconForType(inc.type), color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(inc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('₹${inc.amount.toStringAsFixed(0)} / ${inc.frequency.name}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                      if (inc.creditDate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: (Theme.of(context).primaryColor).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Text('Due Date', style: TextStyle(color: Colors.grey, fontSize: 10)),
                              Text('${inc.creditDate}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddIncomeModal(context, provider, isDark),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Add Income', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  IconData _getIconForType(IncomeType type) {
    switch (type) {
      case IncomeType.salary:
        return Icons.work_outline;
      case IncomeType.freelance:
        return Icons.laptop_mac;
      case IncomeType.investment:
        return Icons.trending_up;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  void _showAddIncomeModal(BuildContext context, FinanceProvider provider, bool isDark) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final dateController = TextEditingController();
    IncomeType selectedType = IncomeType.freelance;
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = Theme.of(context).colorScheme.onPrimary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Income Source', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Source Name (e.g. Upwork)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Expected Credit Date (1-31)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<IncomeType>(
                    initialValue: selectedType,
                    decoration: InputDecoration(labelText: 'Type', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    items: IncomeType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: textColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        final amt = double.tryParse(amountController.text) ?? 0;
                        final date = int.tryParse(dateController.text);
                        if (nameController.text.isNotEmpty && amt > 0) {
                          provider.addIncomeSource(IncomeSource(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: nameController.text,
                            amount: amt,
                            type: selectedType,
                            frequency: IncomeFrequency.monthly,
                            creditDate: (date != null && date >= 1 && date <= 31) ? date : null,
                          ));
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text('Save Income', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
