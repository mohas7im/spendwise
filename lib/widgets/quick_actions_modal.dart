import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/add_transaction_modal.dart';

class QuickActionsModal extends StatelessWidget {
  const QuickActionsModal({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;

    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                children: [
                  _ActionTile(
                    icon: Icons.add_circle,
                    label: 'Transaction',
                    color: primary,
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => const AddTransactionModal(),
                      );
                    },
                  ),
                  _ActionTile(icon: Icons.account_balance, label: 'Add Debt', color: Colors.blue, onTap: () {}),
                  _ActionTile(icon: Icons.home_work, label: 'Add Loan', color: Colors.indigo, onTap: () {}),
                  _ActionTile(icon: Icons.receipt_long, label: 'Add EMI', color: Colors.orange, onTap: () {}),
                  _ActionTile(icon: Icons.local_gas_station, label: 'Add Fuel', color: Colors.teal, onTap: () {}),
                  _ActionTile(icon: Icons.group_work, label: 'Add Group Exp', color: Colors.purple, onTap: () {}),
                  _ActionTile(icon: Icons.pie_chart, label: 'Add Budget', color: Colors.cyan, onTap: () {}),
                  _ActionTile(icon: Icons.savings, label: 'Savings Goal', color: Colors.green, onTap: () {}),
                  _ActionTile(icon: Icons.calculate, label: 'Calculator', color: Colors.deepOrange, onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
