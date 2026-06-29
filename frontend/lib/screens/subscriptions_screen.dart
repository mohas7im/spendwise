import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/subscription.dart';
import '../widgets/common/custom_bottom_sheet.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  String _sortBy = 'Date';
  bool _showYearly = false;

  void _showSubscriptionModal(
    BuildContext context,
    FinanceProvider provider, {
    SubscriptionModel? existingSub,
  }) {
    final nameCtrl = TextEditingController(text: existingSub?.name ?? '');
    final costCtrl = TextEditingController(
      text: existingSub?.cost.toString() ?? '',
    );

    String cycle = existingSub?.cycle ?? 'Monthly';
    bool isCustom = cycle != 'Monthly' && cycle != 'Yearly';
    if (isCustom) cycle = 'Custom (Days)';

    final customDaysCtrl = TextEditingController(
      text: isCustom ? existingSub?.customDays?.toString() ?? '30' : '30',
    );
    DateTime nextBilling =
        existingSub?.nextBilling ??
        DateTime.now().add(const Duration(days: 30));

    int selectedColor =
        existingSub?.colorValue ?? Colors.deepPurpleAccent.toARGB32();
    int selectedIcon =
        existingSub?.iconCodePoint ?? Icons.subscriptions.codePoint;
    String currency = existingSub?.currency ?? '₹';

    final colors = [
      Colors.deepPurpleAccent,
      Colors.redAccent,
      Colors.green,
      Colors.blueAccent,
      Colors.orange,
      Colors.pink,
    ];
    final icons = [
      Icons.subscriptions,
      Icons.movie,
      Icons.music_note,
      Icons.fitness_center,
      Icons.shopping_cart,
      Icons.videogame_asset,
      Icons.wifi,
      Icons.phone_android,
    ];
    final currencies = ['₹', '\$', '€', '£'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => CustomBottomSheet(
          title: existingSub == null ? 'Add Subscription' : 'Edit Subscription',
          saveText: existingSub == null ? 'Add Subscription' : 'Save Changes',
          onSave: () {
            if (nameCtrl.text.isNotEmpty && costCtrl.text.isNotEmpty) {
              final parsedDays = int.tryParse(customDaysCtrl.text) ?? 30;
              final sub = SubscriptionModel(
                id: existingSub?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameCtrl.text,
                cost: double.parse(costCtrl.text),
                cycle: cycle == 'Custom (Days)' ? '$parsedDays Days' : cycle,
                customDays: cycle == 'Custom (Days)' ? parsedDays : null,
                nextBilling: nextBilling,
                colorValue: selectedColor,
                iconCodePoint: selectedIcon,
                currency: currency,
                isPaused: existingSub?.isPaused ?? false,
                paymentHistory: existingSub?.paymentHistory,
              );

              if (existingSub != null) {
                provider.updateSubscription(sub.id, sub);
              } else {
                provider.addSubscription(sub);
              }
              Navigator.pop(ctx);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: currency,
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                        border: OutlineInputBorder(),
                      ),
                      items: currencies
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => setModalState(() => currency = val!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 5,
                    child: TextField(
                      controller: costCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cost',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Subscription Name (e.g. Netflix)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: cycle,
                decoration: const InputDecoration(
                  labelText: 'Billing Cycle',
                  border: OutlineInputBorder(),
                ),
                items: ['Monthly', 'Yearly', 'Custom (Days)']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setModalState(() => cycle = val!),
              ),
              if (cycle == 'Custom (Days)') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: customDaysCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Number of Days',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Next Billing Date'),
                subtitle: Text(
                  '${nextBilling.day}/${nextBilling.month}/${nextBilling.year}',
                ),
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

              const Text(
                'Color',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: colors
                    .map(
                      (c) => GestureDetector(
                        onTap: () =>
                            setModalState(() => selectedColor = c.toARGB32()),
                        child: CircleAvatar(
                          backgroundColor: c,
                          radius: 20,
                          child: selectedColor == c.toARGB32()
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),

              const Text(
                'Icon',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: icons
                    .map(
                      (icon) => GestureDetector(
                        onTap: () => setModalState(
                          () => selectedIcon = icon.codePoint,
                        ),
                        child: CircleAvatar(
                          backgroundColor: selectedIcon == icon.codePoint
                              ? Color(selectedColor)
                              : Colors.grey.withValues(alpha: 0.2),
                          radius: 20,
                          child: Icon(
                            icon,
                            color: selectedIcon == icon.codePoint
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              if (existingSub != null)
                SwitchListTile(
                  title: const Text('Pause Subscription'),
                  subtitle: const Text('Temporarily disable auto-tracking'),
                  value: existingSub.isPaused,
                  onChanged: (val) {
                    setModalState(() => existingSub.isPaused = val);
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoryModal(BuildContext context, SubscriptionModel sub) {
    final history = List<SubscriptionPayment>.from(sub.paymentHistory);
    history.sort((a, b) => b.date.compareTo(a.date));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomBottomSheet(
        title: 'Payment History',
        isScrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (history.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No history yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: history.length,
                  itemBuilder: (_, i) {
                    final item = history[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.check, color: Colors.green, size: 20),
                      ),
                      title: Text('${item.date.day}/${item.date.month}/${item.date.year}'),
                      subtitle: Text(item.status),
                      trailing: Text(
                        '${sub.currency}${item.amount}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLogPaymentModal(BuildContext context, SubscriptionModel sub, FinanceProvider provider) {
    final amountCtrl = TextEditingController(text: sub.cost.toStringAsFixed(0));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomBottomSheet(
        title: 'Log Payment',
        saveText: 'Log Payment',
        onSave: () {
          final val = double.tryParse(amountCtrl.text) ?? 0;
          if (val > 0) {
            sub.paymentHistory.add(SubscriptionPayment(
                date: DateTime.now(),
                amount: val,
                status: 'Success'
            ));
            provider.updateSubscription(sub.id, sub);
            Navigator.pop(ctx);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Logging payment for ${sub.name}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount Paid',
                prefixText: '${sub.currency} ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, SubscriptionModel sub, FinanceProvider provider, int daysLeft) {
    final isPaused = sub.isPaused;
    return Opacity(
      opacity: isPaused ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: sub.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(sub.icon, color: sub.color, size: 24),
              ),
              title: Text(
                sub.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '${sub.currency}${sub.cost.toStringAsFixed(0)} • ${isPaused ? 'Paused' : sub.cycle}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      isPaused
                          ? 'Paused'
                          : (daysLeft == 0
                              ? 'Today'
                              : (daysLeft < 0
                                  ? 'Overdue'
                                  : 'In $daysLeft days')),
                      style: TextStyle(
                        color: isPaused
                            ? Colors.grey
                            : (daysLeft <= 3 ? Colors.red.shade900 : Colors.grey.shade500),
                        fontWeight: (!isPaused && daysLeft <= 3) ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _showSubscriptionModal(context, provider, existingSub: sub),
              ),
            ),
            const Divider(height: 1),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.payment, size: 16),
                    label: const Text('Log Payment'),
                    onPressed: () => _showLogPaymentModal(context, sub, provider),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: Colors.grey.withValues(alpha: 0.15),
                ),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.history, size: 16),
                    label: const Text('History'),
                    onPressed: () => _showHistoryModal(context, sub),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final subscriptions = List<SubscriptionModel>.from(
      financeProvider.subscriptions,
    );

    // Sort subscriptions
    if (_sortBy == 'Date') {
      subscriptions.sort((a, b) => a.nextBilling.compareTo(b.nextBilling));
    } else if (_sortBy == 'Cost') {
      subscriptions.sort((a, b) => b.cost.compareTo(a.cost));
    }

    double totalMonthly = 0;
    double totalYearly = 0;

    for (var s in subscriptions) {
      if (s.isPaused) continue;

      // Convert everything to INR for total logic if we wanted to, but assuming it's just raw amount for now
      if (s.cycle == 'Monthly') {
        totalMonthly += s.cost;
      } else if (s.cycle == 'Yearly') {
        totalYearly += s.cost;
      } else if (s.customDays != null && s.customDays! > 0) {
        // Prorate to monthly for the overview
        totalMonthly += (s.cost / s.customDays!) * 30;
        totalYearly += (s.cost / s.customDays!) * 365;
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Subscriptions', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSubscriptionModal(context, financeProvider),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (subscriptions.isNotEmpty)
              GestureDetector(
                onTap: () => setState(() => _showYearly = !_showYearly),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 300),
                            crossFadeState: _showYearly ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            firstChild: Text('Total Monthly Bills', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.2)),
                            secondChild: Text('Total Yearly Bills', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.2)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.swap_horiz, size: 12, color: Colors.white70),
                                const SizedBox(width: 4),
                                const Text('Tap', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: _showYearly ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        firstChild: Text(
                          '₹${totalMonthly.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 32, 
                            fontWeight: FontWeight.w800, 
                            letterSpacing: -1.0,
                            color: Colors.white,
                          ),
                        ),
                        secondChild: Text(
                          '₹${(totalYearly + (totalMonthly * 12)).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 32, 
                            fontWeight: FontWeight.w800, 
                            letterSpacing: -1.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Active Subs', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                          Text('${subscriptions.where((s) => !s.isPaused).length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: subscriptions.isEmpty
                  ? const Center(child: Text('No active subscriptions.', style: TextStyle(color: Colors.grey)))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Your Subs', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              DropdownButton<String>(
                                value: _sortBy,
                                underline: const SizedBox(),
                                items: ['Date', 'Cost'].map((s) => DropdownMenuItem(value: s, child: Text('Sort by $s'))).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _sortBy = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            itemCount: subscriptions.length,
                itemBuilder: (context, index) {
                  final sub = subscriptions[index];
                  final daysLeft = sub.nextBilling
                      .difference(DateTime.now())
                      .inDays;

                  return Dismissible(
                    key: Key(sub.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: const Text('Are you sure you want to delete this subscription?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) => financeProvider.deleteSubscription(sub.id),
                    child: _buildSubscriptionCard(context, sub, financeProvider, daysLeft),
                  );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
  }
}
