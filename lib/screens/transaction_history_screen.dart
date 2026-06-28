import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ledger_provider.dart';
import '../providers/finance_provider.dart';
import '../providers/split_provider.dart';
import '../providers/fuel_provider.dart';
import '../providers/vault_provider.dart';
import '../models/global_transaction.dart';
import '../widgets/ledger/global_transaction_card.dart';
import '../widgets/common/custom_bottom_sheet.dart';
import 'transaction_detail_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLedger();
    });
  }

  void _loadLedger() {
    final ledger = Provider.of<LedgerProvider>(context, listen: false);
    final finance = Provider.of<FinanceProvider>(context, listen: false);
    final split = Provider.of<SplitProvider>(context, listen: false);
    final fuel = Provider.of<FuelProvider>(context, listen: false);
    final vault = Provider.of<VaultProvider>(context, listen: false);
    
    ledger.buildLedger(finance, split, fuel, vault);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              final ledger = Provider.of<LedgerProvider>(context, listen: false);
              if (value == 'pdf') ledger.exportToPDF(context);
              if (value == 'csv') ledger.exportToCSV(context);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Export as PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Export as CSV'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<LedgerProvider>(
        builder: (context, ledger, child) {
          return Column(
            children: [
              // Analytics Summary
              if (!ledger.isSelectionMode)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Income', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text('₹${ledger.totalIncome.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.green)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Expense', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text('₹${ledger.totalExpense.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Count', style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text('${ledger.transactions.length}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.blueAccent)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Search Bar & Filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search transactions...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey.withValues(alpha: 0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) => ledger.setSearchQuery(val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: () => _showFilterSheet(context, ledger),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),

              // Bulk Actions Bar
              if (ledger.isSelectionMode)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Text('${ledger.selectedIds.length} Selected', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bulk delete will be fully implemented soon')));
                            ledger.clearSelection();
                          },
                          tooltip: 'Delete Selected',
                        ),
                        IconButton(
                          icon: const Icon(Icons.picture_as_pdf),
                          onPressed: () => ledger.exportToPDF(context),
                          tooltip: 'Export PDF',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => ledger.clearSelection(),
                          tooltip: 'Cancel',
                        ),
                      ],
                    ),
                  ),
                ),

              if (!ledger.isSelectionMode)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Your Records', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.trending_up, color: Theme.of(context).primaryColor, size: 22),
                        onPressed: () => _showTrendModal(context, ledger),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

              // Transaction List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _loadLedger(),
                  child: ledger.transactions.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: ledger.transactions.length,
                          itemBuilder: (context, index) {
                            final t = ledger.transactions[index];
                            return GlobalTransactionCard(
                              transaction: t,
                              isSelectionMode: ledger.isSelectionMode,
                              isSelected: ledger.selectedIds.contains(t.id),
                              onTap: () {
                                if (ledger.isSelectionMode) {
                                  ledger.toggleSelection(t.id);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TransactionDetailScreen(transaction: t),
                                    ),
                                  );
                                }
                              },
                              onLongPress: () {
                                ledger.toggleSelection(t.id);
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('No transactions found', style: TextStyle(color: Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, LedgerProvider ledger) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AdvancedFilterSheet(ledger: ledger),
    );
  }
  void _showTrendModal(BuildContext context, LedgerProvider ledger) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomBottomSheet(
        title: 'Income vs Expense',
        isScrollable: false,
        child: _buildTrendChart(ledger.transactions, context),
      ),
    );
  }

  Widget _buildTrendChart(List<GlobalTransaction> transactions, BuildContext context) {
    final now = DateTime.now();
    List<FlSpot> incomeSpots = [];
    List<FlSpot> expenseSpots = [];
    List<FlSpot> savingSpots = [];
    List<String> labels = [];

    List<double> incomeSums = List.filled(6, 0.0);
    List<double> expenseSums = List.filled(6, 0.0);
    List<double> savingSums = List.filled(6, 0.0);

    for (int i = 5; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      labels.add(DateFormat('MMM').format(targetDate));

      double incSum = 0;
      double expSum = 0;

      for (final t in transactions) {
        if (t.date.year == targetDate.year && t.date.month == targetDate.month) {
          if (t.type == GlobalTransactionType.income) {
            incSum += t.amount;
          } else if (t.type == GlobalTransactionType.expense) {
            expSum += t.amount;
          }
        }
      }

      incomeSums[5 - i] = incSum;
      expenseSums[5 - i] = expSum;
      savingSums[5 - i] = incSum - expSum;

      incomeSpots.add(FlSpot((5 - i).toDouble(), incSum));
      expenseSpots.add(FlSpot((5 - i).toDouble(), expSum));
      savingSpots.add(FlSpot((5 - i).toDouble(), savingSums[5 - i]));
    }

    double maxInc = incomeSums.isEmpty ? 1000 : incomeSums.reduce((a, b) => a > b ? a : b);
    double maxExp = expenseSums.isEmpty ? 1000 : expenseSums.reduce((a, b) => a > b ? a : b);
    double maxY = maxInc > maxExp ? maxInc : maxExp;
    if (maxY == 0) maxY = 1000;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Wrap(
            spacing: 16,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  const Text('Income', style: TextStyle(fontSize: 12)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  const Text('Expense', style: TextStyle(fontSize: 12)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  const Text('Savings', style: TextStyle(fontSize: 12)),
                ],
              ),
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
                      String label = rodIndex == 0 ? 'Income' : (rodIndex == 1 ? 'Expense' : 'Savings');
                      return BarTooltipItem(
                        '$label\n₹${rod.toY.round()}',
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
                      BarChartRodData(toY: incomeSums[i], color: Colors.green, width: 6, borderRadius: BorderRadius.circular(2)),
                      BarChartRodData(toY: expenseSums[i], color: Colors.redAccent, width: 6, borderRadius: BorderRadius.circular(2)),
                      BarChartRodData(toY: savingSums[i].clamp(0.0, double.infinity), color: Colors.blueAccent, width: 6, borderRadius: BorderRadius.circular(2)),
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
}

class _AdvancedFilterSheet extends StatefulWidget {
  final LedgerProvider ledger;
  const _AdvancedFilterSheet({required this.ledger});

  @override
  State<_AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends State<_AdvancedFilterSheet> {
  String _sortField = 'date';
  bool _sortAscending = false;
  GlobalTransactionType? _typeFilter;
  String? _categoryFilter;

  @override
  void initState() {
    super.initState();
    _sortField = widget.ledger.sortField;
    _sortAscending = widget.ledger.sortAscending;
    _typeFilter = widget.ledger.typeFilter;
    if (widget.ledger.categoryFilter.isNotEmpty) {
      _categoryFilter = widget.ledger.categoryFilter.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      title: 'Filters & Sort',
      saveText: 'Apply Filters',
      onSave: () {
        widget.ledger.setTypeFilter(_typeFilter);
        widget.ledger.setAdvancedFilters(
          categoryFilter: _categoryFilter != null ? [_categoryFilter!] : [],
        );
        widget.ledger.setSort(_sortField, _sortAscending);
        Navigator.pop(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Date'),
                selected: _sortField == 'date',
                onSelected: (val) => setState(() => _sortField = 'date'),
              ),
              ChoiceChip(
                label: const Text('Amount'),
                selected: _sortField == 'amount',
                onSelected: (val) => setState(() => _sortField = 'amount'),
              ),
              ChoiceChip(
                label: const Text('Category'),
                selected: _sortField == 'category',
                onSelected: (val) => setState(() => _sortField = 'category'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Ascending Order'),
            value: _sortAscending,
            onChanged: (val) => setState(() => _sortAscending = val),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          const Text('Transaction Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _typeFilter == null,
                onSelected: (val) => setState(() => _typeFilter = null),
              ),
              ChoiceChip(
                label: const Text('Income'),
                selected: _typeFilter == GlobalTransactionType.income,
                onSelected: (val) => setState(() => _typeFilter = GlobalTransactionType.income),
              ),
              ChoiceChip(
                label: const Text('Expense'),
                selected: _typeFilter == GlobalTransactionType.expense,
                onSelected: (val) => setState(() => _typeFilter = GlobalTransactionType.expense),
              ),
            ],
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _categoryFilter,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String>(value: null, child: Text('All')),
              const DropdownMenuItem(value: 'Food', child: Text('Food')),
              const DropdownMenuItem(value: 'Transport', child: Text('Transport')),
              const DropdownMenuItem(value: 'Shopping', child: Text('Shopping')),
              const DropdownMenuItem(value: 'Debt', child: Text('Debt')),
              const DropdownMenuItem(value: 'Subscriptions', child: Text('Subscriptions')),
              const DropdownMenuItem(value: 'Group Split', child: Text('Group Split')),
            ],
            onChanged: (val) => setState(() => _categoryFilter = val),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

}
