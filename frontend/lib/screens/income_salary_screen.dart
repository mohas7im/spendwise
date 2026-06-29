import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/income_source.dart';
import '../providers/finance_provider.dart';
import '../widgets/common/custom_bottom_sheet.dart';


class IncomeSalaryScreen extends StatefulWidget {
  const IncomeSalaryScreen({super.key});

  @override
  State<IncomeSalaryScreen> createState() => _IncomeSalaryScreenState();
}

class _IncomeSalaryScreenState extends State<IncomeSalaryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showYearly = false;

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

  IconData _getIconForType(IncomeType type) {
    switch (type) {
      case IncomeType.salary: return Icons.work_outline;
      case IncomeType.freelance: return Icons.laptop_mac;
      case IncomeType.investment: return Icons.trending_up;
      default: return Icons.account_balance_wallet_outlined;
    }
  }

  Color _getColorForType(IncomeType type, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade300 : Colors.grey.shade800;
  }

  void _showAddEditModal(BuildContext context, FinanceProvider provider, {IncomeSource? editing}) {
    final nameController = TextEditingController(text: editing?.name ?? '');
    final amountController = TextEditingController(text: editing?.amount.toStringAsFixed(0) ?? '');
    final dateController = TextEditingController(text: editing?.creditDate?.toString() ?? '');
    IncomeType selectedType = editing?.type ?? IncomeType.salary;
    IncomeFrequency selectedFreq = editing?.frequency ?? IncomeFrequency.monthly;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return CustomBottomSheet(
            title: editing == null ? 'Add Income Source' : 'Edit Income Source',
            saveText: editing == null ? 'Add Income Source' : 'Save Changes',
            headerActions: editing != null
                ? [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: ctx,
                          builder: (dctx) => AlertDialog(
                            title: const Text('Delete Income Source'),
                            content: Text('Delete "${editing.name}"? This cannot be undone.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () {
                                  provider.deleteIncomeSource(editing.id);
                                  Navigator.pop(dctx);
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  ]
                : null,
            onSave: () {
              final amt = double.tryParse(amountController.text) ?? 0;
              final date = int.tryParse(dateController.text);
              if (nameController.text.trim().isNotEmpty && amt > 0) {
                if (editing == null) {
                  provider.addIncomeSource(IncomeSource(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    amount: amt,
                    type: selectedType,
                    frequency: selectedFreq,
                    creditDate: (date != null && date >= 1 && date <= 31) ? date : null,
                  ));
                } else {
                  provider.updateIncomeSource(editing.copyWith(
                    name: nameController.text.trim(),
                    amount: amt,
                    type: selectedType,
                    frequency: selectedFreq,
                    creditDate: (date != null && date >= 1 && date <= 31) ? date : null,
                  ));
                }
                Navigator.pop(ctx);
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Source Name',
                    hintText: 'e.g. Google Inc., Upwork...',
                    prefixIcon: const Icon(Icons.business_center_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 14),

                // Amount
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹ ',
                    prefixIcon: const Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 14),

                // Type + Frequency in a Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<IncomeType>(
                        initialValue: selectedType,
                        decoration: InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        items: IncomeType.values.map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.name[0].toUpperCase() + t.name.substring(1)),
                        )).toList(),
                        onChanged: (val) { if (val != null) setModalState(() => selectedType = val); },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<IncomeFrequency>(
                        initialValue: selectedFreq,
                        decoration: InputDecoration(
                          labelText: 'Frequency',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        items: IncomeFrequency.values.map((f) => DropdownMenuItem(
                          value: f,
                          child: Text(f.name == 'oneTime' ? 'One Time' : f.name[0].toUpperCase() + f.name.substring(1)),
                        )).toList(),
                        onChanged: (val) { if (val != null) setModalState(() => selectedFreq = val); },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Credit date
                TextField(
                  controller: dateController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Expected Credit Day (1-31)',
                    hintText: 'e.g. 1 for 1st of every month',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showHistoryModal(BuildContext context, IncomeSource income) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomBottomSheet(
        title: 'Credit History',
        isScrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (income.creditHistory.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No credit history yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: income.creditHistory.length,
                  itemBuilder: (_, i) {
                    final record = income.creditHistory[i];
                    final fmt = NumberFormat.decimalPattern('en_IN');
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
                      title: Text(DateFormat('MMMM d, y').format(record.creditedAt)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormat('h:mm a').format(record.creditedAt)),
                          if (record.note != null && record.note!.isNotEmpty)
                            Text(record.note!, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                        ],
                      ),
                      trailing: Text(
                        '+₹${fmt.format(record.amount)}',
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

  void _showGlobalHistoryModal(BuildContext context, List<IncomeSource> incomes) {
    final fmt = NumberFormat.decimalPattern('en_IN');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomBottomSheet(
        title: 'All Credit History',
        isScrollable: false,
        child: _buildGlobalHistory(incomes, fmt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final incomes = provider.incomeSources;
    final fmt = NumberFormat.decimalPattern('en_IN');

    double totalMonthly = 0;
    double totalYearly = 0;
    for (var inc in incomes) {
      if (inc.frequency == IncomeFrequency.monthly) {
        totalMonthly += inc.amount;
        totalYearly += inc.amount * 12;
      } else if (inc.frequency == IncomeFrequency.yearly) {
        totalYearly += inc.amount;
        totalMonthly += inc.amount / 12;
      }
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Income & Salary', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditModal(context, provider),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (incomes.isNotEmpty)
              GestureDetector(
                onTap: () => setState(() => _showYearly = !_showYearly),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
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
                            crossFadeState: _showYearly ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            firstChild: Text('Total Monthly Income', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.2)),
                            secondChild: Text('Total Yearly Income', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.2)),
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
                        crossFadeState: _showYearly ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        firstChild: Text(
                          '₹${fmt.format(totalMonthly)}',
                          style: const TextStyle(
                            fontSize: 32, 
                            fontWeight: FontWeight.w800, 
                            letterSpacing: -1.0,
                            color: Colors.white,
                          ),
                        ),
                        secondChild: Text(
                          '₹${fmt.format(totalYearly)}',
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
            Expanded(
              child: incomes.isEmpty
                  ? const Center(child: Text('No active income sources.', style: TextStyle(color: Colors.grey)))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Your Sources', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.trending_up, color: Theme.of(context).primaryColor, size: 22),
                                    onPressed: () => _showCollectionTrendModal(context, incomes),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: Icon(Icons.history, color: Theme.of(context).primaryColor, size: 22),
                                    onPressed: () => _showGlobalHistoryModal(context, incomes),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            itemCount: incomes.length,
                      itemBuilder: (context, index) {
                    final inc = incomes[index];
                    final color = _getColorForType(inc.type, context);

                    return Dismissible(
                      key: Key(inc.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                      ),
                      confirmDismiss: (_) async {
                        bool confirm = false;
                        await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Source'),
                            content: Text('Delete "${inc.name}"? This cannot be undone.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () { confirm = true; Navigator.pop(ctx); },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        return confirm;
                      },
                      onDismissed: (_) {
                        provider.deleteIncomeSource(inc.id);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                              leading: CircleAvatar(
                                backgroundColor: color.withValues(alpha: 0.1),
                                child: Icon(_getIconForType(inc.type), color: color),
                              ),
                              title: Text(inc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${fmt.format(inc.amount)} / ${inc.frequency == IncomeFrequency.oneTime ? 'one time' : inc.frequency.name}',
                                    style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                  if (inc.creditDate != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text('Expected: ${inc.creditDate} of every month', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                    ),
                                  if (inc.lastCredited != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text('Last credited: ${DateFormat('MMM d, y').format(inc.lastCredited!)}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _showAddEditModal(context, provider, editing: inc),
                              ),
                            ),
                            const Divider(height: 1),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton.icon(
                                    icon: const Icon(Icons.download, size: 16),
                                    label: const Text('Payday'),
                                    onPressed: () => _showSalaryArrivalDialog(inc, provider),
                                    style: TextButton.styleFrom(foregroundColor: Colors.green),
                                  ),
                                ),
                                Container(width: 1, height: 36, color: Colors.grey.withValues(alpha: 0.15)),
                                Expanded(
                                  child: TextButton.icon(
                                    icon: const Icon(Icons.history, size: 16),
                                    label: const Text('History'),
                                    onPressed: () => _showHistoryModal(context, inc),
                                    style: TextButton.styleFrom(foregroundColor: color),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
  }

  void _showCollectionTrendModal(BuildContext context, List<IncomeSource> incomes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomBottomSheet(
        title: 'Collection Trend',
        isScrollable: false,
        child: _buildCollectionHistoryChart(incomes, context),
      ),
    );
  }


  Widget _buildGlobalHistory(List<IncomeSource> incomes, NumberFormat fmt) {
    // Flatten all credit records across all sources, sorted by date descending
    final allRecords = <Map<String, dynamic>>[];
    for (final inc in incomes) {
      for (final record in inc.creditHistory) {
        allRecords.add({'source': inc, 'record': record});
      }
    }
    allRecords.sort((a, b) {
      final ra = (a['record'] as IncomeCreditRecord).creditedAt;
      final rb = (b['record'] as IncomeCreditRecord).creditedAt;
      return rb.compareTo(ra);
    });

    if (allRecords.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No credit history yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 8),
              Text('Credit history will appear once income is received', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: allRecords.length,
        itemBuilder: (_, i) {
        final item = allRecords[i];
        final inc = item['source'] as IncomeSource;
        final record = item['record'] as IncomeCreditRecord;
        final color = _getColorForType(inc.type, context);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_downward, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(inc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMMM d, y • h:mm a').format(record.creditedAt),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    if (record.note != null)
                      Text(record.note!, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+₹${fmt.format(record.amount)}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      inc.type.name[0].toUpperCase() + inc.type.name.substring(1),
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      ),
    );
  }

  void _showSalaryArrivalDialog(IncomeSource inc, FinanceProvider provider) {
    final amountController = TextEditingController(text: inc.amount.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomBottomSheet(
        title: '🎉 Payday for ${inc.name}',
        saveText: 'Confirm & Add',
        onSave: () {
          final amt = double.tryParse(amountController.text) ?? inc.amount;
          provider.creditIncome(inc.id, amt);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Income credited successfully!'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log a new income credit for ${inc.name}.', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Received Amount (₹)',
                helperText: 'Edit if amount changed due to overtime/LOP',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionHistoryChart(List<IncomeSource> incomes, BuildContext context) {
    final now = DateTime.now();
    List<FlSpot> spots = [];
    List<String> labels = [];
    
    // Aggregate credits per month for the last 6 months
    List<double> monthlySums = List.filled(6, 0.0);
    
    for (int i = 5; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      labels.add(DateFormat('MMM').format(targetDate));
      
      double sum = 0;
      for (final inc in incomes) {
        for (final record in inc.creditHistory) {
          if (record.creditedAt.year == targetDate.year && record.creditedAt.month == targetDate.month) {
            sum += record.amount;
          }
        }
      }
      monthlySums[5 - i] = sum;
      spots.add(FlSpot((5 - i).toDouble(), sum));
    }

    double maxY = monthlySums.isEmpty ? 1000 : monthlySums.reduce((a, b) => a > b ? a : b);
    if (maxY == 0) maxY = 1000;
    
    final bool hasData = monthlySums.any((v) => v > 0);

    if (!hasData) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: Text('Log your first payday to see your collection trend!', style: TextStyle(color: Colors.grey)),
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
          child: Text(
            'Collection Trend (Last 6 Months)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
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
                        return SideTitleWidget(
                          meta: meta,
                          space: 10,
                          child: Text(labels[index], style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
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
                    spots: spots,
                    isCurved: true,
                    color: Colors.greenAccent,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.greenAccent.withValues(alpha: 0.3),
                          Colors.greenAccent.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

}
