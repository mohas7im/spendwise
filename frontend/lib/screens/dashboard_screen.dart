import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/finance_provider.dart';
import '../providers/ledger_provider.dart';
import '../providers/split_provider.dart';
import '../providers/fuel_provider.dart';
import '../providers/vault_provider.dart';
import '../main.dart'; // for ThemeProvider
import '../widgets/ledger/global_transaction_card.dart';
import '../widgets/spending_breakdown_sheet.dart';
import '../widgets/add_transaction_modal.dart';
import '../widgets/common/custom_bottom_sheet.dart';


import 'profile_screen.dart';
import 'transaction_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _profileName = 'Guest';
  String _profileAvatar = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLedger();
    });
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileName = prefs.getString('profile_name') ?? 'Guest';
      if (_profileName.isEmpty) _profileName = 'Guest';
      _profileAvatar = prefs.getString('profile_avatar') ?? '';
    });
  }

  void _loadLedger() {
    if (!mounted) return;
    final ledger = Provider.of<LedgerProvider>(context, listen: false);
    final finance = Provider.of<FinanceProvider>(context, listen: false);
    final split = Provider.of<SplitProvider>(context, listen: false);
    final fuel = Provider.of<FuelProvider>(context, listen: false);
    final vault = Provider.of<VaultProvider>(context, listen: false);
    
    ledger.buildLedger(finance, split, fuel, vault);
  }

  void _showNotificationsModal() {
    final finance = Provider.of<FinanceProvider>(context, listen: false);
    final now = DateTime.now();
    
    List<Map<String, dynamic>> alerts = [];
    
    // Check subscriptions
    for (var sub in finance.subscriptions) {
      if (!sub.isPaused) {
        final days = sub.nextBilling.difference(now).inDays;
        if (days >= 0 && days <= 3) {
          alerts.add({
            'title': 'Upcoming Subscription',
            'desc': '${sub.name} is due in ${days == 0 ? 'today' : '$days days'}',
            'icon': Icons.autorenew,
            'color': Colors.blue
          });
        }
      }
    }
    
    // Check debts
    for (var debt in finance.debts) {
      if (!debt.isPaid && debt.remainingAmount > 0) {
        if (debt.nextDueDate != null) {
          final days = debt.nextDueDate!.difference(now).inDays;
          if (days < 0) {
            alerts.add({
              'title': 'Overdue Debt',
              'desc': '${debt.personName} is overdue by ${days.abs()} days',
              'icon': Icons.warning,
              'color': Colors.red
            });
          } else if (days <= 3) {
            alerts.add({
              'title': 'Upcoming Debt',
              'desc': '${debt.personName} is due in ${days == 0 ? 'today' : '$days days'}',
              'icon': Icons.account_balance_wallet,
              'color': Colors.orange
            });
          }
        }
      }
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: CustomBottomSheet(
              title: 'Notifications',
              isTopSheet: true,
              child: alerts.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.notifications_off_outlined, size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text('No new notifications', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: alerts.map((alert) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: (alert['color'] as Color).withValues(alpha: 0.2),
                              child: Icon(alert['icon'] as IconData, color: alert['color'] as Color),
                            ),
                            title: Text(alert['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(alert['desc'] as String, style: const TextStyle(fontSize: 12)),
                          )).toList(),
                    ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOutQuart,
          )),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final financeProvider = Provider.of<FinanceProvider>(context);
    final ledger = Provider.of<LedgerProvider>(context);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                        _loadProfile();
                      },
                      child: _profileAvatar.isNotEmpty
                          ? CircleAvatar(
                              radius: 20,
                              backgroundImage: FileImage(File(_profileAvatar)),
                            )
                          : const CircleAvatar(
                              radius: 20,
                              child: Icon(Icons.person),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome Back,', style: Theme.of(context).textTheme.bodyMedium),
                        Text(_profileName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                      ],
                    )
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                      onPressed: () => themeProvider.toggleTheme(!isDark),
                    ),
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none, size: 20),
                        onPressed: _showNotificationsModal,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 120.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Financial Summary Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(28),
                border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1) : null,
                boxShadow: [
                  if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total balance', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text(
                    '₹${NumberFormat.decimalPattern('en_IN').format(ledger.netBalance)}',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: -1),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2E) : Colors.black,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.arrow_upward, color: Colors.black, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Income', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                                Text('₹${NumberFormat.compact().format(ledger.totalIncome)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.arrow_downward, color: Colors.black, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Spending', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                                Text('₹${NumberFormat.compact().format(ledger.totalExpense)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Spending Summary ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Spending Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    useSafeArea: true,
                    builder: (_) => const AddTransactionModal(),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 14, color: Theme.of(context).colorScheme.onPrimary),
                        const SizedBox(width: 4),
                        Text('Add', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SpendingSummaryGrid(financeProvider: financeProvider),
            const SizedBox(height: 32),

            // Unified Recent Activity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionHistoryScreen())),
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Builder(
              builder: (ctx) {
                final activities = ledger.transactions;
                if (activities.isEmpty) {
                  return const Center(child: Text('No recent activity.', style: TextStyle(color: Colors.grey)));
                }
                
                return Column(
                  children: activities.take(10).map((act) => GlobalTransactionCard(
                    transaction: act,
                    onTap: () {},
                    margin: const EdgeInsets.symmetric(vertical: 6),
                  )).toList(),
                );
              },
            ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SPENDING SUMMARY GRID ─────────────────────────────────────────────────────
class _SpendingSummaryGrid extends StatelessWidget {
  final FinanceProvider financeProvider;
  const _SpendingSummaryGrid({required this.financeProvider});

  @override
  Widget build(BuildContext context) {
    final periods = ['Today', 'This Week', 'This Month', 'This Year', 'All Time'];
    final fmt = NumberFormat('#,##,##0', 'en_IN');

    final Map<String, double> amounts = {
      'Today': financeProvider.spendingToday,
      'This Week': financeProvider.spendingThisWeek,
      'This Month': financeProvider.spendingThisMonth,
      'This Year': financeProvider.spendingThisYear,
      'All Time': financeProvider.totalExpenses,
    };

    final Map<String, Map<String, dynamic>> summaries = {
      for (var p in periods) p: financeProvider.spendingSummary(p),
    };

    return Column(children: [
      // First two side by side
      Row(
        children: [
          Expanded(child: _SummaryCard(period: 'Today', amount: amounts['Today']!, summary: summaries['Today']!, fmt: fmt)),
          const SizedBox(width: 12),
          Expanded(child: _SummaryCard(period: 'This Week', amount: amounts['This Week']!, summary: summaries['This Week']!, fmt: fmt)),
        ],
      ),
      const SizedBox(height: 12),
      // Next two side by side
      Row(
        children: [
          Expanded(child: _SummaryCard(period: 'This Month', amount: amounts['This Month']!, summary: summaries['This Month']!, fmt: fmt)),
          const SizedBox(width: 12),
          Expanded(child: _SummaryCard(period: 'This Year', amount: amounts['This Year']!, summary: summaries['This Year']!, fmt: fmt)),
        ],
      ),
      const SizedBox(height: 12),
      // All Time – full width
      _SummaryCard(period: 'All Time', amount: amounts['All Time']!, summary: summaries['All Time']!, fmt: fmt, fullWidth: true),
    ]);
  }
}

class _SummaryCard extends StatelessWidget {
  final String period;
  final double amount;
  final Map<String, dynamic> summary;
  final NumberFormat fmt;
  final bool fullWidth;

  const _SummaryCard({
    required this.period, required this.amount, required this.summary,
    required this.fmt, this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final count = summary['count'] as int;
    final pctChange = summary['pctChange'] as double?;
    final bool up = pctChange != null && pctChange >= 0;

    return GestureDetector(
      onTap: () => showSpendingBreakdownSheet(context, period),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: fullWidth
            ? Row(
                children: [
                  Expanded(child: _CardContent(period: period, amount: amount, count: count, pctChange: pctChange, up: up, fmt: fmt)),
                  Icon(Icons.chevron_right, color: Colors.grey.withValues(alpha: 0.5), size: 20),
                ],
              )
            : _CardContent(period: period, amount: amount, count: count, pctChange: pctChange, up: up, fmt: fmt),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final String period;
  final double amount;
  final int count;
  final double? pctChange;
  final bool up;
  final NumberFormat fmt;

  const _CardContent({required this.period, required this.amount, required this.count, required this.pctChange, required this.up, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(period, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
            if (pctChange != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: (up ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(up ? Icons.trending_up : Icons.trending_down, size: 10, color: up ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                    const SizedBox(width: 2),
                    Text('${up ? '+' : ''}${pctChange!.toStringAsFixed(0)}%',
                      style: TextStyle(color: up ? const Color(0xFFEF4444) : const Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text('₹${fmt.format(amount)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text('$count transaction${count != 1 ? 's' : ''}',
          style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
