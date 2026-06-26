import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/fuel_provider.dart';
import '../models/fuel_entry.dart';

class FuelScreen extends StatefulWidget {
  const FuelScreen({super.key});

  @override
  State<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends State<FuelScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('⛽', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            const Text('Petrol & Mileage', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tab,
          labelColor: primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Fill-up Log'),
            Tab(text: 'Calculator'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle, color: primary),
            onPressed: () => _showAddFillUpSheet(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _FillUpLogTab(onAdd: () => _showAddFillUpSheet(context)),
          const _MileageCalculatorTab(),
        ],
      ),
    );
  }

  void _showAddFillUpSheet(BuildContext context) {
    final litersCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final odometerCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheet) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 24, right: 24, top: 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('⛽', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text('Log Fill-Up', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),

                // Date picker row
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setSheet(() => selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 10),
                        Text(DateFormat('dd MMM yyyy').format(selectedDate), style: const TextStyle(fontWeight: FontWeight.w500)),
                        const Spacer(),
                        const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(child: _InputField(controller: litersCtrl, label: 'Liters (L)', hint: '40.0', icon: '🛢️')),
                    const SizedBox(width: 12),
                    Expanded(child: _InputField(controller: priceCtrl, label: 'Price / L (₹)', hint: '106.0', icon: '💰')),
                  ],
                ),
                const SizedBox(height: 12),

                _InputField(controller: odometerCtrl, label: 'Odometer (km)', hint: 'Current km reading', icon: '📍'),
                const SizedBox(height: 12),

                _InputField(controller: notesCtrl, label: 'Notes (optional)', hint: 'e.g. Highway trip', icon: '📝', textInput: TextInputType.text),
                const SizedBox(height: 24),

                // Preview total cost
                ValueListenableBuilder(
                  valueListenable: litersCtrl,
                  builder: (_, __, ___) => ValueListenableBuilder(
                    valueListenable: priceCtrl,
                    builder: (_, __, ___) {
                      final liters = double.tryParse(litersCtrl.text) ?? 0;
                      final price = double.tryParse(priceCtrl.text) ?? 0;
                      final total = liters * price;
                      if (total == 0) return const SizedBox();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Cost', style: TextStyle(fontWeight: FontWeight.w500)),
                            Text('₹${total.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor)),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      final liters = double.tryParse(litersCtrl.text);
                      final price = double.tryParse(priceCtrl.text);
                      final odometer = double.tryParse(odometerCtrl.text);

                      if (liters == null || price == null || odometer == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill Liters, Price, and Odometer')),
                        );
                        return;
                      }

                      Provider.of<FuelProvider>(context, listen: false).addEntry(FuelEntry(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        date: selectedDate,
                        liters: liters,
                        pricePerLiter: price,
                        odometer: odometer,
                        notes: notesCtrl.text.isEmpty ? null : notesCtrl.text,
                      ));
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save Fill-Up', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Fill-Up Log Tab ─────────────────────────────────────────────────────────

class _FillUpLogTab extends StatelessWidget {
  final VoidCallback onAdd;
  const _FillUpLogTab({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Consumer<FuelProvider>(
      builder: (context, fuel, _) {
        final entries = fuel.entries;

        return CustomScrollView(
          slivers: [
            // Summary cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    // Hero stats
                    Row(
                      children: [
                        _StatCard(
                          label: 'Avg Mileage',
                          value: fuel.averageMileage > 0 ? '${fuel.averageMileage.toStringAsFixed(1)} km/l' : '—',
                          icon: '🚗',
                          color: primary,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Last Mileage',
                          value: fuel.lastMileage > 0 ? '${fuel.lastMileage.toStringAsFixed(1)} km/l' : '—',
                          icon: '📈',
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatCard(
                          label: 'Total Spent',
                          value: '₹${fuel.totalFuelSpend.toStringAsFixed(0)}',
                          icon: '💸',
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Total Liters',
                          value: '${fuel.totalLitersFilled.toStringAsFixed(1)} L',
                          icon: '🛢️',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Log list
            if (entries.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⛽', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      const Text('No fill-ups logged yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: onAdd,
                        child: const Text('Log First Fill-Up'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final entry = entries[i];
                    final sortedAll = [...fuel.entries]..sort((a, b) => a.date.compareTo(b.date));
                    final idx = sortedAll.indexOf(entry);
                    double? mileage;
                    if (idx > 0) {
                      final prevOdo = sortedAll[idx - 1].odometer;
                      final km = entry.odometer - prevOdo;
                      if (km > 0 && entry.liters > 0) mileage = km / entry.liters;
                    }

                    return Dismissible(
                      key: Key(entry.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        color: Colors.red.withOpacity(0.2),
                        child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      ),
                      onDismissed: (_) => Provider.of<FuelProvider>(ctx, listen: false).deleteEntry(entry.id),
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text('⛽', style: TextStyle(fontSize: 18)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(DateFormat('dd MMM yyyy').format(entry.date),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      if (entry.notes != null)
                                        Text(entry.notes!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('₹${entry.totalCost.toStringAsFixed(0)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('${entry.liters.toStringAsFixed(1)} L @ ₹${entry.pricePerLiter.toStringAsFixed(1)}',
                                        style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _MiniStat(label: 'Odometer', value: '${entry.odometer.toStringAsFixed(0)} km'),
                                if (mileage != null)
                                  _MiniStat(label: 'Mileage', value: '${mileage.toStringAsFixed(1)} km/l', color: Colors.green),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: entries.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        );
      },
    );
  }
}

// ─── Mileage Calculator Tab ───────────────────────────────────────────────────

class _MileageCalculatorTab extends StatefulWidget {
  const _MileageCalculatorTab();

  @override
  State<_MileageCalculatorTab> createState() => _MileageCalculatorTabState();
}

class _MileageCalculatorTabState extends State<_MileageCalculatorTab> {
  final _startOdoCtrl = TextEditingController();
  final _endOdoCtrl = TextEditingController();
  final _litersCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  double? _mileage;
  double? _costPerKm;
  double? _totalKm;

  void _calculate() {
    final start = double.tryParse(_startOdoCtrl.text);
    final end = double.tryParse(_endOdoCtrl.text);
    final liters = double.tryParse(_litersCtrl.text);
    final price = double.tryParse(_priceCtrl.text);

    if (start == null || end == null || liters == null || liters <= 0 || end <= start) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid values. End odometer must be greater than start.')),
      );
      return;
    }

    final km = end - start;
    setState(() {
      _totalKm = km;
      _mileage = km / liters;
      _costPerKm = price != null && price > 0 ? (price * liters) / km : null;
    });
  }

  void _reset() {
    _startOdoCtrl.clear();
    _endOdoCtrl.clear();
    _litersCtrl.clear();
    _priceCtrl.clear();
    setState(() { _mileage = null; _costPerKm = null; _totalKm = null; });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: primary, size: 18),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Enter your starting & ending odometer readings along with fuel filled to calculate mileage.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Odometer Readings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _InputField(controller: _startOdoCtrl, label: 'Start (km)', hint: '12000', icon: '🔵')),
                    const SizedBox(width: 12),
                    Expanded(child: _InputField(controller: _endOdoCtrl, label: 'End (km)', hint: '12400', icon: '🔴')),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Fuel Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _InputField(controller: _litersCtrl, label: 'Liters (L)', hint: '40.0', icon: '🛢️')),
                    const SizedBox(width: 12),
                    Expanded(child: _InputField(controller: _priceCtrl, label: 'Price/L (₹) opt.', hint: '106.0', icon: '💰')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _calculate,
                  child: const Text('Calculate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: BorderSide(color: primary.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                onPressed: _reset,
                child: const Text('Reset'),
              ),
            ],
          ),

          // Results
          if (_mileage != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Results', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Main mileage big display
                  Center(
                    child: Column(
                      children: [
                        const Text('⛽', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 8),
                        Text('${_mileage!.toStringAsFixed(2)} km/l',
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: primary, letterSpacing: -1)),
                        const Text('Mileage', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ResultStat(label: 'Distance', value: '${_totalKm!.toStringAsFixed(1)} km', icon: Icons.straight),
                      _ResultStat(label: 'Fuel Used', value: '${double.parse(_litersCtrl.text).toStringAsFixed(1)} L', icon: Icons.local_gas_station),
                      if (_costPerKm != null)
                        _ResultStat(label: 'Cost/km', value: '₹${_costPerKm!.toStringAsFixed(2)}', icon: Icons.attach_money),
                    ],
                  ),

                  if (_mileage! < 10) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                          SizedBox(width: 8),
                          Expanded(child: Text('Low mileage detected. Consider checking tyre pressure or engine health.', style: TextStyle(fontSize: 12, color: Colors.orange))),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String icon;
  final TextInputType textInput;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.textInput = TextInputType.number,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: textInput,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: '$icon  ',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _MiniStat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ResultStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
