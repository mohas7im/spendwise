import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_hub_provider.dart';
import '../../models/finance_module_models.dart';
import '../../widgets/common/custom_bottom_sheet.dart';
import 'package:fl_chart/fl_chart.dart';

class DebtsManagerModal extends StatefulWidget {
  const DebtsManagerModal({super.key});

  @override
  State<DebtsManagerModal> createState() => _DebtsManagerModalState();
}

class _DebtsManagerModalState extends State<DebtsManagerModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['I Owe', 'They Owe Me', 'EMI'];
  bool _showPaid = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Update summary box when tab changes
      }
    });
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDebtModal(context, null),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Consumer<FinanceHubProvider>(
          builder: (context, provider, child) {
            final activeTab = _tabs[_tabController.index];
            final activeDebts = provider.debts.where((d) => d.type == activeTab).toList();
            
            double totalPrincipal = 0;
            double totalPaid = 0;
            for (var d in activeDebts) {
              totalPrincipal += d.totalAmount;
              totalPaid += d.paidAmount;
            }
            final totalPending = totalPrincipal - totalPaid;

            return Column(
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
                if (activeDebts.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _showPaid = !_showPaid),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 300),
                                crossFadeState: _showPaid ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                firstChild: Text('Total Pending ($activeTab)', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.2)),
                                secondChild: Text('Total Paid ($activeTab)', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.2)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.swap_horiz, size: 12, color: Colors.white70),
                                    const SizedBox(width: 4),
                                    const Text('Tap', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 300),
                            crossFadeState: _showPaid ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            firstChild: Text(
                              '₹${totalPending.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 32, 
                                fontWeight: FontWeight.w800, 
                                letterSpacing: -1.0,
                                color: Colors.white,
                              ),
                            ),
                            secondChild: Text(
                              '₹${totalPaid.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 32, 
                                fontWeight: FontWeight.w800, 
                                letterSpacing: -1.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Your Records', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.trending_up, color: Theme.of(context).primaryColor, size: 22),
                        onPressed: () => _showDebtTrendModal(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _tabs.map((tabType) {
                      final tabDebts = provider.debts.where((d) => d.type == tabType).toList();
                      if (tabDebts.isEmpty) {
                        return Center(child: Text('No active records for $tabType.', style: const TextStyle(color: Colors.grey)));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: tabDebts.length,
                        itemBuilder: (ctx, i) => _buildDebtCard(context, tabDebts[i], provider),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDebtCard(BuildContext context, DebtItem debt, FinanceHubProvider provider) {
    final progress = debt.totalAmount > 0 ? debt.paidAmount / debt.totalAmount : 0.0;
    final isOwedToMe = debt.type == 'They Owe Me';
    final primaryColor = debt.type == 'EMI' ? Colors.orange : (isOwedToMe ? Colors.green : Colors.redAccent);
    final pendingAmount = debt.totalAmount - debt.paidAmount;

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
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => provider.deleteDebt(debt.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              title: Text(debt.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Pending: ₹${pendingAmount.toStringAsFixed(0)}',
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  if (debt.dueDate.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text('Due: ${debt.dueDate}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Paid: ₹${debt.paidAmount.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      Text('Total: ₹${debt.totalAmount.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _showAddEditDebtModal(context, debt),
              ),
            ),
            if (debt.type == 'EMI' && debt.emiAmount > 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('EMI: ₹${debt.emiAmount.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    Text('${debt.interestRate}% p.a.', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  ],
                ),
              ),
            ],
            const Divider(height: 1),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.payment, size: 16),
                    label: const Text('Log Payment'),
                    onPressed: () => _showLogPaymentModal(context, debt, provider),
                    style: TextButton.styleFrom(foregroundColor: primaryColor),
                  ),
                ),
                Container(width: 1, height: 36, color: Colors.grey.withValues(alpha: 0.15)),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.history, size: 16),
                    label: const Text('History'),
                    onPressed: () => _showHistoryModal(context, debt),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryModal(BuildContext context, DebtItem debt) {
    final fmt = NumberFormat.decimalPattern('en_IN');
    final history = List<Map<String, dynamic>>.from(debt.paymentHistory);
    history.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomBottomSheet(
        title: 'Payment History',
        isScrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (history.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No history yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: history.length,
                  itemBuilder: (_, i) {
                    final item = history[i];
                    final date = DateTime.parse(item['date']);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_downward, color: Colors.green, size: 20),
                      ),
                      title: Text(DateFormat('MMM d, y').format(date)),
                      subtitle: Text(DateFormat('h:mm a').format(date)),
                      trailing: Text(
                        '₹${fmt.format(item['amount'])}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLogPaymentModal(BuildContext context, DebtItem debt, FinanceHubProvider provider) {
    final amountCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomBottomSheet(
        title: 'Log Payment',
        saveText: 'Log Payment',
        onSave: () {
          final val = double.tryParse(amountCtrl.text) ?? 0;
          if (val > 0) {
            double newPaid = debt.paidAmount + val;
            if (newPaid > debt.totalAmount) newPaid = debt.totalAmount;
            
            final newHistory = List<Map<String, dynamic>>.from(debt.paymentHistory)
              ..add({
                'date': DateTime.now().toIso8601String(),
                'amount': val,
              });

            provider.updateDebt(debt.copyWith(paidAmount: newPaid, paymentHistory: newHistory));
            Navigator.pop(ctx);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Logging payment for ${debt.name}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount Paid',
                prefixText: '₹ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
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

  void _showDebtTrendModal(BuildContext context) {
    bool isEmiTab = _tabController.index == 2;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomBottomSheet(
        title: isEmiTab ? 'Monthly EMI Payments' : 'Debt & Loan Trend',
        isScrollable: false,
        child: Consumer<FinanceHubProvider>(
          builder: (context, provider, child) {
            if (isEmiTab) {
              final emiDebts = provider.debts.where((d) => d.type == 'EMI').toList();
              return _buildEmiTrendChart(emiDebts, context);
            } else {
              return _buildDebtTrendChart(provider.debts, context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmiTrendChart(List<DebtItem> emiDebts, BuildContext context) {
    final now = DateTime.now();
    List<String> labels = [];
    List<double> emiSums = List.filled(6, 0.0);

    for (int i = 5; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      labels.add(DateFormat('MMM').format(targetDate));

      double monthSum = 0;
      for (final debt in emiDebts) {
        for (final payment in debt.paymentHistory) {
          final pDate = DateTime.parse(payment['date']);
          if (pDate.year == targetDate.year && pDate.month == targetDate.month) {
            monthSum += payment['amount'];
          }
        }
      }
      emiSums[5 - i] = monthSum;
    }

    double maxY = emiSums.isEmpty ? 1000 : emiSums.reduce((a, b) => a > b ? a : b);
    if (maxY == 0) maxY = 1000;
    
    final bool hasData = emiDebts.isNotEmpty;
    if (!hasData) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: Text('Add an EMI to see your payment trend!', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
               Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle)),
               const SizedBox(width: 6),
               const Text('EMI Paid', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.2,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => isDark ? Colors.white : Colors.black87,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        'EMI Paid\n₹${rod.toY.round()}',
                        TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(labels[index], style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 1,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(6, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(toY: emiSums[i], color: Colors.blueAccent, width: 12, borderRadius: BorderRadius.circular(4)),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDebtTrendChart(List<DebtItem> debts, BuildContext context) {
    final now = DateTime.now();
    List<FlSpot> principalSpots = [];
    List<FlSpot> paidSpots = [];
    List<String> labels = [];
    
    List<double> principalSums = List.filled(6, 0.0);
    List<double> paidSums = List.filled(6, 0.0);
    
    for (int i = 5; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      labels.add(DateFormat('MMM').format(targetDate));
      
      double paidSum = 0;
      
      for (final debt in debts) {
        for (final payment in debt.paymentHistory) {
          final pDate = DateTime.parse(payment['date']);
          if (pDate.year == targetDate.year && pDate.month == targetDate.month) {
            paidSum += payment['amount'];
          }
        }
      }
      
      double historicalBalance = 0;
      for (final debt in debts) {
          double debtPaidAfter = 0;
          for (final payment in debt.paymentHistory) {
              final pDate = DateTime.parse(payment['date']);
              if (pDate.isAfter(DateTime(targetDate.year, targetDate.month + 1, 0))) {
                  debtPaidAfter += payment['amount'];
              }
          }
          double currentPending = debt.totalAmount - debt.paidAmount;
          historicalBalance += currentPending + debtPaidAfter;
      }
      
      principalSums[5 - i] = historicalBalance;
      paidSums[5 - i] = paidSum;
      
      principalSpots.add(FlSpot((5 - i).toDouble(), historicalBalance));
      paidSpots.add(FlSpot((5 - i).toDouble(), paidSum));
    }

    double maxPrincipal = principalSums.isEmpty ? 1000 : principalSums.reduce((a, b) => a > b ? a : b);
    double maxPaid = paidSums.isEmpty ? 1000 : paidSums.reduce((a, b) => a > b ? a : b);
    double maxY = maxPrincipal > maxPaid ? maxPrincipal : maxPaid;
    if (maxY == 0) maxY = 1000;
    
    final bool hasData = debts.isNotEmpty;

    if (!hasData) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: Text('Add a loan or debt to see your trend!', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
               Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
               const SizedBox(width: 6),
               const Text('Outstanding Balance', style: TextStyle(fontSize: 12)),
               const SizedBox(width: 16),
               Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
               const SizedBox(width: 6),
               const Text('Amount Paid', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY * 1.2,
                minX: 0,
                maxX: 5,
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => isDark ? Colors.white : Colors.black87,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '₹${spot.y.round()}',
                          TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length || value != index.toDouble()) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(labels[index], style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: principalSpots,
                    isCurved: true,
                    color: Colors.redAccent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.redAccent.withValues(alpha: 0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: paidSpots,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
