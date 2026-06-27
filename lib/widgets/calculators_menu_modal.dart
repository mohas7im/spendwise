import 'package:flutter/material.dart';
// We will import the actual calculator screens once we create them
import '../screens/calculators/savings_goal_screen.dart';
import '../screens/calculators/emi_calculator_screen.dart';
import '../screens/calculators/loan_affordability_screen.dart';
import '../screens/calculators/savings_growth_screen.dart';
import '../screens/calculators/fuel_consumption_screen.dart';

class CalculatorsMenuModal extends StatelessWidget {
  const CalculatorsMenuModal({super.key});

  @override
  Widget build(BuildContext context) {

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
              'All Calculators',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildSectionHeader('Savings & Investments'),
                  _CalculatorTile(
                    title: 'Savings Goal',
                    description: 'Calculate monthly savings needed for your goal.',
                    icon: Icons.track_changes,
                    color: Colors.green,
                    onTap: () => _openModal(context, const SavingsGoalScreen()),
                  ),
                  _CalculatorTile(
                    title: 'Savings Growth',
                    description: 'Compound interest & investment growth.',
                    icon: Icons.trending_up,
                    color: Colors.teal,
                    onTap: () => _openModal(context, const SavingsGrowthScreen()),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Loans & Debt'),
                  _CalculatorTile(
                    title: 'EMI / Loan',
                    description: 'Calculate monthly payments for any loan.',
                    icon: Icons.account_balance,
                    color: Colors.indigo,
                    onTap: () => _openModal(context, const EmiCalculatorScreen()),
                  ),
                  _CalculatorTile(
                    title: 'Loan Affordability',
                    description: 'How much loan can you afford?',
                    icon: Icons.real_estate_agent,
                    color: Colors.blue,
                    onTap: () => _openModal(context, const LoanAffordabilityScreen()),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader('Vehicle & Travel'),
                  _CalculatorTile(
                    title: 'Fuel Consumption',
                    description: 'Calculate mileage and cost per trip.',
                    icon: Icons.local_gas_station,
                    color: Colors.orange,
                    onTap: () => _openModal(context, const FuelConsumptionScreen()),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
      ),
    );
  }

  void _openModal(BuildContext context, Widget modalScreen) {
    Navigator.pop(context); // Close the menu
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => modalScreen,
    );
  }
}

class _CalculatorTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CalculatorTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Theme.of(context).primaryColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
