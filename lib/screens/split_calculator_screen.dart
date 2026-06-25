import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/split_provider.dart';
import '../providers/friends_provider.dart';
import '../models/split_bill.dart';

class SplitCalculatorScreen extends StatefulWidget {
  const SplitCalculatorScreen({super.key});

  @override
  State<SplitCalculatorScreen> createState() => _SplitCalculatorScreenState();
}

class _SplitCalculatorScreenState extends State<SplitCalculatorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Bill', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () => _showAddPersonSheet(context, Provider.of<SplitProvider>(context, listen: false)),
          )
        ],
      ),
      body: Consumer<SplitProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            slivers: [
              // 1. Horizontal People List
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Text('People in Group', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.people.length,
                        itemBuilder: (context, index) {
                          final p = provider.people[index];
                          return Container(
                            width: 72,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundImage: NetworkImage(p.avatarUrl),
                                    ),
                                    if (p.id != 'me')
                                      Positioned(
                                        top: -4,
                                        right: -4,
                                        child: GestureDetector(
                                          onTap: () => provider.removePerson(p.id),
                                          child: Container(
                                            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  p.id == 'me' ? 'You' : p.name,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SliverPadding(padding: EdgeInsets.only(top: 16)),

              // 2. Expenses Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Expenses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('${provider.items.length} items', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),

              provider.items.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long, size: 64, color: Colors.grey.withOpacity(0.3)),
                              const SizedBox(height: 16),
                              const Text('No expenses added yet.', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = provider.items[index];
                            final payer = provider.getPerson(item.paidByPersonId)?.name ?? 'Unknown';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Paid by $payer', style: const TextStyle(fontSize: 12)),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('₹${item.amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).primaryColor)),
                                    Text(item.isEquallySplit ? 'Equal Split' : 'Unequal', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: provider.items.length,
                        ),
                      ),
                    ),

              // 3. Settlements Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Text('Settlements (Who owes who)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),

              provider.settlements.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text('All settled up! 🎉', style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final s = provider.settlements[index];
                            final fromName = provider.getPerson(s.fromPersonId)?.name ?? 'Unknown';
                            final toName = provider.getPerson(s.toPersonId)?.name ?? 'Unknown';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(backgroundColor: Colors.redAccent.withOpacity(0.1), child: const Icon(Icons.arrow_upward, color: Colors.redAccent, size: 20)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('$fromName owes', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        Text(toName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      ],
                                    ),
                                  ),
                                  Text('₹${s.amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor)),
                                ],
                              ),
                            );
                          },
                          childCount: provider.settlements.length,
                        ),
                      ),
                    ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 100)), // Space for FAB
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseSheet(context, Provider.of<SplitProvider>(context, listen: false)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddPersonSheet(BuildContext context, SplitProvider splitProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Consumer<FriendsProvider>(
          builder: (ctx, friendsProvider, _) {
            // Filter out friends that are already in the split bill
            final availableFriends = friendsProvider.friends.where((f) {
              return !splitProvider.people.any((p) => p.name.toLowerCase() == f.name.toLowerCase());
            }).toList();

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text('Add Person', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  
                  // Quick add existing friends
                  if (availableFriends.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text('From your Friends List', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: availableFriends.length,
                        itemBuilder: (context, index) {
                          final f = availableFriends[index];
                          return GestureDetector(
                            onTap: () {
                              splitProvider.addPerson(f.name);
                              Navigator.pop(ctx);
                            },
                            child: Container(
                              width: 72,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                children: [
                                  CircleAvatar(radius: 28, backgroundImage: NetworkImage(f.avatarUrl)),
                                  const SizedBox(height: 8),
                                  Text(f.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 32),
                  ],

                  // Add new person
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text('Or add a new person', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty) {
                                splitProvider.addPerson(val.trim());
                                // Automatically save to global friends list!
                                friendsProvider.addFriend(val.trim());
                                Navigator.pop(ctx);
                              }
                            },
                            decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddExpenseSheet(BuildContext context, SplitProvider provider) {
    if (provider.people.isEmpty) return;
    
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String selectedPayerId = provider.people.first.id;
    
    // 0 = Food/Equal, 1 = Trip/Unequal
    int splitMode = 0; 
    
    List<String> selectedSharers = provider.people.map((p) => p.id).toList();
    
    Map<String, TextEditingController> exactAmountControllers = {};
    for (var p in provider.people) {
      exactAmountControllers[p.id] = TextEditingController();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Expense', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Expense Name (e.g. Pizza, Hotel)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Total Amount (₹)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedPayerId,
                      decoration: const InputDecoration(labelText: 'Who Paid?', border: OutlineInputBorder()),
                      items: provider.people.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                      onChanged: (v) { if (v != null) setState(() => selectedPayerId = v); },
                    ),
                    const SizedBox(height: 24),
                    const Text('How to Split?', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => splitMode = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: splitMode == 0 ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: splitMode == 0 ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.restaurant, color: splitMode == 0 ? Theme.of(context).primaryColor : Colors.grey),
                                  const SizedBox(height: 4),
                                  Text('Equal (Food)', style: TextStyle(color: splitMode == 0 ? Theme.of(context).primaryColor : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => splitMode = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: splitMode == 1 ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: splitMode == 1 ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.directions_car, color: splitMode == 1 ? Theme.of(context).primaryColor : Colors.grey),
                                  const SizedBox(height: 4),
                                  Text('Unequal (Trip)', style: TextStyle(color: splitMode == 1 ? Theme.of(context).primaryColor : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (splitMode == 0) ...[
                      const Text('Who shared this?', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Text('Cost will be split equally among selected people.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      ...provider.people.map((p) {
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(p.name),
                          value: selectedSharers.contains(p.id),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) selectedSharers.add(p.id);
                              else selectedSharers.remove(p.id);
                            });
                          },
                        );
                      }),
                    ] else ...[
                      const Text('Exact amounts owed:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Text('Enter exactly how much each person spent/owes.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      ...provider.people.map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: TextField(
                            controller: exactAmountControllers[p.id],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: '${p.name} owes', prefixText: '₹ ', border: const OutlineInputBorder()),
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Theme.of(context).colorScheme.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () {
                          final amount = double.tryParse(amountController.text) ?? 0.0;
                          if (nameController.text.isNotEmpty && amount > 0) {
                            Map<String, double> exactAmounts = {};
                            if (splitMode == 1) {
                              double sum = 0;
                              exactAmountControllers.forEach((id, ctrl) {
                                double val = double.tryParse(ctrl.text) ?? 0.0;
                                exactAmounts[id] = val;
                                sum += val;
                              });
                              if ((sum - amount).abs() > 1.0) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Warning: Exact amounts do not sum up to total!')));
                              }
                            }
                            
                            provider.addItem(SplitItem(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              name: nameController.text,
                              amount: amount,
                              paidByPersonId: selectedPayerId,
                              isEquallySplit: splitMode == 0,
                              sharedByPersonIds: selectedSharers,
                              exactAmountsOwed: exactAmounts,
                            ));
                            Navigator.pop(ctx);
                          }
                        },
                        child: const Text('Save Expense', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
