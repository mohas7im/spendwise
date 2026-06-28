import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/global_transaction.dart';

class TransactionDetailScreen extends StatelessWidget {
  final GlobalTransaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final isIncome = t.type == GlobalTransactionType.income;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'edit') {
                // handle edit
              } else if (val == 'delete') {
                // handle delete
              } else if (val == 'duplicate') {
                // handle duplicate
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Amount
            CircleAvatar(
              radius: 40,
              backgroundColor: t.color.withValues(alpha: 0.1),
              child: Icon(t.icon, color: t.color, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              t.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${isIncome ? '+' : '-'}₹${t.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: t.color,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: t.status == TransactionStatus.pending ? Colors.orange.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                t.status.name.toUpperCase(),
                style: TextStyle(
                  color: t.status == TransactionStatus.pending ? Colors.orange : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Details Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _DetailRow(icon: Icons.calendar_today, label: 'Date', value: DateFormat('MMMM d, y - h:mm a').format(t.date)),
                  const Divider(height: 30),
                  _DetailRow(icon: Icons.category, label: 'Category', value: t.category),
                  const Divider(height: 30),
                  _DetailRow(icon: Icons.payment, label: 'Payment Method', value: t.paymentMethod),
                  const Divider(height: 30),
                  _DetailRow(icon: Icons.dashboard_customize, label: 'Source Module', value: t.sourceModule),
                  if (t.person != null && t.person!.isNotEmpty) ...[
                    const Divider(height: 30),
                    _DetailRow(icon: Icons.person, label: 'Person Involved', value: t.person!),
                  ],
                  if (t.notes.isNotEmpty) ...[
                    const Divider(height: 30),
                    _DetailRow(icon: Icons.note, label: 'Notes', value: t.notes),
                  ],
                  if (t.tags.isNotEmpty) ...[
                    const Divider(height: 30),
                    _DetailRow(icon: Icons.local_offer, label: 'Tags', value: t.tags.join(', ')),
                  ],
                  if (t.hasAttachment) ...[
                    const Divider(height: 30),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.attachment, color: Theme.of(context).primaryColor, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Attachments', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  Container(
                                    width: 60, height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    child: const Icon(Icons.image, color: Colors.white54),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit action navigates to source module in future')));
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Original Entry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 16),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
