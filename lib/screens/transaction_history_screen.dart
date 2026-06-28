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
              return IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterSheet(context, ledger),
              );
            },
          ),
        ],
      ),
      body: Consumer<LedgerProvider>(
        builder: (context, ledger, child) {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
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

              // Analytics Summary
              if (!ledger.isSelectionMode)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Income',
                          amount: ledger.totalIncome,
                          color: Colors.green,
                          icon: Icons.arrow_downward,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Expense',
                          amount: ledger.totalExpense,
                          color: Colors.red,
                          icon: Icons.arrow_upward,
                        ),
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
          const Text('No transactions found', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, LedgerProvider ledger) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter by Type', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                ActionChip(
                  label: const Text('All'),
                  onPressed: () {
                    ledger.setTypeFilter(null);
                    Navigator.pop(ctx);
                  },
                ),
                ActionChip(
                  label: const Text('Income'),
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  onPressed: () {
                    ledger.setTypeFilter(GlobalTransactionType.income);
                    Navigator.pop(ctx);
                  },
                ),
                ActionChip(
                  label: const Text('Expense'),
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  onPressed: () {
                    ledger.setTypeFilter(GlobalTransactionType.expense);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export All to PDF'),
                onPressed: () {
                  Navigator.pop(ctx);
                  ledger.exportToPDF(context);
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.table_chart),
                label: const Text('Export All to CSV'),
                onPressed: () {
                  Navigator.pop(ctx);
                  ledger.exportToCSV(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
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
    );
  }
}
