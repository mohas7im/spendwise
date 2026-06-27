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

  void _showAddSubscriptionModal(BuildContext context, FinanceProvider provider) {
    final nameCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    String cycle = 'Monthly';
    DateTime nextBilling = DateTime.now().add(const Duration(days: 30));

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
              Text('Add Subscription', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
                items: ['Monthly', 'Yearly'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setModalState(() => cycle = val!),
              ),
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
                      provider.addSubscription({
                        'name': nameCtrl.text,
                        'cost': double.parse(costCtrl.text),
                        'cycle': cycle,
                        'nextBilling': nextBilling,
                        'color': Colors.deepPurpleAccent,
                        'icon': Icons.subscriptions,
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Add Subscription'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
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
                      onPressed: () => _showAddSubscriptionModal(context, financeProvider),
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
                                daysLeft == 0 ? 'Today' : 'In $daysLeft days',
                                style: TextStyle(
                                  color: daysLeft <= 3 ? Colors.redAccent : Colors.grey,
                                  fontWeight: daysLeft <= 3 ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
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
