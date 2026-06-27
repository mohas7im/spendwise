import 'package:flutter/material.dart';
import '../widgets/calculators_menu_modal.dart';
import 'modules/debts_manager_modal.dart';
import 'modules/savings_goals_modal.dart';
import 'modules/savings_growth_modal.dart';

class FinanceHubScreen extends StatefulWidget {
  const FinanceHubScreen({super.key});

  @override
  State<FinanceHubScreen> createState() => _FinanceHubScreenState();
}

class _FinanceHubScreenState extends State<FinanceHubScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Finance Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.calculate, color: Theme.of(context).primaryColor),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => const CalculatorsMenuModal(),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryDashboard(context),
            const SizedBox(height: 24),
            _buildModuleCards(context),
            const SizedBox(height: 100), // padding for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Finance Modules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _ModuleCard(
          title: 'Debts & Loans',
          description: 'Track people who owe you, EMIs, and active debts.',
          icon: Icons.account_balance_wallet,
          color: Colors.blue,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const DebtsManagerModal(),
            );
          },
        ),
        const SizedBox(height: 16),
        _ModuleCard(
          title: 'Savings Goals',
          description: 'Set and track your goals for a car, vacation, or home.',
          icon: Icons.track_changes,
          color: Colors.green,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const SavingsGoalsModal(),
            );
          },
        ),
        const SizedBox(height: 16),
        _ModuleCard(
          title: 'Growth & Investments',
          description: 'Track your Mutual Funds, FDs, and compound returns.',
          icon: Icons.trending_up,
          color: Colors.teal,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const SavingsGrowthModal(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryDashboard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Net Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                child: const Text('+12%', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('₹1,45,000', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryStat('I Owe', '₹12,500', Colors.redAccent),
              _buildSummaryStat('Owed to Me', '₹4,200', Colors.greenAccent),
              _buildSummaryStat('EMIs Due', '₹8,500', Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
