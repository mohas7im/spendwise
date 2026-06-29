import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../providers/budget_provider.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import 'add_transaction_modal.dart';

// ─── CATEGORY META ────────────────────────────────────────────────────────────
class _CatMeta {
  static const Map<String, Map<String, dynamic>> data = {
    'Food & Drink': {'emoji': '🍔', 'color': Color(0xFFEF4444)},
    'Groceries': {'emoji': '🛒', 'color': Color(0xFF10B981)},
    'Transport': {'emoji': '🚕', 'color': Color(0xFF3B82F6)},
    'Shopping': {'emoji': '🛍️', 'color': Color(0xFFF59E0B)},
    'Entertainment': {'emoji': '🎬', 'color': Color(0xFF8B5CF6)},
    'Health': {'emoji': '💊', 'color': Color(0xFFEC4899)},
    'Bills': {'emoji': '📄', 'color': Color(0xFF6B7280)},
    'Invest': {'emoji': '📈', 'color': Color(0xFF06B6D4)},
    'Rent': {'emoji': '🏠', 'color': Color(0xFFD97706)},
    'Income': {'emoji': '💰', 'color': Color(0xFF10B981)},
    'Other': {'emoji': '📦', 'color': Color(0xFF9CA3AF)},
  };

  static Color color(String cat) => (data[cat]?['color'] as Color?) ?? const Color(0xFF9CA3AF);
  static String emoji(String cat) => (data[cat]?['emoji'] as String?) ?? '📦';
}

// ─── MAIN SHEET ENTRY ─────────────────────────────────────────────────────────
void showSpendingBreakdownSheet(BuildContext context, String period) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SpendingBreakdownSheet(period: period),
  );
}

class SpendingBreakdownSheet extends StatefulWidget {
  final String period;
  const SpendingBreakdownSheet({super.key, required this.period});

  @override
  State<SpendingBreakdownSheet> createState() => _SpendingBreakdownSheetState();
}

class _SpendingBreakdownSheetState extends State<SpendingBreakdownSheet> with TickerProviderStateMixin {
  String? _selectedCategory;
  late final AnimationController _animCtrl;
  late final Animation<Offset> _slideAnim;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _openCategory(String cat) {
    setState(() => _selectedCategory = cat);
    _animCtrl.reset();
    _animCtrl.forward();
  }

  void _backToOverview() {
    setState(() => _selectedCategory = null);
    _animCtrl.reset();
    _animCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final limits = budgetProvider.budget.categoryLimits;
    final summary = provider.spendingSummary(widget.period);
    final categoryBreakdown = summary['categoryBreakdown'] as Map<String, Map<String, dynamic>>;
    final allTxs = summary['transactions'] as List<TransactionModel>;
    final total = summary['total'] as double;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    final subTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? (isDark ? Colors.white70 : Colors.black54);
    final fmt = NumberFormat('#,##,##0', 'en_IN');

    return FractionallySizedBox(
      heightFactor: 0.93,
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  if (_selectedCategory != null)
                    GestureDetector(
                      onTap: _backToOverview,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.arrow_back_ios_new, size: 16, color: textColor),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.close, size: 16, color: textColor),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCategory != null ? _selectedCategory! : widget.period,
                          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        if (_selectedCategory == null)
                          Text('Spending Breakdown', style: TextStyle(color: subTextColor, fontSize: 12)),
                      ],
                    ),
                  ),
                  // Add transaction shortcut
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const AddTransactionModal(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 16, color: Theme.of(context).colorScheme.onPrimary),
                          const SizedBox(width: 4),
                          Text('Add', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SlideTransition(
                position: _slideAnim,
                child: _selectedCategory != null
                    ? _CategoryDetailView(
                        category: _selectedCategory!,
                        transactions: (categoryBreakdown[_selectedCategory]!['transactions'] as List<TransactionModel>)
                          ..sort((a, b) => b.date.compareTo(a.date)),
                        textColor: textColor,
                        subTextColor: subTextColor,
                        cardColor: cardColor,
                        fmt: fmt,
                        onEdit: (tx) {
                          _backToOverview();
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => AddTransactionModal(editingTransaction: tx),
                          );
                        },
                        onDelete: (tx) {
                          provider.deleteTransaction(tx.id);
                          _backToOverview();
                        },
                      )
                    : _OverviewBody(
                        total: total,
                        period: widget.period,
                        pctChange: summary['pctChange'] as double?,
                        count: summary['count'] as int,
                        categoryBreakdown: categoryBreakdown,
                        allTxs: allTxs,
                        limits: limits,
                        onCategoryTap: _openCategory,
                        touchedIndex: _touchedIndex,
                        onTouched: (i) => setState(() => _touchedIndex = i),
                        textColor: textColor,
                        subTextColor: subTextColor,
                        cardColor: cardColor,
                        surfaceColor: surfaceColor,
                        fmt: fmt,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── OVERVIEW BODY ────────────────────────────────────────────────────────────
class _OverviewBody extends StatelessWidget {
  final double total;
  final String period;
  final double? pctChange;
  final int count;
  final Map<String, Map<String, dynamic>> categoryBreakdown;
  final List<TransactionModel> allTxs;
  final List<CategoryLimit> limits;
  final void Function(String) onCategoryTap;
  final int touchedIndex;
  final void Function(int) onTouched;
  final Color textColor, subTextColor, cardColor, surfaceColor;
  final NumberFormat fmt;

  const _OverviewBody({
    required this.total, required this.period, required this.pctChange, required this.count,
    required this.categoryBreakdown, required this.allTxs, required this.limits, required this.onCategoryTap,
    required this.touchedIndex, required this.onTouched,
    required this.textColor, required this.subTextColor, required this.cardColor, required this.surfaceColor, required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = categoryBreakdown.entries.toList()
      ..sort((a, b) => (b.value['total'] as double).compareTo(a.value['total'] as double));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Hero Card ──
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Spent', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8), fontSize: 14)),
              const SizedBox(height: 8),
              Text('₹${fmt.format(total)}',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatChip(label: '$count transactions', icon: Icons.receipt_long),
                  const SizedBox(width: 12),
                  if (pctChange != null)
                    _StatChip(
                      label: '${pctChange! >= 0 ? '+' : ''}${pctChange!.toStringAsFixed(1)}% vs prior',
                      icon: pctChange! >= 0 ? Icons.trending_up : Icons.trending_down,
                      isUp: pctChange! >= 0,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Pie Chart ──
        if (sorted.isNotEmpty) ...[
          Text('By Category', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(touchCallback: (e, r) {
                        if (r?.touchedSection != null) {
                          onTouched(r!.touchedSection!.touchedSectionIndex);
                        } else {
                          onTouched(-1);
                        }
                      }),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 3,
                      centerSpaceRadius: 48,
                      sections: sorted.asMap().entries.map((entry) {
                        final i = entry.key;
                        final cat = entry.value.key;
                        final catTotal = entry.value.value['total'] as double;
                        final isTouched = i == touchedIndex;
                        return PieChartSectionData(
                          color: _CatMeta.color(cat),
                          value: catTotal,
                          title: isTouched ? '${(catTotal / total * 100).toStringAsFixed(1)}%' : '',
                          radius: isTouched ? 60 : 50,
                          titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 130,
                  child: ListView.builder(
                    itemCount: sorted.length,
                    itemBuilder: (_, i) {
                      final cat = sorted[i].key;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(width: 10, height: 10, decoration: BoxDecoration(color: _CatMeta.color(cat), borderRadius: BorderRadius.circular(3))),
                            const SizedBox(width: 6),
                            Expanded(child: Text('${_CatMeta.emoji(cat)} $cat', style: TextStyle(fontSize: 11, color: subTextColor), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // ── Category Rows ──
        Text('Category Limits & Spend', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ...sorted.map((entry) {
          final cat = entry.key;
          final catTotal = entry.value['total'] as double;
          final catCount = entry.value['count'] as int;
          
          LimitPeriod? limitPeriod;
          switch (period) {
            case 'Today': limitPeriod = LimitPeriod.daily; break;
            case 'This Week': limitPeriod = LimitPeriod.weekly; break;
            case 'This Month': limitPeriod = LimitPeriod.monthly; break;
            case 'This Year': limitPeriod = LimitPeriod.yearly; break;
          }

          CategoryLimit? matchedLimit;
          if (limitPeriod != null) {
            try {
              matchedLimit = limits.firstWhere((l) => l.category == cat && l.period == limitPeriod);
            } catch (e) {
              // No limit found
            }
          }

          final bool hasLimit = matchedLimit != null && matchedLimit.limitAmount > 0;
          final double limitAmt = hasLimit ? matchedLimit.limitAmount : 0.0;
          final pct = hasLimit ? (catTotal / limitAmt).clamp(0.0, 1.0) : (total > 0 ? catTotal / total : 0.0);
          final bool isOver = hasLimit && catTotal > limitAmt;

          return GestureDetector(
            onTap: () => onCategoryTap(cat),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: _CatMeta.color(cat).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Text(_CatMeta.emoji(cat), style: const TextStyle(fontSize: 20))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cat, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('$catCount transaction${catCount != 1 ? 's' : ''}', style: TextStyle(color: subTextColor, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${fmt.format(catTotal)}', style: TextStyle(color: isOver ? Colors.red.shade900 : textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                          if (hasLimit)
                            Text('of ₹${fmt.format(limitAmt)} limit', style: TextStyle(color: subTextColor, fontSize: 11))
                          else
                            Text('${(pct * 100).toStringAsFixed(1)}% of total', style: TextStyle(color: subTextColor, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: subTextColor, size: 18),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: _CatMeta.color(cat).withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(isOver ? Colors.red.shade900 : _CatMeta.color(cat)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── CATEGORY DETAIL VIEW ─────────────────────────────────────────────────────
class _CategoryDetailView extends StatelessWidget {
  final String category;
  final List<TransactionModel> transactions;
  final Color textColor, subTextColor, cardColor;
  final NumberFormat fmt;
  final void Function(TransactionModel) onEdit;
  final void Function(TransactionModel) onDelete;

  const _CategoryDetailView({
    required this.category, required this.transactions,
    required this.textColor, required this.subTextColor, required this.cardColor,
    required this.fmt, required this.onEdit, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final total = transactions.fold(0.0, (s, t) => s + t.amount);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Summary chip
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _CatMeta.color(category).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _CatMeta.color(category).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Text(_CatMeta.emoji(category), style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('₹${fmt.format(total)}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 28)),
                  Text('${transactions.length} transaction${transactions.length != 1 ? 's' : ''}', style: TextStyle(color: subTextColor, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Transactions', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ...transactions.map((tx) => _TxTile(
          tx: tx,
          textColor: textColor, subTextColor: subTextColor, cardColor: cardColor, fmt: fmt,
          onEdit: () => onEdit(tx),
          onDelete: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Delete Transaction'),
                content: Text('Delete "${tx.title}"?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () { Navigator.pop(context); onDelete(tx); },
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        )),
      ],
    );
  }
}

// ─── TRANSACTION TILE ─────────────────────────────────────────────────────────
class _TxTile extends StatelessWidget {
  final TransactionModel tx;
  final Color textColor, subTextColor, cardColor;
  final NumberFormat fmt;
  final VoidCallback onEdit, onDelete;

  const _TxTile({required this.tx, required this.textColor, required this.subTextColor, required this.cardColor, required this.fmt, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final payLabel = tx.paymentMethod.isNotEmpty == true ? tx.paymentMethod : '';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: _CatMeta.color(tx.category).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(_CatMeta.emoji(tx.category), style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(DateFormat('d MMM, hh:mm a').format(tx.date), style: TextStyle(color: subTextColor, fontSize: 11)),
                    if (payLabel.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: subTextColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                        child: Text(payLabel, style: TextStyle(color: subTextColor, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text('₹${fmt.format(tx.amount)}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: subTextColor, size: 18),
            onSelected: (v) { if (v == 'edit') {
              onEdit();
            } else {
              onDelete();
            } },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit')])),
              PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── HELPERS ──────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool? isUp;
  const _StatChip({required this.label, required this.icon, this.isUp});

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final color = isUp == null ? onPrimary : (isUp! ? const Color(0xFFEF4444) : const Color(0xFF10B981));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: onPrimary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

