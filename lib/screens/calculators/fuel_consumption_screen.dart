import 'package:flutter/material.dart';

class FuelConsumptionScreen extends StatefulWidget {
  const FuelConsumptionScreen({super.key});

  @override
  State<FuelConsumptionScreen> createState() => _FuelConsumptionScreenState();
}

class _FuelConsumptionScreenState extends State<FuelConsumptionScreen> {
  final _distanceCtrl = TextEditingController(text: '300');
  final _fuelUsedCtrl = TextEditingController(text: '20');
  final _fuelPriceCtrl = TextEditingController(text: '100');

  double get _mileage {
    final distance = double.tryParse(_distanceCtrl.text) ?? 0;
    final fuel = double.tryParse(_fuelUsedCtrl.text) ?? 0;
    if (fuel <= 0) return 0;
    return distance / fuel;
  }

  double get _costPerKm {
    final mileage = _mileage;
    final price = double.tryParse(_fuelPriceCtrl.text) ?? 0;
    if (mileage <= 0) return 0;
    return price / mileage;
  }

  double get _totalCost {
    final fuel = double.tryParse(_fuelUsedCtrl.text) ?? 0;
    final price = double.tryParse(_fuelPriceCtrl.text) ?? 0;
    return fuel * price;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: MediaQuery.of(context).padding.top + 24,
      ),
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
            Text('Fuel & Mileage', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Text('Fuel Efficiency / Mileage', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                          const SizedBox(height: 8),
                          Text('${_mileage.toStringAsFixed(1)} km/l', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 32, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Cost Per Km', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12)),
                                  Text('₹${_costPerKm.toStringAsFixed(2)} / km', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Total Cost', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12)),
                                  Text('₹${_totalCost.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    TextField(
                      controller: _distanceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Distance Travelled (km)', border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _fuelUsedCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Fuel Consumed (Litres)', border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _fuelPriceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Fuel Price (per Litre)', border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
