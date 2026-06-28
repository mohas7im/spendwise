import 'package:flutter/material.dart';
import '../widgets/calculators_menu_modal.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/common/premium_gradient_card.dart';
import 'modules/debts_manager_modal.dart';
import 'modules/savings_goals_modal.dart';
import 'transaction_history_screen.dart';
import 'income_salary_screen.dart';

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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildNetWorthTrend(context),
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
          title: 'Income & Salary',
          subtitle: 'Manage salary and income',
          icon: Icons.account_balance_wallet_outlined,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (ctx) => const IncomeSalaryScreen()));
          },
        ),
        _buildVaultTile(
          context: context,
          title: 'Master Transaction Ledger',
          subtitle: 'Manage all transactions',
          icon: Icons.receipt_long,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (ctx) => const TransactionHistoryScreen()));
          },
        ),
        _buildVaultTile(
          context: context,
          title: 'Debts & Loans',
          subtitle: 'Track people who owe you, and EMIs.',
          icon: Icons.account_balance_wallet,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (ctx) => const DebtsManagerModal()));
          },
        ),
        _buildVaultTile(
          context: context,
          title: 'Savings Goals',
          subtitle: 'Set and track your savings targets.',
          icon: Icons.track_changes,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (ctx) => const SavingsGoalsModal()));
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

  Widget _buildNetWorthTrend(BuildContext context) {
    return PremiumGradientCard(
      builder: (context, textColor, subTextColor) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Net Worth Trend', style: TextStyle(color: subTextColor, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2), 
                  borderRadius: BorderRadius.circular(12)
                ),
                child: const Text('+12.5%', style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('₹2,45,000', style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1.5),
                      FlSpot(1, 1.7),
                      FlSpot(2, 1.6),
                      FlSpot(3, 2.0),
                      FlSpot(4, 2.2),
                      FlSpot(5, 2.45),
                    ],
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryStat(context, 'Income', '₹1.2L', Colors.greenAccent, textColor, subTextColor),
              _buildSummaryStat(context, 'Savings', '₹45K', Colors.blueAccent, textColor, subTextColor),
              _buildSummaryStat(context, 'Debt', '₹12K', Colors.redAccent, textColor, subTextColor),
              _buildSummaryStat(context, 'Loans', '₹8K', Colors.orangeAccent, textColor, subTextColor),
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
