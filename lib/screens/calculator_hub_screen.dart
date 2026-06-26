import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fuel_screen.dart'; // We will link Fuel tools here

enum CalcCategory {
  expense,
  loan,
  fuel,
}

extension CalcCategoryExt on CalcCategory {
  String get name {
    switch (this) {
      case CalcCategory.expense: return 'Expense & Group';
      case CalcCategory.loan: return 'Loan & Finance';
      case CalcCategory.fuel: return 'Fuel & Vehicle';
    }
  }

  IconData get icon {
    switch (this) {
      case CalcCategory.expense: return Icons.group_work_outlined;
      case CalcCategory.loan: return Icons.account_balance_outlined;
      case CalcCategory.fuel: return Icons.local_gas_station_outlined;
    }
  }
}

class CalculatorItem {
  final String id;
  final String title;
  final String iconEmoji;
  final CalcCategory category;
  final Widget? destination; // null for placeholders

  CalculatorItem({
    required this.id,
    required this.title,
    required this.iconEmoji,
    required this.category,
    this.destination,
  });
}

final List<CalculatorItem> allCalculators = [
  // Expense & Group
  CalculatorItem(id: 'exp_grp_split', title: 'Group Expense Split', iconEmoji: '👥', category: CalcCategory.expense),
  CalculatorItem(id: 'exp_food', title: 'Food Bill Split', iconEmoji: '🍔', category: CalcCategory.expense),
  CalculatorItem(id: 'exp_trip', title: 'Trip Cost', iconEmoji: '✈️', category: CalcCategory.expense),
  CalculatorItem(id: 'exp_shared', title: 'Shared Expense', iconEmoji: '🤝', category: CalcCategory.expense),
  CalculatorItem(id: 'exp_debt', title: 'Debt Settlement', iconEmoji: '💳', category: CalcCategory.expense),
  CalculatorItem(id: 'exp_budget', title: 'Budget', iconEmoji: '📊', category: CalcCategory.expense),
  CalculatorItem(id: 'exp_savings', title: 'Savings Goal', iconEmoji: '🎯', category: CalcCategory.expense),
  
  // Loan & Finance
  CalculatorItem(id: 'fin_emi', title: 'EMI', iconEmoji: '🏦', category: CalcCategory.loan),
  CalculatorItem(id: 'fin_loan_int', title: 'Loan Interest', iconEmoji: '📉', category: CalcCategory.loan),
  CalculatorItem(id: 'fin_comp_int', title: 'Compound Interest', iconEmoji: '📈', category: CalcCategory.loan),
  CalculatorItem(id: 'fin_simp_int', title: 'Simple Interest', iconEmoji: '₹', category: CalcCategory.loan),
  CalculatorItem(id: 'fin_afford', title: 'Loan Affordability', iconEmoji: '🏠', category: CalcCategory.loan),
  CalculatorItem(id: 'fin_sav_grwth', title: 'Savings Growth', iconEmoji: '🌱', category: CalcCategory.loan),
  
  // Fuel & Vehicle
  CalculatorItem(id: 'fuel_qty', title: 'Fuel Quantity', iconEmoji: '⛽', category: CalcCategory.fuel, destination: const FuelScreen(initialTab: 0)),
  CalculatorItem(id: 'fuel_mil', title: 'Mileage', iconEmoji: '🚗', category: CalcCategory.fuel, destination: const FuelScreen(initialTab: 1)),
  CalculatorItem(id: 'fuel_trip', title: 'Trip Fuel Cost', iconEmoji: '🗺️', category: CalcCategory.fuel, destination: const FuelScreen(initialTab: 2)),
  CalculatorItem(id: 'fuel_split', title: 'Fuel Bill Split', iconEmoji: '💸', category: CalcCategory.fuel, destination: const FuelScreen(initialTab: 3)),
  CalculatorItem(id: 'fuel_run', title: 'Vehicle Running Cost', iconEmoji: '🛠️', category: CalcCategory.fuel, destination: const FuelScreen(initialTab: 4)),
  CalculatorItem(id: 'fuel_track', title: 'Consumption Tracker', iconEmoji: '📊', category: CalcCategory.fuel, destination: const FuelScreen(initialTab: 5)),
];

class CalculatorHubScreen extends StatefulWidget {

  const CalculatorHubScreen({super.key});

  @override
  State<CalculatorHubScreen> createState() => _CalculatorHubScreenState();
}

class _CalculatorHubScreenState extends State<CalculatorHubScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  Set<String> _favorites = {};
  List<String> _recent = [];

  @override
  void initState() {
    super.initState();
    _loadFavoritesAndRecent();
  }

  Future<void> _loadFavoritesAndRecent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = Set<String>.from(prefs.getStringList('calc_favorites') ?? []);
      _recent = prefs.getStringList('calc_recent') ?? [];
    });
  }


  Future<void> _toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
      prefs.setStringList('calc_favorites', _favorites.toList());
    });
  }

  void _openCalculator(CalculatorItem item) async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _recent.remove(item.id);
      _recent.insert(0, item.id);
      if (_recent.length > 5) _recent = _recent.sublist(0, 5);
      prefs.setStringList('calc_recent', _recent);
    });

    if (item.destination != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => item.destination!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.title} Calculator is coming soon!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    
    // Filter by search
    final filtered = allCalculators.where((c) => c.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
    // Group by category
    final grouped = <CalcCategory, List<CalculatorItem>>{};
    for (var cat in CalcCategory.values) {
      grouped[cat] = filtered.where((c) => c.category == cat).toList();
    }

    final favoriteItems = allCalculators.where((c) => _favorites.contains(c.id)).toList();
    
    // Map recent IDs to actual items safely
    final recentItems = _recent
        .map((id) => allCalculators.cast<CalculatorItem?>().firstWhere((c) => c?.id == id, orElse: () => null))
        .whereType<CalculatorItem>()
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Calculator Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search calculators...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          
          // Recently Used Section (if search is empty and has recents)
          if (_searchQuery.isEmpty && recentItems.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('Recently Used', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: recentItems.length,
                  itemBuilder: (context, i) => _buildHorizCard(recentItems[i]),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
          
          // Favorites Section (if search is empty and has favorites)
          if (_searchQuery.isEmpty && favoriteItems.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('Favorites', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: favoriteItems.length,
                  itemBuilder: (context, i) => _buildHorizCard(favoriteItems[i]),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],

          // Categories
          ...CalcCategory.values.map((cat) {
            final items = grouped[cat]!;
            if (items.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
            
            return SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      children: [
                        Icon(cat.icon, size: 20, color: primary),
                        const SizedBox(width: 8),
                        Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _buildGridCard(items[i]),
                      childCount: items.length,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
          
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildGridCard(CalculatorItem item) {
    final isFav = _favorites.contains(item.id);
    return GestureDetector(
      onTap: () => _openCalculator(item),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.iconEmoji, style: const TextStyle(fontSize: 28)),
                GestureDetector(
                  onTap: () => _toggleFavorite(item.id),
                  child: Icon(
                    isFav ? Icons.star : Icons.star_border,
                    color: isFav ? Colors.amber : Colors.grey.withOpacity(0.5),
                    size: 20,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            if (item.destination == null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                child: const Text('COMING SOON', style: TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHorizCard(CalculatorItem item) {
    return GestureDetector(
      onTap: () => _openCalculator(item),
      child: Container(
        width: 110,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.iconEmoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.2)),
          ],
        ),
      ),
    );
  }
}
