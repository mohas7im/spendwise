import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/subscription.dart';
import '../widgets/common/premium_gradient_card.dart';
import '../widgets/common/custom_bottom_sheet.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  String _sortBy = 'Date';

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
            ],
          ),
        ),
      ),
    );
  }

  void _showSubscriptionDetails(
    BuildContext context,
    SubscriptionModel sub,
    FinanceProvider provider,
  ) {
    final daysLeft = sub.nextBilling.difference(DateTime.now()).inDays;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
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
                          color: sub.color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(sub.icon, color: sub.color, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub.name,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${sub.cycle} Plan',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (val) {
                      Navigator.pop(ctx);
                      if (val == 'edit') {
                        _showSubscriptionModal(
                          context,
                          provider,
                          existingSub: sub,
                        );
                      } else if (val == 'delete') {
                        provider.deleteSubscription(sub.id);
                      } else if (val == 'pause') {
                        sub.isPaused = !sub.isPaused;
                        provider.updateSubscription(sub.id, sub);
                      }
                    },
                    itemBuilder: (c) => [
                      PopupMenuItem(
                        value: 'pause',
                        child: Text(sub.isPaused ? 'Resume' : 'Pause'),
                      ),
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
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
                      const Text(
                        'Amount',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '${sub.currency}${sub.cost.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Next Billing',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        sub.isPaused
                            ? 'Paused'
                            : '${sub.nextBilling.day}/${sub.nextBilling.month}/${sub.nextBilling.year}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: sub.isPaused
                              ? Colors.grey
                              : (daysLeft <= 3
                                    ? Colors.red.shade900
                                    : Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                'Payment History',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (sub.paymentHistory.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'No actual payments recorded yet. Auto-deductions will appear here.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                ...sub.paymentHistory.reversed
                    .take(5)
                    .map(
                      (h) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.withValues(alpha: 0.1),
                          child: const Icon(Icons.check, color: Colors.green),
                        ),
                        title: Text(
                          '${sub.currency}${h.amount.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${h.date.day}/${h.date.month}/${h.date.year} • ${h.status}',
                        ),
                      ),
                    ),
            ],
          ),
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
                    Text(
                      'Subscriptions',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () =>
                          _showSubscriptionModal(context, financeProvider),
                      icon: Icon(
                        Icons.add_circle,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              // Summary Card
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: PremiumGradientCard(
                  builder: (context, textColor, subTextColor) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Monthly Bills',
                        style: TextStyle(color: subTextColor, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${totalMonthly.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Yearly Equivalent',
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                '₹${(totalYearly + (totalMonthly * 12)).toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Active Subs',
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                '${subscriptions.where((s) => !s.isPaused).length}',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (subscriptions.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Subs',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      DropdownButton<String>(
                        value: _sortBy,
                        underline: const SizedBox(),
                        items: ['Date', 'Cost']
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text('Sort by $s'),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _sortBy = val);
                        },
                      ),
                    ],
                  ),
                ),

                ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: subscriptions.length,
                itemBuilder: (context, index) {
                  final sub = subscriptions[index];
                  final daysLeft = sub.nextBilling
                      .difference(DateTime.now())
                      .inDays;

                  return Opacity(
                    opacity: sub.isPaused ? 0.5 : 1.0,
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showSubscriptionDetails(
                          context,
                          sub,
                          financeProvider,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: sub.color.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  sub.icon,
                                  color: sub.color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sub.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      sub.isPaused ? 'Paused' : sub.cycle,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${sub.currency}${sub.cost.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    sub.isPaused
                                        ? 'Paused'
                                        : (daysLeft == 0
                                              ? 'Today'
                                              : (daysLeft < 0
                                                    ? 'Overdue'
                                                    : 'In $daysLeft days')),
                                    style: TextStyle(
                                      color: sub.isPaused
                                          ? Colors.grey
                                          : (daysLeft <= 3
                                                ? Colors.red.shade900
                                                : Colors.grey),
                                      fontWeight:
                                          (!sub.isPaused && daysLeft <= 3)
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                  },
                ),
              ] else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No subscriptions added.', style: TextStyle(color: Colors.grey)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
