import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ledger_provider.dart';
import '../providers/finance_provider.dart';
import '../providers/split_provider.dart';
import '../providers/fuel_provider.dart';
import '../providers/vault_provider.dart';
import '../models/global_transaction.dart';
import '../widgets/ledger/global_transaction_card.dart';
import 'transaction_detail_screen.dart';

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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<LedgerProvider>(
            builder: (context, ledger, _) {
              if (ledger.isSelectionMode) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf),
                      onPressed: () => ledger.exportToPDF(context),
                      tooltip: 'Export PDF',
                    ),
                    IconButton(
                      icon: const Icon(Icons.table_chart),
                      onPressed: () => ledger.exportToCSV(context),
                      tooltip: 'Export CSV',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => ledger.clearSelection(),
                    ),
                  ],
                );
              }
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
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
              );
            },
          ),
        ],
      ),
      body: Consumer<LedgerProvider>(
        builder: (context, ledger, child) {
          return Column(
            children: [
              // Search Bar & Filter
              Padding(
                padding: const EdgeInsets.all(16),
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
                            borderRadius: BorderRadius.circular(12),
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
                        backgroundColor: Theme.of(context).cardColor,
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),

              // Analytics Summary
              if (!ledger.isSelectionMode)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _StatItem(label: 'Total Txns', value: '${ledger.transactions.length}', color: Colors.blueAccent),
                            _StatItem(label: 'Net Balance', value: '₹${ledger.netBalance.toStringAsFixed(0)}', color: Colors.white),
                            _StatItem(
                              label: 'Today', 
                              value: '${ledger.transactions.where((t) => t.date.day == DateTime.now().day && t.date.month == DateTime.now().month && t.date.year == DateTime.now().year).length}', 
                              color: Colors.orangeAccent
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(child: _SummaryCard(
                              title: 'Income',
                              amount: ledger.totalIncome,
                              color: Colors.green,
                              icon: Icons.arrow_downward,
                              isSelected: ledger.typeFilter == GlobalTransactionType.income,
                              onTap: () => ledger.setTypeFilter(ledger.typeFilter == GlobalTransactionType.income ? null : GlobalTransactionType.income),
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: _SummaryCard(
                              title: 'Expense',
                              amount: ledger.totalExpense,
                              color: Colors.red,
                              icon: Icons.arrow_upward,
                              isSelected: ledger.typeFilter == GlobalTransactionType.expense,
                              onTap: () => ledger.setTypeFilter(ledger.typeFilter == GlobalTransactionType.expense ? null : GlobalTransactionType.expense),
                            )),
                          ],
                        ),
                      ],
                    ),
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters & Sort', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
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
          const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _categoryFilter,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black12,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            hint: const Text('All Categories'),
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
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.ledger.setTypeFilter(_typeFilter);
                widget.ledger.setAdvancedFilters(
                  categoryFilter: _categoryFilter != null ? [_categoryFilter!] : [],
                );
                widget.ledger.setSort(_sortField, _sortAscending);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Apply Filters', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: color.withValues(alpha: 0.5), width: 2) : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  
  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
