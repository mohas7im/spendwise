import 'package:flutter/material.dart';
import '../widgets/calculators_menu_modal.dart';
import '../widgets/common/premium_gradient_card.dart';
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Finance Hub',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.calculate, color: Colors.blueAccent),
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
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'Your financial overview, debts, and growth.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildSummaryDashboard(context),
              ),
              const SizedBox(height: 24),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildModuleCards(context),
              ),
            ],
          ),
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
        _buildVaultTile(
          context: context,
          title: 'Debts & Loans',
          subtitle: 'Track people who owe you, and EMIs.',
          icon: Icons.account_balance_wallet,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const DebtsManagerModal(),
            );
          },
        ),
        _buildVaultTile(
          context: context,
          title: 'Savings Goals',
          subtitle: 'Set and track your savings targets.',
          icon: Icons.track_changes,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const SavingsGoalsModal(),
            );
          },
        ),
        _buildVaultTile(
          context: context,
          title: 'Growth & Investments',
          subtitle: 'Track your Mutual Funds and FDs.',
          icon: Icons.trending_up,
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

  Widget _buildVaultTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Icon(icon, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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

  Widget _buildSummaryDashboard(BuildContext context) {
    return PremiumGradientCard(
      builder: (context, textColor, subTextColor) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Net Balance', style: TextStyle(color: subTextColor, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1), 
                  borderRadius: BorderRadius.circular(12)
                ),
                child: const Text('+12%', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('₹1,45,000', style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryStat(context, 'I Owe', '₹12,500', Colors.red, textColor, subTextColor),
              _buildSummaryStat(context, 'Owed to Me', '₹4,200', Colors.green, textColor, subTextColor),
              _buildSummaryStat(context, 'EMIs Due', '₹8,500', Colors.orange, textColor, subTextColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(BuildContext context, String label, String value, Color iconColor, Color textColor, Color subTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: subTextColor, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(value, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
