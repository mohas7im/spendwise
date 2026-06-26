import 'package:flutter/material.dart';
import '../models/transaction.dart';

class UnifiedActivityCard extends StatelessWidget {
  final ActivityItem activity;

  const UnifiedActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (activity.type) {
      case ActivityType.income:
        icon = Icons.attach_money;
        iconColor = Colors.green;
        bgColor = Colors.green.withValues(alpha: 0.1);
        break;
      case ActivityType.debtPayment:
        icon = activity.isCredit ? Icons.arrow_downward : Icons.arrow_upward;
        iconColor = activity.isCredit ? Colors.green : Colors.redAccent;
        bgColor = activity.isCredit ? Colors.green.withValues(alpha: 0.1) : Colors.redAccent.withValues(alpha: 0.1);
        break;
      case ActivityType.settlement:
        icon = Icons.handshake;
        iconColor = Colors.blue;
        bgColor = Colors.blue.withValues(alpha: 0.1);
        break;
      case ActivityType.transaction:
      default:
        icon = activity.isCredit ? Icons.trending_up : Icons.receipt_long;
        iconColor = activity.isCredit ? Colors.green : Theme.of(context).primaryColor;
        bgColor = activity.isCredit ? Colors.green.withValues(alpha: 0.1) : Theme.of(context).primaryColor.withValues(alpha: 0.1);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(activity.subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${activity.isCredit ? '+' : '-'}₹${activity.amount.toStringAsFixed(0)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: activity.isCredit ? Colors.green : null),
              ),
              const SizedBox(height: 4),
              Text(
                '${activity.date.day}/${activity.date.month}/${activity.date.year}',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
