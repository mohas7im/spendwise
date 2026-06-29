import 'package:flutter/material.dart';
import '../widgets/common/custom_tab_bar.dart';

class ExpenseGroupScreen extends StatefulWidget {
  final int initialTabIndex;

  const ExpenseGroupScreen({super.key, this.initialTabIndex = 0});

  @override
  State<ExpenseGroupScreen> createState() => _ExpenseGroupScreenState();
}

class _ExpenseGroupScreenState extends State<ExpenseGroupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
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
        title: const Text(
          'Expense & Group',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          CustomTabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Food Bill'),
              Tab(text: 'Trip Cost'),
            ],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_FoodBillSplitTab(), _TripCostTab()],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. Food Bill Split Tab
// ---------------------------------------------------------------------------
class _FoodBillSplitTab extends StatefulWidget {
  const _FoodBillSplitTab();
  @override
  State<_FoodBillSplitTab> createState() => _FoodBillSplitTabState();
}

class _FoodBillSplitTabState extends State<_FoodBillSplitTab> {
  final List<PersonItem> _people = [PersonItem(name: 'Person 1', amount: 0)];
  double _taxPercent = 0;
  double _tipPercent = 0;

  void _addPerson() {
    setState(() {
      _people.add(PersonItem(name: 'Person ${_people.length + 1}', amount: 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = _people.fold(0, (sum, p) => sum + p.amount);
    double taxAmount = subtotal * (_taxPercent / 100);
    double tipAmount = subtotal * (_tipPercent / 100);
    double total = subtotal + taxAmount + tipAmount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResultBox(
            title: 'Total Bill (w/ Tax & Tip)',
            value: '₹${total.toStringAsFixed(0)}',
            subtitle: 'Subtotal: ₹${subtotal.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _InputField(
                  label: 'Tax (%)',
                  icon: Icons.receipt_long,
                  onChanged: (v) =>
                      setState(() => _taxPercent = double.tryParse(v) ?? 0),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InputField(
                  label: 'Tip (%)',
                  icon: Icons.volunteer_activism,
                  onChanged: (v) =>
                      setState(() => _tipPercent = double.tryParse(v) ?? 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'People & Items',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Person'),
                onPressed: _addPerson,
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...List.generate(_people.length, (index) {
            final p = _people[index];
            double proportion = subtotal > 0 ? p.amount / subtotal : 0;
            double pTax = proportion * taxAmount;
            double pTip = proportion * tipAmount;
            double pTotal = p.amount + pTax + pTip;

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
                  Expanded(
                    flex: 2,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        isDense: true,
                        border: InputBorder.none,
                      ),
                      onChanged: (v) => setState(() => p.name = v),
                      controller: TextEditingController(text: p.name)
                        ..selection = TextSelection.collapsed(
                          offset: p.name.length,
                        ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Item Cost',
                        isDense: true,
                        border: InputBorder.none,
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) =>
                          setState(() => p.amount = double.tryParse(v) ?? 0),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Owes',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        '₹${pTotal.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  if (_people.length > 1)
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _people.removeAt(index)),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class PersonItem {
  String name;
  double amount;
  PersonItem({required this.name, required this.amount});
}

// ---------------------------------------------------------------------------
// 2. Trip Cost Tab
// ---------------------------------------------------------------------------
class _TripCostTab extends StatefulWidget {
  const _TripCostTab();
  @override
  State<_TripCostTab> createState() => _TripCostTabState();
}

class _TripCostTabState extends State<_TripCostTab> {
  int _peopleCount = 1;
  int _daysCount = 1;
  double _travelCost = 0; // flights, train
  double _accommodationPerNight = 0;
  double _foodActivitiesPerDay = 0;

  @override
  Widget build(BuildContext context) {
    double totalTravel = _travelCost;
    double totalAccommodation =
        _accommodationPerNight * (_daysCount - 1 > 0 ? _daysCount - 1 : 1);
    double totalFood = _foodActivitiesPerDay * _daysCount;

    double totalTripCost = totalTravel + totalAccommodation + totalFood;
    double costPerPerson = _peopleCount > 0 ? totalTripCost / _peopleCount : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _ResultBox(
                  title: 'Total Trip Cost',
                  value: '₹${totalTripCost.toStringAsFixed(0)}',
                  subtitle: '$_daysCount Days, $_peopleCount People',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ResultBox(
                  title: 'Cost Per Person',
                  value: '₹${costPerPerson.toStringAsFixed(0)}',
                  subtitle: 'Estimated Average',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: _InputField(
                  label: 'People',
                  icon: Icons.group,
                  onChanged: (v) =>
                      setState(() => _peopleCount = int.tryParse(v) ?? 1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InputField(
                  label: 'Days',
                  icon: Icons.calendar_today,
                  onChanged: (v) =>
                      setState(() => _daysCount = int.tryParse(v) ?? 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InputField(
            label: 'Travel / Flights (Total)',
            icon: Icons.flight,
            onChanged: (v) =>
                setState(() => _travelCost = double.tryParse(v) ?? 0),
          ),
          const SizedBox(height: 16),
          _InputField(
            label: 'Accommodation (Per Night)',
            icon: Icons.hotel,
            onChanged: (v) => setState(
              () => _accommodationPerNight = double.tryParse(v) ?? 0,
            ),
          ),
          const SizedBox(height: 16),
          _InputField(
            label: 'Food & Activities (Per Day)',
            icon: Icons.restaurant,
            onChanged: (v) =>
                setState(() => _foodActivitiesPerDay = double.tryParse(v) ?? 0),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared UI Widgets
// ---------------------------------------------------------------------------

class _ResultBox extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;

  const _ResultBox({required this.title, required this.value, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final Function(String) onChanged;

  const _InputField({
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: TextField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.grey),
          labelText: label,
          border: InputBorder.none,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
