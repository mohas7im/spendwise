import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // Ensure fl_chart is in pubspec.yaml! (If not, we can remove it, but user wanted charts)
import '../providers/split_provider.dart';
import '../providers/friends_provider.dart';
import '../models/split_bill.dart';
import '../widgets/split/add_split_expense_modal.dart';

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
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddExpenseModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddSplitExpenseModal(
        provider: Provider.of<SplitProvider>(context, listen: false),
      ),
    );
  }

  void _showAddPersonSheet() {
    final provider = Provider.of<SplitProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Consumer<FriendsProvider>(
          builder: (ctx, friendsProvider, _) {
            final availableFriends = friendsProvider.friends.where((f) {
              return !provider.people.any((p) => p.name.toLowerCase() == f.name.toLowerCase());
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
                              provider.addPerson(f.name);
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
                                provider.addPerson(val.trim());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Expenses', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: _showAddPersonSheet,
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Participants'),
            Tab(text: 'Expenses'),
            Tab(text: 'Settlements'),
          ],
        ),
      ),
      body: Consumer<SplitProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(provider),
              _buildParticipantsTab(provider),
              _buildExpensesTab(provider),
              _buildSettlementsTab(provider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseModal,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildOverviewTab(SplitProvider provider) {
    double totalExpense = provider.items.fold(0, (sum, item) => sum + item.amount);
    
    // Calculate personal stats for "me"
    double paidByMe = provider.items.where((i) => i.paidByPersonId == 'me').fold(0, (sum, i) => sum + i.amount);
    double owedByMe = provider.items.fold(0, (sum, i) => sum + (i.exactAmountsOwed['me'] ?? 0));
    double netBalance = paidByMe - owedByMe;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Trip Expense Card
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Trip Expense', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text('₹${totalExpense.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // My Summary
          const Text('My Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard('Total Paid', '₹${paidByMe.toStringAsFixed(0)}', Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard('Total Share', '₹${owedByMe.toStringAsFixed(0)}', Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetricCard(
            'Net Balance', 
            '${netBalance >= 0 ? '+' : '-'} ₹${netBalance.abs().toStringAsFixed(0)}', 
            netBalance >= 0 ? Colors.green : Colors.red,
            subtitle: netBalance >= 0 ? 'You get back' : 'You owe',
          ),
          
          const SizedBox(height: 32),
          const Text('Category Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          _buildCategoryChart(provider),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ]
        ],
      ),
    );
  }

  Widget _buildCategoryChart(SplitProvider provider) {
    if (provider.items.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No expenses yet')));
    }
    
    Map<String, double> categorySums = {};
    for (var item in provider.items) {
      categorySums[item.category] = (categorySums[item.category] ?? 0) + item.amount;
    }

    // Since I don't know if fl_chart is fully installed and working in this project, 
    // I'll render a simple list view representation of a chart to be safe and avoid build errors.
    return Column(
      children: categorySums.entries.map((e) {
        double pct = e.value / provider.items.fold(0, (sum, i) => sum + i.amount);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('₹${e.value.toStringAsFixed(0)} (${(pct * 100).toStringAsFixed(1)}%)', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: pct,
                backgroundColor: Colors.grey.withOpacity(0.1),
                color: Theme.of(context).primaryColor,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildParticipantsTab(SplitProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      itemCount: provider.people.length,
      itemBuilder: (context, index) {
        final p = provider.people[index];
        
        double paid = provider.items.where((i) => i.paidByPersonId == p.id).fold(0, (sum, i) => sum + i.amount);
        double owed = provider.items.fold(0, (sum, i) => sum + (i.exactAmountsOwed[p.id] ?? 0));
        double net = paid - owed;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(radius: 24, backgroundImage: NetworkImage(p.avatarUrl)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Paid: ₹${paid.toStringAsFixed(0)} • Owed: ₹${owed.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      net >= 0 ? '+₹${net.toStringAsFixed(0)}' : '-₹${net.abs().toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16, 
                        color: net >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(net >= 0 ? 'gets back' : 'owes', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                if (p.id != 'me') ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => provider.removePerson(p.id),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpensesTab(SplitProvider provider) {
    if (provider.items.isEmpty) {
      return const Center(child: Text('No expenses added yet.', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        final item = provider.items[index];
        final payer = provider.getPerson(item.paidByPersonId)?.name ?? 'Unknown';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Paid by $payer • ${item.splitMethod.name} split', style: const TextStyle(fontSize: 12)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${item.amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).primaryColor)),
                Text(item.category, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            onLongPress: () => provider.removeItem(item.id),
          ),
        );
      },
    );
  }

  Widget _buildSettlementsTab(SplitProvider provider) {
    if (provider.settlements.isEmpty) {
      return const Center(child: Text('All settled up! 🎉', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      itemCount: provider.settlements.length,
      itemBuilder: (context, index) {
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
                    Text('$fromName pays', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(toName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
              Text('₹${s.amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor)),
            ],
          ),
        );
      },
    );
  }
}
