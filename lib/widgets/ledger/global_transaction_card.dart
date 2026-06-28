import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/global_transaction.dart';

class GlobalTransactionCard extends StatelessWidget {
  final GlobalTransaction transaction;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isSelectionMode;
  final EdgeInsetsGeometry margin;

  const GlobalTransactionCard({
    super.key,
    required this.transaction,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final bool isIncome = t.type == GlobalTransactionType.income;

    return Card(
      elevation: 0,
      margin: margin,
      color: isSelected 
          ? Theme.of(context).primaryColor.withValues(alpha: 0.1) 
          : Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected 
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2) 
            : BorderSide(color: Colors.grey.withValues(alpha: 0.1), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon or Checkbox
              if (isSelectionMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onTap(),
                )
              else
                CircleAvatar(
                  backgroundColor: t.color.withValues(alpha: 0.1),
                  child: Icon(t.icon, color: t.color),
                ),
              const SizedBox(width: 16),
              
              // Middle Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          t.category,
                          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
                        ),
                        if (t.person != null && t.person!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.person, size: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                          const SizedBox(width: 2),
                          Text(t.person!, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13)),
                        ]
                      ],
                    ),
                    if (t.hasAttachment) ...[
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(Icons.attach_file, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text('Has attachment', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Right side (Amount & Date)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'}₹${t.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: t.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, h:mm a').format(t.date),
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12),
                  ),
                  if (t.status == TransactionStatus.pending)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Pending', style: TextStyle(fontSize: 10, color: Colors.orange)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
