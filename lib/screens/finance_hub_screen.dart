import 'package:flutter/material.dart';
import 'fuel_screen.dart';
import 'expense_group_screen.dart';

enum ToolCategory { favorite, food, trip, fuel, finance, bills }

class FinanceTool {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final ToolCategory category;
  final bool isComingSoon;
  final Widget? destination;
  
  FinanceTool({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    this.isComingSoon = false,
    this.destination,
  });
}

class FinanceHubScreen extends StatefulWidget {
  const FinanceHubScreen({super.key});

  @override
  State<FinanceHubScreen> createState() => _FinanceHubScreenState();
}

class _FinanceHubScreenState extends State<FinanceHubScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  ToolCategory _selectedCategory = ToolCategory.favorite;
  final Set<String> _favorites = {}; // We will load this from SharedPreferences later

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Finance Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryDashboard(context),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildCategoryChips(),
            const SizedBox(height: 24),
            if (_selectedCategory == ToolCategory.finance || _selectedCategory == ToolCategory.favorite)
              _buildActiveLoansAndDebts(),
            _buildToolsGrid(),
            const SizedBox(height: 100), // padding for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildActiveLoansAndDebts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Active Debts & Loans', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _DebtCard(
          name: 'Sarah Connor',
          type: 'They Owe Me',
          totalAmount: 5000,
          paidAmount: 2500,
          dueDate: '15 Aug 2026',
          status: 'Active',
          onTap: () => _showDebtDetailsModal(),
        ),
        const SizedBox(height: 16),
        _DebtCard(
          name: 'HDFC Car Loan',
          type: 'I Owe',
          totalAmount: 500000,
          paidAmount: 120000,
          dueDate: '5th of Every Month',
          status: 'Active',
          onTap: () => _showDebtDetailsModal(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showDebtDetailsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Text('Debt Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              const Center(child: Text('Detailed Payment History & EMI Schedule Here')),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryDashboard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Net Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                child: const Text('+12%', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('₹1,45,000', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryStat('I Owe', '₹12,500', Colors.redAccent),
              _buildSummaryStat('Owed to Me', '₹4,200', Colors.greenAccent),
              _buildSummaryStat('EMIs Due', '₹8,500', Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchCtrl,
      decoration: InputDecoration(
        hintText: 'Search calculators (e.g. EMI, Fuel)',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (val) => setState(() {}),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ToolCategory.values.map((cat) {
          final isSelected = _selectedCategory == cat;
          final primary = Theme.of(context).primaryColor;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(_getCategoryName(cat)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedCategory = cat);
              },
              selectedColor: primary,
              labelStyle: TextStyle(
                color: isSelected ? Theme.of(context).colorScheme.onPrimary : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              side: BorderSide.none,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getCategoryName(ToolCategory cat) {
    switch (cat) {
      case ToolCategory.favorite: return 'Favorites';
      case ToolCategory.food: return 'Food';
      case ToolCategory.trip: return 'Trip';
      case ToolCategory.fuel: return 'Fuel & Vehicle';
      case ToolCategory.finance: return 'Loans & Finance';
      case ToolCategory.bills: return 'Bills & Utilities';
    }
  }

  Widget _buildToolsGrid() {
    var filtered = allTools;
    if (_searchCtrl.text.isNotEmpty) {
      filtered = filtered.where((t) => t.title.toLowerCase().contains(_searchCtrl.text.toLowerCase())).toList();
    } else if (_selectedCategory != ToolCategory.favorite) {
      filtered = filtered.where((t) => t.category == _selectedCategory).toList();
    } else {
      filtered = filtered.where((t) => _favorites.contains(t.id)).toList();
    }

    if (filtered.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No calculators found.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ListView.separated(
        key: ValueKey('$_selectedCategory-${_searchCtrl.text}'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filtered.length,
        separatorBuilder: (ctx, idx) => const SizedBox(height: 16),
        itemBuilder: (ctx, i) => _buildToolCard(filtered[i]),
      ),
    );
  }

  Widget _buildToolCard(FinanceTool tool) {
    final isFavorite = _favorites.contains(tool.id);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: tool.isComingSoon || tool.destination == null ? null : () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => tool.destination!));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(tool.icon, size: 32, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              tool.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isFavorite) {
                                  _favorites.remove(tool.id);
                                } else {
                                  _favorites.add(tool.id);
                                }
                              });
                            },
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.redAccent : Colors.grey,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tool.description,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      if (tool.isComingSoon)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Coming Soon', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      else
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            minimumSize: const Size(80, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: tool.destination == null ? null : () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => tool.destination!));
                          },
                          child: const Text('Open'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Dummy tools to fill the screen
final List<FinanceTool> allTools = [
  // Food
  FinanceTool(id: 'f1', title: 'Food Bill Split', description: 'Split restaurant bills accurately with tax & tip.', icon: Icons.restaurant, category: ToolCategory.food, destination: const ExpenseGroupScreen(initialTabIndex: 0)),
  FinanceTool(id: 'f2', title: 'Discount Calculator', description: 'Quickly calculate discounted prices.', icon: Icons.local_offer, category: ToolCategory.food, isComingSoon: true),
  // Trip
  FinanceTool(id: 't1', title: 'Trip Cost Calculator', description: 'Estimate total cost for upcoming trips.', icon: Icons.flight_takeoff, category: ToolCategory.trip, destination: const ExpenseGroupScreen(initialTabIndex: 1)),
  FinanceTool(id: 't2', title: 'Accommodation Split', description: 'Split Airbnb or hotel costs.', icon: Icons.hotel, category: ToolCategory.trip, isComingSoon: true),
  // Fuel
  FinanceTool(id: 'fv1', title: 'Fuel Quantity', description: 'Calculate litres from fuel amount and price.', icon: Icons.local_gas_station, category: ToolCategory.fuel, destination: const FuelScreen(initialTab: 0)),
  FinanceTool(id: 'fv2', title: 'Mileage Calculator', description: 'Track your vehicle\'s fuel efficiency.', icon: Icons.speed, category: ToolCategory.fuel, destination: const FuelScreen(initialTab: 1)),
  // Finance
  FinanceTool(id: 'fn1', title: 'EMI Calculator', description: 'Calculate monthly loan EMI payments.', icon: Icons.account_balance, category: ToolCategory.finance, isComingSoon: true),
  FinanceTool(id: 'fn2', title: 'Savings Goal', description: 'Plan how to reach your savings target.', icon: Icons.savings, category: ToolCategory.finance, isComingSoon: true),
  FinanceTool(id: 'fn3', title: 'Mortgage Planner', description: 'Advanced mortgage planning tools.', icon: Icons.home_work, category: ToolCategory.finance, isComingSoon: true),
  // Bills
  FinanceTool(id: 'b1', title: 'Rent Split', description: 'Split rent among roommates.', icon: Icons.house, category: ToolCategory.bills, isComingSoon: true),
  FinanceTool(id: 'b2', title: 'Internet Bill', description: 'Track ISP expenses.', icon: Icons.wifi, category: ToolCategory.bills, isComingSoon: true),
];

class _DebtCard extends StatelessWidget {
  final String name;
  final String type;
  final double totalAmount;
  final double paidAmount;
  final String dueDate;
  final String status;
  final VoidCallback onTap;

  const _DebtCard({
    required this.name,
    required this.type,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueDate,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = paidAmount / totalAmount;
    final isOwedToMe = type == 'They Owe Me';
    final primaryColor = isOwedToMe ? Colors.green : Colors.redAccent;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      child: Text(name[0], style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(type, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(status, style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Amount', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('₹${totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Paid Amount', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('₹${paidAmount.toStringAsFixed(0)}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 12),
                Text('Next Due: $dueDate', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


