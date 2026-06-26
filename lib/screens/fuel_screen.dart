import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/fuel_provider.dart';
import '../models/fuel_entry.dart';

class FuelScreen extends StatefulWidget {
  final int initialTab;
  const FuelScreen({super.key, this.initialTab = 0});

  @override
  State<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends State<FuelScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 6, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Fuel & Vehicle Tools', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          labelColor: primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Quantity'),
            Tab(text: 'Mileage'),
            Tab(text: 'Trip Cost'),
            Tab(text: 'Split'),
            Tab(text: 'Running Cost'),
            Tab(text: 'Tracker'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _FuelQuantityTab(),
          _MileageCalculatorTab(),
          _TripFuelCostTab(),
          _FuelBillSplitTab(),
          _VehicleRunningCostTab(),
          _FuelConsumptionTrackerTab(),
        ],
      ),
    );
  }
}

// ─── 1. Fuel Quantity Calculator ──────────────────────────────────────────────
class _FuelQuantityTab extends StatefulWidget {
  const _FuelQuantityTab();
  @override
  State<_FuelQuantityTab> createState() => _FuelQuantityTabState();
}
class _FuelQuantityTabState extends State<_FuelQuantityTab> {
  final _amountCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  double? _liters;

  void _calculate() {
    final amt = double.tryParse(_amountCtrl.text);
    final price = double.tryParse(_priceCtrl.text);
    if (amt == null || price == null || price <= 0) return;
    setState(() => _liters = amt / price);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _CalcCard(
            title: 'Calculate Fuel Quantity',
            children: [
              _InputField(controller: _amountCtrl, label: 'Amount Paid (₹)', hint: '500', icon: '💰', onChanged: (_) => _calculate()),
              const SizedBox(height: 12),
              _InputField(controller: _priceCtrl, label: 'Fuel Price Per Litre (₹)', hint: '106.0', icon: '⛽', onChanged: (_) => _calculate()),
            ],
          ),
          if (_liters != null)
            _ResultBox(
              title: 'Fuel Filled',
              value: '${_liters!.toStringAsFixed(2)} Litres',
              emoji: '🛢️',
              primary: primary,
            ),
        ],
      ),
    );
  }
}

// ─── 2. Mileage Calculator ────────────────────────────────────────────────────
class _MileageCalculatorTab extends StatefulWidget {
  const _MileageCalculatorTab();
  @override
  State<_MileageCalculatorTab> createState() => _MileageCalculatorTabState();
}
class _MileageCalculatorTabState extends State<_MileageCalculatorTab> {
  final _distCtrl = TextEditingController();
  final _fuelCtrl = TextEditingController();
  double? _mileage;

  void _calculate() {
    final dist = double.tryParse(_distCtrl.text);
    final fuel = double.tryParse(_fuelCtrl.text);
    if (dist == null || fuel == null || fuel <= 0) return;
    setState(() => _mileage = dist / fuel);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _CalcCard(
            title: 'Calculate Mileage',
            children: [
              _InputField(controller: _distCtrl, label: 'Distance Travelled (km)', hint: '250', icon: '📍', onChanged: (_) => _calculate()),
              const SizedBox(height: 12),
              _InputField(controller: _fuelCtrl, label: 'Fuel Consumed (L)', hint: '5', icon: '🛢️', onChanged: (_) => _calculate()),
            ],
          ),
          if (_mileage != null)
            _ResultBox(
              title: 'Vehicle Mileage',
              value: '${_mileage!.toStringAsFixed(1)} km/L',
              emoji: '🚗',
              primary: primary,
            ),
        ],
      ),
    );
  }
}

// ─── 3. Trip Fuel Cost Calculator ─────────────────────────────────────────────
class _TripFuelCostTab extends StatefulWidget {
  const _TripFuelCostTab();
  @override
  State<_TripFuelCostTab> createState() => _TripFuelCostTabState();
}
class _TripFuelCostTabState extends State<_TripFuelCostTab> {
  final _distCtrl = TextEditingController();
  final _milCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  double? _fuelReq;
  double? _estCost;

  void _calculate() {
    final dist = double.tryParse(_distCtrl.text);
    final mil = double.tryParse(_milCtrl.text);
    final price = double.tryParse(_priceCtrl.text);
    if (dist == null || mil == null || price == null || mil <= 0) return;
    setState(() {
      _fuelReq = dist / mil;
      _estCost = _fuelReq! * price;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _CalcCard(
            title: 'Estimate Trip Cost',
            children: [
              _InputField(controller: _distCtrl, label: 'Total Distance (km)', hint: '500', icon: '🗺️', onChanged: (_) => _calculate()),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _InputField(controller: _milCtrl, label: 'Mileage (km/L)', hint: '15.0', icon: '🚗', onChanged: (_) => _calculate())),
                  const SizedBox(width: 12),
                  Expanded(child: _InputField(controller: _priceCtrl, label: 'Fuel Price (₹)', hint: '106.0', icon: '💰', onChanged: (_) => _calculate())),
                ],
              ),
            ],
          ),
          if (_estCost != null)
            _ResultBox(
              title: 'Estimated Cost',
              value: '₹${_estCost!.toStringAsFixed(0)}',
              emoji: '💸',
              primary: primary,
              subtext: 'Fuel Required: ${_fuelReq!.toStringAsFixed(1)} L',
            ),
        ],
      ),
    );
  }
}

// ─── 4. Fuel Bill Split Calculator ────────────────────────────────────────────
class _FuelBillSplitTab extends StatefulWidget {
  const _FuelBillSplitTab();
  @override
  State<_FuelBillSplitTab> createState() => _FuelBillSplitTabState();
}
class _FuelBillSplitTabState extends State<_FuelBillSplitTab> {
  final _expCtrl = TextEditingController();
  final _pplCtrl = TextEditingController(text: '2');
  final _pctCtrl = TextEditingController();
  final _customCtrl = TextEditingController();
  
  String _splitMethod = 'Equal';
  double? _splitAmt;

  void _calculate() {
    final exp = double.tryParse(_expCtrl.text);
    if (exp == null) return;

    if (_splitMethod == 'Equal') {
      final ppl = int.tryParse(_pplCtrl.text);
      if (ppl != null && ppl > 0) {
        setState(() => _splitAmt = exp / ppl);
      }
    } else if (_splitMethod == 'Percentage') {
      final pct = double.tryParse(_pctCtrl.text);
      if (pct != null && pct >= 0 && pct <= 100) {
        setState(() => _splitAmt = exp * (pct / 100));
      }
    } else if (_splitMethod == 'Custom') {
      final custom = double.tryParse(_customCtrl.text);
      if (custom != null) {
        setState(() => _splitAmt = exp - custom);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _CalcCard(
            title: 'Split Trip Fuel Cost',
            children: [
              _InputField(controller: _expCtrl, label: 'Total Fuel Expense (₹)', hint: '2000', icon: '🧾', onChanged: (_) => _calculate()),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.pie_chart_outline, color: Colors.grey, size: 20),
                  const SizedBox(width: 12),
                  const Text('Split Method:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _splitMethod,
                      isExpanded: true,
                      items: ['Equal', 'Percentage', 'Custom'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _splitMethod = val;
                            _splitAmt = null;
                            _calculate();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_splitMethod == 'Equal')
                _InputField(controller: _pplCtrl, label: 'Number of Participants', hint: '4', icon: '👥', textInput: TextInputType.number, onChanged: (_) => _calculate())
              else if (_splitMethod == 'Percentage')
                _InputField(controller: _pctCtrl, label: 'Your Percentage (%)', hint: '50', icon: '⚖️', onChanged: (_) => _calculate())
              else if (_splitMethod == 'Custom')
                _InputField(controller: _customCtrl, label: 'Amount Paid by Others (₹)', hint: '1000', icon: '💵', onChanged: (_) => _calculate()),
            ],
          ),
          if (_splitAmt != null)
            _ResultBox(
              title: _splitMethod == 'Equal' ? 'Amount per person' : 'You Pay',
              value: '₹${_splitAmt!.toStringAsFixed(0)}',
              emoji: '🤝',
              primary: primary,
            ),
        ],
      ),
    );
  }
}

// ─── 5. Vehicle Running Cost Calculator ───────────────────────────────────────
class _VehicleRunningCostTab extends StatefulWidget {
  const _VehicleRunningCostTab();
  @override
  State<_VehicleRunningCostTab> createState() => _VehicleRunningCostTabState();
}
class _VehicleRunningCostTabState extends State<_VehicleRunningCostTab> {
  final _fuelCtrl = TextEditingController();
  final _serviceCtrl = TextEditingController();
  final _insCtrl = TextEditingController();
  final _maintCtrl = TextEditingController();
  final _otherCtrl = TextEditingController();
  
  double? _monthly;
  double? _annual;

  void _calculate() {
    final f = double.tryParse(_fuelCtrl.text) ?? 0;
    final s = double.tryParse(_serviceCtrl.text) ?? 0;
    final i = double.tryParse(_insCtrl.text) ?? 0;
    final m = double.tryParse(_maintCtrl.text) ?? 0;
    final o = double.tryParse(_otherCtrl.text) ?? 0;
    
    // Convert to monthly assuming inputs are monthly except maybe insurance.
    // Let's assume all inputs are monthly for simplicity, OR we add dropdowns.
    // The spec says: Inputs: Monthly Fuel, Service, Insurance, Maintenance, Other
    final totalMonthly = f + s + i + m + o;
    if (totalMonthly == 0) return;
    setState(() {
      _monthly = totalMonthly;
      _annual = totalMonthly * 12;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _CalcCard(
            title: 'Monthly Expenses',
            children: [
              _InputField(controller: _fuelCtrl, label: 'Fuel Cost (₹)', hint: '3000', icon: '⛽', onChanged: (_) => _calculate()),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _InputField(controller: _serviceCtrl, label: 'Service (₹)', hint: '500', icon: '🔧', onChanged: (_) => _calculate())),
                  const SizedBox(width: 12),
                  Expanded(child: _InputField(controller: _insCtrl, label: 'Insurance (₹)', hint: '800', icon: '📄', onChanged: (_) => _calculate())),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _InputField(controller: _maintCtrl, label: 'Maintenance', hint: '200', icon: '🛠️', onChanged: (_) => _calculate())),
                  const SizedBox(width: 12),
                  Expanded(child: _InputField(controller: _otherCtrl, label: 'Other', hint: '100', icon: '➕', onChanged: (_) => _calculate())),
                ],
              ),
            ],
          ),
          if (_monthly != null)
            _ResultBox(
              title: 'Total Running Cost',
              value: '₹${_monthly!.toStringAsFixed(0)} / mo',
              emoji: '🚘',
              primary: primary,
              subtext: 'Annual: ₹${_annual!.toStringAsFixed(0)}',
            ),
        ],
      ),
    );
  }
}

// ─── 6. Fuel Consumption Tracker ──────────────────────────────────────────────
class _FuelConsumptionTrackerTab extends StatefulWidget {
  const _FuelConsumptionTrackerTab();
  @override
  State<_FuelConsumptionTrackerTab> createState() => _FuelConsumptionTrackerTabState();
}
class _FuelConsumptionTrackerTabState extends State<_FuelConsumptionTrackerTab> {
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
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 16, left: 24, right: 24, top: 24),
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
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now());
                    if (picked != null) setSheet(() => selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 10),
                        Text(DateFormat('dd MMM yyyy').format(selectedDate), style: const TextStyle(fontWeight: FontWeight.w500)),
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
                _InputField(controller: odometerCtrl, label: 'Odometer (km)', hint: 'Current km', icon: '📍'),
                const SizedBox(height: 12),
                _InputField(controller: notesCtrl, label: 'Notes (opt)', hint: 'e.g. Highway', icon: '📝', textInput: TextInputType.text),
                const SizedBox(height: 24),
                ValueListenableBuilder(
                  valueListenable: litersCtrl,
                  builder: (_, _, _) => ValueListenableBuilder(
                    valueListenable: priceCtrl,
                    builder: (_, _, _) {
                      final l = double.tryParse(litersCtrl.text) ?? 0;
                      final p = double.tryParse(priceCtrl.text) ?? 0;
                      if (l * p == 0) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text('Total Cost: ₹${(l * p).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.redAccent)),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    onPressed: () {
                      final liters = double.tryParse(litersCtrl.text);
                      final price = double.tryParse(priceCtrl.text);
                      final odo = double.tryParse(odometerCtrl.text);
                      if (liters != null && price != null && odo != null) {
                        Provider.of<FuelProvider>(context, listen: false).addEntry(
                          FuelEntry(id: DateTime.now().millisecondsSinceEpoch.toString(), date: selectedDate, odometer: odo, liters: liters, pricePerLiter: price, notes: notesCtrl.text.isEmpty ? null : notesCtrl.text),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save Entry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FuelProvider>(
      builder: (ctx, fuel, _) {
        final entries = fuel.entries;
        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No fill-ups logged yet.', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showAddFillUpSheet(context),
                  child: const Text('Log First Fill-Up'),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  // Calculate Average Mileage and Monthly Spending
                  final sortedAll = [...entries]..sort((a, b) => a.date.compareTo(b.date));
                  double totalLiters = 0;
                  double totalCost = 0;
                  double totalKm = 0;

                  for (int i = 0; i < sortedAll.length; i++) {
                    totalCost += sortedAll[i].totalCost;
                    if (i > 0) {
                      final km = sortedAll[i].odometer - sortedAll[i - 1].odometer;
                      if (km > 0 && sortedAll[i].liters > 0) {
                        totalKm += km;
                        totalLiters += sortedAll[i].liters;
                      }
                    }
                  }

                  final avgMileage = totalLiters > 0 ? totalKm / totalLiters : 0.0;

                  // Simple monthly average based on first and last entry
                  double avgMonthlyCost = 0.0;
                  if (sortedAll.isNotEmpty) {
                    final days = sortedAll.last.date.difference(sortedAll.first.date).inDays;
                    if (days > 30) {
                      avgMonthlyCost = (totalCost / days) * 30;
                    } else {
                      avgMonthlyCost = totalCost; // If less than a month, just show total
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
                            child: Column(
                              children: [
                                const Text('Avg Mileage', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(avgMileage > 0 ? avgMileage.toStringAsFixed(1) : '--', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                                const Text('km/L', style: TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
                            child: Column(
                              children: [
                                const Text('Est. Monthly', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text('₹${avgMonthlyCost.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                const Text('spending', style: TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Entry'),
                      onPressed: () => _showAddFillUpSheet(context),
                    )
                  ],
                ),
              ),
            ),
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
                    background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 24), color: Colors.red.withValues(alpha: 0.2), child: const Icon(Icons.delete_outline, color: Colors.redAccent)),
                    onDismissed: (_) => Provider.of<FuelProvider>(ctx, listen: false).deleteEntry(entry.id),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Text('⛽', style: TextStyle(fontSize: 18))),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(DateFormat('dd MMM yyyy').format(entry.date), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    if (entry.notes != null) Text(entry.notes!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('₹${entry.totalCost.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('${entry.liters.toStringAsFixed(1)} L', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                          if (mileage != null) ...[
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Odometer: ${entry.odometer.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                Text('${mileage.toStringAsFixed(1)} km/l', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
                childCount: entries.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }
}

// ─── Shared UI Components ─────────────────────────────────────────────────────
class _CalcCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _CalcCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).primaryColor)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  final String title;
  final String value;
  final String emoji;
  final Color primary;
  final String? subtext;

  const _ResultBox({required this.title, required this.value, required this.emoji, required this.primary, this.subtext});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primary, letterSpacing: -1)),
          if (subtext != null) ...[
            const SizedBox(height: 8),
            Text(subtext!, style: TextStyle(color: primary.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w500)),
          ]
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String icon;
  final TextInputType textInput;
  final void Function(String)? onChanged;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.textInput = TextInputType.number,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: textInput,
        onChanged: onChanged,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.normal),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(icon, style: const TextStyle(fontSize: 16)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
