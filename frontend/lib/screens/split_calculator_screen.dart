import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String _searchQuery = '';

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

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report copied to clipboard! (Native share sheet would open here)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SplitProvider>(
      builder: (context, provider, child) {
        final trip = provider.activeTrip;
        if (trip == null) {
          return Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('No active trip')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(trip.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: [
              IconButton(icon: const Icon(Icons.share), onPressed: _exportReport),
              IconButton(icon: const Icon(Icons.person_add_alt_1), onPressed: _showAddPersonSheet),
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
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(provider, trip),
              _buildParticipantsTab(provider, trip),
              _buildExpensesTab(provider, trip),
              _buildSettlementsTab(provider, trip),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddExpenseModal,
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(SplitProvider provider, Trip trip) {
    double totalExpense = trip.totalExpense;
    String cur = trip.currency;
    
    double paidByMe = trip.expenses.where((i) => i.paidByPersonId == 'me').fold(0, (sum, i) => sum + i.amount);
    double owedByMe = trip.expenses.fold(0, (sum, i) => sum + (i.exactAmountsOwed['me'] ?? 0));
    double netBalance = paidByMe - owedByMe;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.7)],
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
                Text('$cur${totalExpense.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          const Text('My Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMetricCard('Total Paid', '$cur${paidByMe.toStringAsFixed(0)}', Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('Total Share', '$cur${owedByMe.toStringAsFixed(0)}', Colors.orange)),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetricCard(
            'Net Balance', 
            '${netBalance >= 0 ? '+' : '-'} $cur${netBalance.abs().toStringAsFixed(0)}', 
            netBalance >= 0 ? Colors.green : Colors.red,
            subtitle: netBalance >= 0 ? 'You get back' : 'You owe',
          ),
          
          const SizedBox(height: 32),
          const Text('Category Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          _buildCategoryChart(provider, trip),
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
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
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

  Widget _buildCategoryChart(SplitProvider provider, Trip trip) {
    if (trip.expenses.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No expenses yet')));
    }
    
    Map<String, double> categorySums = {};
    for (var item in trip.expenses) {
      categorySums[item.category] = (categorySums[item.category] ?? 0) + item.amount;
    }

    return Column(
      children: categorySums.entries.map((e) {
        double pct = e.value / trip.totalExpense;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${trip.currency}${e.value.toStringAsFixed(0)} (${(pct * 100).toStringAsFixed(1)}%)', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: pct,
                backgroundColor: Colors.grey.withValues(alpha: 0.1),
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

  Widget _buildParticipantsTab(SplitProvider provider, Trip trip) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      itemCount: trip.participants.length,
      itemBuilder: (context, index) {
        final p = trip.participants[index];
        
        double paid = trip.expenses.where((i) => i.paidByPersonId == p.id).fold(0, (sum, i) => sum + i.amount);
        double owed = trip.expenses.fold(0, (sum, i) => sum + (i.exactAmountsOwed[p.id] ?? 0));
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
                      Text('Paid: ${trip.currency}${paid.toStringAsFixed(0)} • Owed: ${trip.currency}${owed.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      net >= 0 ? '+${trip.currency}${net.toStringAsFixed(0)}' : '-${trip.currency}${net.abs().toStringAsFixed(0)}',
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

  Widget _buildExpensesTab(SplitProvider provider, Trip trip) {
    if (trip.expenses.isEmpty) {
      return const Center(child: Text('No expenses added yet.', style: TextStyle(color: Colors.grey)));
    }

    final filteredExpenses = trip.expenses.where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search Expenses',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            itemCount: filteredExpenses.length,
            itemBuilder: (context, index) {
              final item = filteredExpenses[index];
              final payer = provider.getPerson(item.paidByPersonId)?.name ?? 'Unknown';
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ExpansionTile(
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Paid by $payer • ${item.splitMethod.name} split', style: const TextStyle(fontSize: 12)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${trip.currency}${item.amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).primaryColor)),
                      Text(item.category, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  children: [
                    if (item.notes != null && item.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Notes: ${item.notes}', style: const TextStyle(fontStyle: FontStyle.italic)),
                      ),
                    OverflowBar(
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                          onPressed: () {
                            // In a real app we would open the modal with pre-filled data
                          },
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text('Delete', style: TextStyle(color: Colors.red)),
                          onPressed: () => provider.removeItem(item.id),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettlementsTab(SplitProvider provider, Trip trip) {
    if (trip.settlements.isEmpty) {
      return const Center(child: Text('All settled up! 🎉', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      itemCount: trip.settlements.length,
      itemBuilder: (context, index) {
        final s = trip.settlements[index];
        final fromName = provider.getPerson(s.fromPersonId)?.name ?? 'Unknown';
        final toName = provider.getPerson(s.toPersonId)?.name ?? 'Unknown';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: Colors.redAccent.withValues(alpha: 0.1), child: const Icon(Icons.arrow_upward, color: Colors.redAccent, size: 20)),
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
              Text('${trip.currency}${s.amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor)),
            ],
          ),
        );
      },
    );
  }
}
