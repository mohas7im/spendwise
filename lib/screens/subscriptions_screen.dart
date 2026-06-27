import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../widgets/common/premium_gradient_card.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {

  void _showSubscriptionModal(BuildContext context, FinanceProvider provider, {int? editIndex, Map<String, dynamic>? existingSub}) {
    final nameCtrl = TextEditingController(text: existingSub?['name'] ?? '');
    final costCtrl = TextEditingController(text: existingSub?['cost']?.toString() ?? '');
    String cycle = existingSub?['cycle'] ?? 'Monthly';
    bool isCustom = cycle != 'Monthly' && cycle != 'Yearly';
    if (isCustom) {
      // If it's a custom cycle like "1000 Days", extract the number
      cycle = 'Custom (Days)';
    }
    final customDaysCtrl = TextEditingController(
      text: isCustom ? existingSub!['cycle'].toString().split(' ').first : '1000',
    );
    DateTime nextBilling = existingSub?['nextBilling'] ?? DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(editIndex == null ? 'Add Subscription' : 'Edit Subscription', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Subscription Name (e.g. Netflix)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: costCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cost (₹)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: cycle,
                decoration: const InputDecoration(labelText: 'Billing Cycle', border: OutlineInputBorder()),
                items: ['Monthly', 'Yearly', 'Custom (Days)'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setModalState(() => cycle = val!),
              ),
              if (cycle == 'Custom (Days)') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: customDaysCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Number of Days', border: OutlineInputBorder()),
                ),
              ],
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Next Billing Date'),
                subtitle: Text('${nextBilling.day}/${nextBilling.month}/${nextBilling.year}'),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: nextBilling,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (picked != null) {
                    setModalState(() => nextBilling = picked);
                  }
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty && costCtrl.text.isNotEmpty) {
                      final finalCycle = cycle == 'Custom (Days)' ? '${customDaysCtrl.text} Days' : cycle;
                      final subData = {
                        'name': nameCtrl.text,
                        'cost': double.parse(costCtrl.text),
                        'cycle': finalCycle,
                        'nextBilling': nextBilling,
                        'color': existingSub?['color'] ?? Colors.deepPurpleAccent,
                        'icon': existingSub?['icon'] ?? Icons.subscriptions,
                      };
                      if (editIndex != null) {
                        provider.updateSubscription(editIndex, subData);
                      } else {
                        provider.addSubscription(subData);
                      }
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(editIndex == null ? 'Add Subscription' : 'Update Subscription'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubscriptionDetails(BuildContext context, Map<String, dynamic> sub, FinanceProvider provider, int index) {
    final daysLeft = sub['nextBilling'].difference(DateTime.now()).inDays;
    
    // Mock some payment history based on cycle
    final history = List.generate(3, (i) {
      DateTime payDate;
      if (sub['cycle'] == 'Monthly') {
        payDate = sub['nextBilling'].subtract(Duration(days: 30 * (i + 1)));
      } else if (sub['cycle'] == 'Yearly') {
        payDate = sub['nextBilling'].subtract(Duration(days: 365 * (i + 1)));
      } else {
        // Handle custom days, e.g., "1000 Days"
        final days = int.tryParse(sub['cycle'].toString().split(' ').first) ?? 30;
        payDate = sub['nextBilling'].subtract(Duration(days: days * (i + 1)));
      }
      return {'date': payDate, 'amount': sub['cost']};
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (sub['color'] as Color).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(sub['icon'], color: sub['color'], size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sub['name'], style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text('${sub['cycle']} Plan', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (val) {
                    Navigator.pop(ctx);
                    if (val == 'edit') {
                      _showSubscriptionModal(context, provider, editIndex: index, existingSub: sub);
                    } else if (val == 'delete') {
                      provider.deleteSubscription(index);
                    }
                  },
                  itemBuilder: (c) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            
            // Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Amount', style: TextStyle(color: Colors.grey)),
                    Text('₹${sub['cost'].toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Next Billing', style: TextStyle(color: Colors.grey)),
                    Text(
                      '${sub['nextBilling'].day}/${sub['nextBilling'].month}/${sub['nextBilling'].year}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                        color: daysLeft <= 3 ? Colors.redAccent : Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Text('Payment History', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // Mock History List
            ...history.map((h) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                child: const Icon(Icons.check, color: Colors.green),
              ),
              title: Text('₹${h['amount'].toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${(h['date'] as DateTime).day}/${(h['date'] as DateTime).month}/${(h['date'] as DateTime).year} • Paid automatically'),
            )),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final _subscriptions = financeProvider.subscriptions;

    double totalMonthly = _subscriptions.where((s) => s['cycle'] == 'Monthly').fold(0, (sum, s) => sum + s['cost']);
    double totalYearly = _subscriptions.where((s) => s['cycle'] == 'Yearly').fold(0, (sum, s) => sum + s['cost']);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    Text('Subscriptions', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _showSubscriptionModal(context, financeProvider),
                      icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor, size: 28),
                    ),
                  ],
                ),
              ),

              // Summary Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: PremiumGradientCard(
                  builder: (context, textColor, subTextColor) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Monthly Bills', style: TextStyle(color: subTextColor, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        '₹${totalMonthly.toStringAsFixed(0)}',
                        style: TextStyle(color: textColor, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Yearly Bills', style: TextStyle(color: subTextColor, fontSize: 11)),
                              Text('₹${totalYearly.toStringAsFixed(0)}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Active Subs', style: TextStyle(color: subTextColor, fontSize: 11)),
                              Text('${_subscriptions.length}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('Upcoming Renewals', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
              ),

              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _subscriptions.length,
                itemBuilder: (context, index) {
                  final sub = _subscriptions[index];
                  final daysLeft = sub['nextBilling'].difference(DateTime.now()).inDays;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showSubscriptionDetails(context, sub, financeProvider, index),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (sub['color'] as Color).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(sub['icon'], color: sub['color'], size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(sub['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(sub['cycle'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('₹${sub['cost'].toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(
                                  daysLeft == 0 ? 'Today' : (daysLeft < 0 ? 'Overdue' : 'In $daysLeft days'),
                                  style: TextStyle(
                                    color: daysLeft <= 3 ? Colors.redAccent : Colors.grey,
                                    fontWeight: daysLeft <= 3 ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Colors.grey),
                              onSelected: (val) {
                                if (val == 'edit') {
                                  _showSubscriptionModal(context, financeProvider, editIndex: index, existingSub: sub);
                                } else if (val == 'delete') {
                                  financeProvider.deleteSubscription(index);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
