import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    // Determine icon based on category
    String emoji = '☕';
    Color iconBgColor = const Color(0xFFF7F2EC);
    if (transaction.title.toLowerCase().contains('salary')) {
      emoji = '💵';
      iconBgColor = const Color(0xFFE4F5E9);
    } else if (transaction.title.toLowerCase().contains('whole foods')) {
      emoji = '🛒';
      iconBgColor = const Color(0xFFE8F0FE);
    }

    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? Colors.green : Colors.redAccent;
    final sign = isIncome ? '+' : '-';
    
    // Category tag color
    Color tagBgColor = Colors.orange.withOpacity(0.1);
    Color tagTextColor = Colors.orange;
    if (isIncome) {
      tagBgColor = Colors.green.withOpacity(0.1);
      tagTextColor = Colors.green;
    } else if (transaction.title.toLowerCase().contains('whole foods')) {
      tagBgColor = Colors.blue.withOpacity(0.1);
      tagTextColor = Colors.blue;
    }

    // Is Dark mode?
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: isDark ? iconBgColor.withOpacity(0.2) : iconBgColor, shape: BoxShape.circle),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      transaction.category,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: tagBgColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, color: tagTextColor, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            transaction.category.split(' ').first,
                            style: TextStyle(color: tagTextColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign\$${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '2m ago',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

