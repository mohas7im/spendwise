import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/debt.dart';
import '../providers/finance_provider.dart';
import '../widgets/common/premium_gradient_card.dart';
import '../widgets/debt/add_debt_modal.dart';
import 'loan_calculator_screen.dart';
import 'calculator_hub_screen.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  int _selectedDebtTab = 0;

  void _showAddDebtModal(FinanceProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddDebtModal(provider: provider),
    );
  }

  void _showPaymentHistory(DebtModel debt, FinanceProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment History', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text('${debt.personName} - ${debt.type.name.toUpperCase()}', style: const TextStyle(color: Colors.grey)),
            const Divider(height: 32),
            
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Payable', style: TextStyle(color: Colors.grey)),
                    Text('₹${debt.totalPayable.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Remaining', style: TextStyle(color: Colors.grey)),
                    Text('₹${debt.remainingAmount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).primaryColor)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Payment History List
            if (debt.paymentHistory.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No payments recorded yet.')))
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: debt.paymentHistory.length,
                  itemBuilder: (ctx, index) {
                    final payment = debt.paymentHistory[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: payment.status == PaymentStatus.paid ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                        child: Icon(payment.status == PaymentStatus.paid ? Icons.check : Icons.warning, color: payment.status == PaymentStatus.paid ? Colors.green : Colors.orange),
                      ),
                      title: Text('₹${payment.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${payment.date.day}/${payment.date.month}/${payment.date.year} • ${payment.status.name}'),
                      trailing: payment.note != null && payment.note!.isNotEmpty ? const Icon(Icons.note, color: Colors.grey, size: 16) : null,
                    );
                  },
                ),
              ),
              
            const SizedBox(height: 24),
            
            // Record New Payment Button
            if (!debt.isPaid)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.payment),
                  label: const Text('Record Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showRecordPaymentDialog(debt, provider);
                  },
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showRecordPaymentDialog(DebtModel debt, FinanceProvider provider) {
    final amountCtrl = TextEditingController(text: debt.emiAmount != null ? debt.emiAmount.toString() : debt.remainingAmount.toString());
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Record Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount Paid (₹)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text) ?? 0;
              if (amount > 0) {
                provider.recordDebtPayment(debt.id, amount, status: amount < debt.remainingAmount && debt.emiAmount == null ? PaymentStatus.partial : PaymentStatus.paid);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final debts = financeProvider.debts;
    
    final simpleDebts = debts.where((d) => (d.type == DebtType.iOwe || d.type == DebtType.theyOwe) && !d.isPaid).toList();
    final loansEmis = debts.where((d) => (d.type == DebtType.loanGiven || d.type == DebtType.loanTaken || d.type == DebtType.emiLoan) && !d.isPaid).toList();

    double totalIOwe = debts.where((d) => (d.type == DebtType.iOwe || d.type == DebtType.loanTaken || d.type == DebtType.emiLoan) && !d.isPaid).fold(0, (sum, d) => sum + d.remainingAmount);
    double totalTheyOwe = debts.where((d) => (d.type == DebtType.theyOwe || d.type == DebtType.loanGiven) && !d.isPaid).fold(0, (sum, d) => sum + d.remainingAmount);
    double netBalance = totalTheyOwe - totalIOwe;

    double activeEmis = debts.where((d) => d.type == DebtType.emiLoan && !d.isPaid).fold(0, (sum, d) => sum + d.remainingAmount);
    double activeLoans = debts.where((d) => (d.type == DebtType.loanTaken || d.type == DebtType.loanGiven) && !d.isPaid).fold(0, (sum, d) => sum + d.remainingAmount);
    
    int overdueCount = debts.where((d) => d.isOverdue).length;

    // Fuel spent this month
    double fuelSpent = financeProvider.transactions
        .where((t) => t.category.toLowerCase().contains('fuel') && t.date.month == DateTime.now().month)
        .fold(0, (sum, t) => sum + t.amount);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    Text('Finance Hub', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoanCalculatorScreen())),
                      icon: Icon(Icons.calculate, color: Theme.of(context).primaryColor, size: 28),
                    ),
                    IconButton(
                      onPressed: () => _showAddDebtModal(financeProvider),
                      icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor, size: 28),
                    ),
                  ],
                ),
              ),

              // Dashboard Summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: PremiumGradientCard(
                  builder: (context, textColor, subTextColor) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Net Balance (Debt)', style: TextStyle(color: subTextColor, fontSize: 13)),
                          if (overdueCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
                              child: Text('$overdueCount Overdue!', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${netBalance >= 0 ? '+' : '-'} ₹${netBalance.abs().toStringAsFixed(0)}',
                        style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('I Owe (Total)', style: TextStyle(color: subTextColor, fontSize: 11)),
                              Text('₹${totalIOwe.toStringAsFixed(0)}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Others Owe Me', style: TextStyle(color: subTextColor, fontSize: 11)),
                              Text('₹${totalTheyOwe.toStringAsFixed(0)}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Fuel Spent', style: TextStyle(color: subTextColor, fontSize: 11)),
                              Text('₹${fuelSpent.toStringAsFixed(0)}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Active EMIs', style: TextStyle(color: subTextColor, fontSize: 11)),
                              Text('₹${activeEmis.toStringAsFixed(0)}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Active Loans', style: TextStyle(color: subTextColor, fontSize: 11)),
                              Text('₹${activeLoans.toStringAsFixed(0)}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Tools Grid Partition
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('Calculators & Tools', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: allCalculators.length,
                itemBuilder: (context, index) {
                  final tool = allCalculators[index];
                  return GestureDetector(
                    onTap: () {
                      if (tool.destination != null) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => tool.destination!));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${tool.title} is coming soon!')),
                        );
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                          ),
                          child: Text(tool.iconEmoji, style: const TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tool.title, 
                          textAlign: TextAlign.center, 
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600), 
                          maxLines: 2, 
                          overflow: TextOverflow.ellipsis
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Active Debts Partition with Custom Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedDebtTab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedDebtTab == 0 ? Theme.of(context).primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Debts (P2P)', 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedDebtTab == 0 ? Colors.white : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedDebtTab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedDebtTab == 1 ? Theme.of(context).primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Loans & EMIs', 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedDebtTab == 1 ? Colors.white : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_selectedDebtTab == 0)
                _buildList(simpleDebts, financeProvider, isStructured: false)
              else
                _buildList(loansEmis, financeProvider, isStructured: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<DebtModel> list, FinanceProvider provider, {bool isStructured = false}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isStructured ? Icons.account_balance : Icons.people, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No active ${isStructured ? 'loans' : 'debts'}', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final debt = list[index];
        final isOwedByMe = debt.type == DebtType.iOwe || debt.type == DebtType.loanTaken || debt.type == DebtType.emiLoan;
        final color = isOwedByMe ? Colors.redAccent : Colors.green;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showPaymentHistory(debt, provider),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.1),
                            child: Icon(isOwedByMe ? Icons.arrow_downward : Icons.arrow_upward, color: color, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(debt.personName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(debt.type.name.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${debt.remainingAmount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
                          if (debt.isOverdue)
                            const Text('OVERDUE', style: TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.bold))
                          else if (debt.isPaid)
                            const Text('PAID', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold))
                          else
                            Text('of ₹${debt.totalPayable.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  if (isStructured && debt.nextDueDate != null) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: debt.totalPayable > 0 ? (debt.repaidAmount / debt.totalPayable) : 0,
                      backgroundColor: Colors.grey.withValues(alpha: 0.1),
                      color: Theme.of(context).primaryColor,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Next Due: ${debt.nextDueDate!.day}/${debt.nextDueDate!.month}/${debt.nextDueDate!.year}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        if (debt.emiAmount != null)
                          Text('EMI: ₹${debt.emiAmount!.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
