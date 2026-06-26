import 'package:flutter/material.dart';
import 'common/premium_gradient_card.dart';

class PremiumBalanceCard extends StatelessWidget {
  final double balance;
  
  const PremiumBalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return PremiumGradientCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 32,
      builder: (context, textColor, subTextColor) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: TextStyle(color: subTextColor, fontSize: 16),
              ),
              Icon(Icons.more_horiz, color: subTextColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${balance.toStringAsFixed(2)}',
            style: TextStyle(
              color: textColor,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '****  ****  ****  4023',
                style: TextStyle(color: subTextColor, fontSize: 16, letterSpacing: 2),
              ),
              Row(
                children: [
                  Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.8), shape: BoxShape.circle),
                  ),
                  Transform.translate(
                    offset: const Offset(-6, 0),
                    child: Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.8), shape: BoxShape.circle),
                    ),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

class ActionPillRow extends StatelessWidget {
  final double income;
  final double expense;

  const ActionPillRow({super.key, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildMetricCard(context, 'Income', income, Icons.arrow_downward, Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard(context, 'Expense', expense, Icons.arrow_upward, Colors.redAccent)),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13)),
              const SizedBox(height: 4),
              Text('\$${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }
}

