import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_hub_provider.dart';
import '../../models/finance_module_models.dart';

class DebtsManagerModal extends StatelessWidget {
  const DebtsManagerModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Debts & Loans', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blue, size: 32),
                  onPressed: () => _showAddEditDebtModal(context, null),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<FinanceHubProvider>(
              builder: (context, provider, child) {
                final debts = provider.debts;
                if (debts.isEmpty) {
                  return const Center(child: Text('No active debts or loans.', style: TextStyle(color: Colors.grey)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: debts.length,
                  itemBuilder: (ctx, i) {
                    final debt = debts[i];
                    return _buildDebtCard(context, debt, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(BuildContext context, DebtItem debt, FinanceHubProvider provider) {
    final progress = debt.totalAmount > 0 ? debt.paidAmount / debt.totalAmount : 0.0;
    final isOwedToMe = debt.type == 'They Owe Me';
    final primaryColor = isOwedToMe ? Colors.green : Colors.redAccent;

    return Dismissible(
      key: Key(debt.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => provider.deleteDebt(debt.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showAddEditDebtModal(context, debt),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                        child: Text(debt.name.isNotEmpty ? debt.name[0] : '?', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(debt.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(debt.type, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(progress >= 1 ? 'Paid Off' : 'Active', style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Amount', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text('₹${debt.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Paid Amount', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text('₹${debt.paidAmount.toStringAsFixed(0)}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 12),
                  Text('Next Due: ${debt.dueDate}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddEditDebtModal(BuildContext context, DebtItem? existingDebt) {
    final nameCtrl = TextEditingController(text: existingDebt?.name ?? '');
    final totalCtrl = TextEditingController(text: existingDebt?.totalAmount.toString() ?? '');
    final paidCtrl = TextEditingController(text: existingDebt?.paidAmount.toString() ?? '0');
    final dueCtrl = TextEditingController(text: existingDebt?.dueDate ?? '');
    String type = existingDebt?.type ?? 'I Owe';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(existingDebt == null ? 'Add Debt / Loan' : 'Edit Debt / Loan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                  items: ['I Owe', 'They Owe Me', 'EMI'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setModalState(() => type = val!),
                ),
                const SizedBox(height: 16),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name (e.g. John, Car Loan)', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: totalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Amount', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: paidCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Paid Amount', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: dueCtrl, decoration: const InputDecoration(labelText: 'Due Date / Schedule', border: OutlineInputBorder())),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (nameCtrl.text.isNotEmpty && totalCtrl.text.isNotEmpty) {
                        final provider = Provider.of<FinanceHubProvider>(context, listen: false);
                        final item = DebtItem(
                          id: existingDebt?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameCtrl.text,
                          type: type,
                          totalAmount: double.tryParse(totalCtrl.text) ?? 0,
                          paidAmount: double.tryParse(paidCtrl.text) ?? 0,
                          dueDate: dueCtrl.text,
                        );
                        if (existingDebt == null) {
                          provider.addDebt(item);
                        } else {
                          provider.updateDebt(item);
                        }
                        Navigator.pop(ctx);
                      }
                    },
                    child: Text(existingDebt == null ? 'Add' : 'Save Changes'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
