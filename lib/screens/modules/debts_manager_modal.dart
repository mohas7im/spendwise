import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_hub_provider.dart';
import '../../models/finance_module_models.dart';

class DebtsManagerModal extends StatefulWidget {
  const DebtsManagerModal({super.key});

  @override
  State<DebtsManagerModal> createState() => _DebtsManagerModalState();
}

class _DebtsManagerModalState extends State<DebtsManagerModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['I Owe', 'They Owe Me', 'EMI'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Debts & Loans', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.blue, size: 28),
            onPressed: () => _showAddEditDebtModal(context, null),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<FinanceHubProvider>(
              builder: (context, provider, child) {
                return TabBarView(
                  controller: _tabController,
                  children: _tabs.map((tabType) {
                    final tabDebts = provider.debts.where((d) => d.type == tabType).toList();
                    if (tabDebts.isEmpty) {
                      return Center(child: Text('No active records for $tabType.', style: const TextStyle(color: Colors.grey)));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: tabDebts.length,
                      itemBuilder: (ctx, i) => _buildDebtCard(context, tabDebts[i], provider),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDebtCard(BuildContext context, DebtItem debt, FinanceHubProvider provider) {
    final progress = debt.totalAmount > 0 ? debt.paidAmount / debt.totalAmount : 0.0;
    final isOwedToMe = debt.type == 'They Owe Me';
    final primaryColor = debt.type == 'EMI' ? Colors.orange : (isOwedToMe ? Colors.green : Colors.redAccent);

    return Dismissible(
      key: Key(debt.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this record?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
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
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
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
                        decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(progress >= 1 ? 'Paid Off' : 'Active', style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  if (debt.type == 'EMI' && debt.emiAmount > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Monthly EMI', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              Text('₹${debt.emiAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Interest Rate', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              Text('${debt.interestRate}% p.a.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(debt.dueDate.isEmpty ? 'No Due Date' : 'Due: ${debt.dueDate}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                      if (progress < 1.0)
                        SizedBox(
                          height: 30,
                          child: OutlinedButton.icon(
                            onPressed: () => _showLogPaymentModal(context, debt, provider),
                            icon: const Icon(Icons.payment, size: 14),
                            label: const Text('Log Payment', style: TextStyle(fontSize: 11)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogPaymentModal(BuildContext context, DebtItem debt, FinanceHubProvider provider) {
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Logging payment for ${debt.name}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount Paid',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(amountCtrl.text) ?? 0;
              if (val > 0) {
                double newPaid = debt.paidAmount + val;
                if (newPaid > debt.totalAmount) newPaid = debt.totalAmount;
                provider.updateDebt(debt.copyWith(paidAmount: newPaid));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddEditDebtModal(BuildContext context, DebtItem? existingDebt) {
    final nameCtrl = TextEditingController(text: existingDebt?.name ?? '');
    final totalCtrl = TextEditingController(text: existingDebt?.totalAmount.toString() ?? '');
    final paidCtrl = TextEditingController(text: existingDebt?.paidAmount.toString() ?? '0');
    final dueCtrl = TextEditingController(text: existingDebt?.dueDate ?? '');
    
    // EMI fields
    final emiAmountCtrl = TextEditingController(text: existingDebt?.emiAmount.toString() ?? '');
    final interestCtrl = TextEditingController(text: existingDebt?.interestRate.toString() ?? '');
    final tenureCtrl = TextEditingController(text: existingDebt?.tenureMonths.toString() ?? '');

    String type = existingDebt?.type ?? _tabs[_tabController.index];
    DateTime? selectedDate = existingDebt?.dueDate != null && existingDebt!.dueDate.isNotEmpty
        ? _parseDate(existingDebt.dueDate)
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return AnimatedPadding(
            padding: EdgeInsets.only(bottom: bottomInset),
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.fastOutSlowIn,
              height: (MediaQuery.of(context).size.height * 0.92 - bottomInset).clamp(400.0, double.infinity),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                        Text(existingDebt == null ? 'Add Debt / Loan' : 'Edit Debt / Loan',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                        TextButton(
                          onPressed: () {
                            if (nameCtrl.text.isNotEmpty && totalCtrl.text.isNotEmpty) {
                              final provider = Provider.of<FinanceHubProvider>(context, listen: false);
                              double total = double.tryParse(totalCtrl.text) ?? 0;
                              double paid = double.tryParse(paidCtrl.text) ?? 0;
                              if (paid > total) paid = total;

                              final item = DebtItem(
                                id: existingDebt?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                name: nameCtrl.text,
                                type: type,
                                totalAmount: total,
                                paidAmount: paid,
                                dueDate: dueCtrl.text,
                                emiAmount: double.tryParse(emiAmountCtrl.text) ?? 0,
                                interestRate: double.tryParse(interestCtrl.text) ?? 0,
                                tenureMonths: int.tryParse(tenureCtrl.text) ?? 0,
                              );
                              if (existingDebt == null) {
                                provider.addDebt(item);
                              } else {
                                provider.updateDebt(item);
                              }
                              Navigator.pop(ctx);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter name and total amount')));
                            }
                          },
                          child: Text(existingDebt == null ? 'Save' : 'Update', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: type,
                            decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder(), prefixIcon: Icon(Icons.category)),
                            items: ['I Owe', 'They Owe Me', 'EMI'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (val) => setModalState(() => type = val!),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: nameCtrl, 
                            decoration: const InputDecoration(labelText: 'Name (e.g. John, Car Loan)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: TextField(controller: totalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Amount', prefixText: '₹ ', border: OutlineInputBorder()))),
                              const SizedBox(width: 16),
                              Expanded(child: TextField(controller: paidCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Paid Amount', prefixText: '₹ ', border: OutlineInputBorder()))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          if (type == 'EMI') ...[
                            Row(
                              children: [
                                Expanded(child: TextField(controller: emiAmountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monthly EMI', prefixText: '₹ ', border: OutlineInputBorder()))),
                                const SizedBox(width: 16),
                                Expanded(child: TextField(controller: interestCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Interest Rate (%)', border: OutlineInputBorder()))),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(controller: tenureCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tenure (Months)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.schedule))),
                            const SizedBox(height: 16),
                          ],
                          
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setModalState(() {
                                  selectedDate = date;
                                  dueCtrl.text = DateFormat('dd MMM yyyy').format(date);
                                });
                              }
                            },
                            child: IgnorePointer(
                              child: TextField(
                                controller: dueCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Due Date',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  DateTime? _parseDate(String dateStr) {
    try {
      return DateFormat('dd MMM yyyy').parse(dateStr);
    } catch (e) {
      return null;
    }
  }
}
