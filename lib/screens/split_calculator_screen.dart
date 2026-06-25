import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/split_provider.dart';
import '../models/split_bill.dart';

class SplitCalculatorScreen extends StatefulWidget {
  const SplitCalculatorScreen({super.key});

  @override
  State<SplitCalculatorScreen> createState() => _SplitCalculatorScreenState();
}

class _SplitCalculatorScreenState extends State<SplitCalculatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Bill', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'People'),
            Tab(text: 'Expenses'),
            Tab(text: 'Settlements'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPeopleTab(),
          _buildExpensesTab(),
          _buildSettlementsTab(),
        ],
      ),
    );
  }

  // --- 1. PEOPLE TAB ---
  Widget _buildPeopleTab() {
    return Consumer<SplitProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: provider.people.length,
                itemBuilder: (context, index) {
                  final p = provider.people[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(backgroundImage: NetworkImage(p.avatarUrl)),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: p.id == 'me' ? const Text('You', style: TextStyle(color: Colors.grey)) : IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                      onPressed: () => provider.removePerson(p.id),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton.icon(
                onPressed: () => _showAddPersonDialog(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.person_add),
                label: const Text('Add Person', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        );
      },
    );
  }

  void _showAddPersonDialog(BuildContext context, SplitProvider provider) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Add Person'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                provider.addPerson(nameController.text.trim());
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  // --- 2. EXPENSES TAB ---
  Widget _buildExpensesTab() {
    return Consumer<SplitProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Expanded(
              child: provider.items.isEmpty
                  ? Center(child: Text('No expenses yet.', style: TextStyle(color: Colors.grey.shade600)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: provider.items.length,
                      itemBuilder: (context, index) {
                        final item = provider.items[index];
                        final payer = provider.getPerson(item.paidByPersonId)?.name ?? 'Unknown';
                        return Card(
                          color: Theme.of(context).cardColor,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Paid by $payer'),
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
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton.icon(
                onPressed: () => _showAddExpenseSheet(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        );
      },
    );
  }

  void _showAddExpenseSheet(BuildContext context, SplitProvider provider) {
    if (provider.people.isEmpty) return;
    
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String selectedPayerId = provider.people.first.id;
    bool isEquallySplit = true;
    
    // For equal split: Who shared it?
    List<String> selectedSharers = provider.people.map((p) => p.id).toList();
    
    // For unequal split: Exact amounts
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
                      decoration: const InputDecoration(labelText: 'Item Name (e.g. Pizza)', border: OutlineInputBorder()),
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
                      decoration: const InputDecoration(labelText: 'Paid By', border: OutlineInputBorder()),
                      items: provider.people.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                      onChanged: (v) { if (v != null) setState(() => selectedPayerId = v); },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Split Equally'),
                            value: true,
                            groupValue: isEquallySplit,
                            onChanged: (v) => setState(() => isEquallySplit = v!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Unequal'),
                            value: false,
                            groupValue: isEquallySplit,
                            onChanged: (v) => setState(() => isEquallySplit = v!),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (isEquallySplit) ...[
                      const Text('Who shared this?', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...provider.people.map((p) {
                        return CheckboxListTile(
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
                      ...provider.people.map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
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
                            if (!isEquallySplit) {
                              double sum = 0;
                              exactAmountControllers.forEach((id, ctrl) {
                                double val = double.tryParse(ctrl.text) ?? 0.0;
                                exactAmounts[id] = val;
                                sum += val;
                              });
                              // Just a basic check, ideally show error if sum doesn't match total
                              if ((sum - amount).abs() > 1.0) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Warning: Exact amounts do not sum up to total!')));
                              }
                            }
                            
                            provider.addItem(SplitItem(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              name: nameController.text,
                              amount: amount,
                              paidByPersonId: selectedPayerId,
                              isEquallySplit: isEquallySplit,
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

  // --- 3. SETTLEMENTS TAB ---
  Widget _buildSettlementsTab() {
    return Consumer<SplitProvider>(
      builder: (context, provider, child) {
        if (provider.settlements.isEmpty) {
          return Center(child: Text('All settled up! 🎉', style: Theme.of(context).textTheme.titleLarge));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: provider.settlements.length,
          itemBuilder: (context, index) {
            final s = provider.settlements[index];
            final fromName = provider.getPerson(s.fromPersonId)?.name ?? 'Unknown';
            final toName = provider.getPerson(s.toPersonId)?.name ?? 'Unknown';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: Colors.redAccent.withOpacity(0.1), child: const Icon(Icons.arrow_upward, color: Colors.redAccent)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$fromName owes', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(toName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                  Text('₹${s.amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).primaryColor)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
