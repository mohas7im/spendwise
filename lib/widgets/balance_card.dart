import 'package:flutter/material.dart';

class PremiumBalanceCard extends StatelessWidget {
  final double balance;
  
  const PremiumBalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2D34), Color(0xFF13151A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const Icon(Icons.more_horiz, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '****  ****  ****  4023',
                style: TextStyle(color: Colors.white54, fontSize: 16, letterSpacing: 2),
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
        Expanded(child: _buildMetricCard(context, 'Income', income, Icons.arrow_downward, Colors.green)),
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

