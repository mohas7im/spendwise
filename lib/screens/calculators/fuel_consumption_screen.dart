import 'package:flutter/material.dart';
import '../../widgets/common/premium_gradient_card.dart';

class FuelConsumptionScreen extends StatefulWidget {
  const FuelConsumptionScreen({super.key});

  @override
  State<FuelConsumptionScreen> createState() => _FuelConsumptionScreenState();
}

class _FuelConsumptionScreenState extends State<FuelConsumptionScreen> {
  final _distanceCtrl = TextEditingController(text: '300');
  final _fuelUsedCtrl = TextEditingController(text: '20');
  final _fuelPriceCtrl = TextEditingController(text: '100');
  final _totalPaidCtrl = TextEditingController(text: '2000');
  bool _isByAmount = false;

  double get _mileage {
    final distance = double.tryParse(_distanceCtrl.text) ?? 0;
    double fuel = 0;
    if (_isByAmount) {
      final totalPaid = double.tryParse(_totalPaidCtrl.text) ?? 0;
      final price = double.tryParse(_fuelPriceCtrl.text) ?? 0;
      if (price > 0) fuel = totalPaid / price;
    } else {
      fuel = double.tryParse(_fuelUsedCtrl.text) ?? 0;
    }
    if (fuel <= 0) return 0;
    return distance / fuel;
  }

  double get _totalCost {
    if (_isByAmount) return double.tryParse(_totalPaidCtrl.text) ?? 0;
    final fuel = double.tryParse(_fuelUsedCtrl.text) ?? 0;
    final price = double.tryParse(_fuelPriceCtrl.text) ?? 0;
    return fuel * price;
  }

  double get _costPerKm {
    final distance = double.tryParse(_distanceCtrl.text) ?? 0;
    if (distance <= 0) return 0;
    return _totalCost / distance;
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
                    PremiumGradientCard(
                      builder: (context, textColor, subTextColor) => Column(
                        children: [
                          Text('Fuel Efficiency / Mileage', style: TextStyle(color: subTextColor)),
                          const SizedBox(height: 8),
                          Text('${_mileage.toStringAsFixed(1)} km/l', style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Cost Per Km', style: TextStyle(color: subTextColor, fontSize: 12)),
                                  Text('₹${_costPerKm.toStringAsFixed(2)} / km', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Total Cost', style: TextStyle(color: subTextColor, fontSize: 12)),
                                  Text('₹${_totalCost.toStringAsFixed(0)}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('By Litres'),
                          selected: !_isByAmount,
                          onSelected: (v) => setState(() => _isByAmount = false),
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('By Total Cost'),
                          selected: _isByAmount,
                          onSelected: (v) => setState(() => _isByAmount = true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    TextField(
                      controller: _distanceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Distance Travelled (km)', border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    if (!_isByAmount)
                      TextField(
                        controller: _fuelUsedCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Fuel Consumed (Litres)', border: OutlineInputBorder()),
                        onChanged: (_) => setState(() {}),
                      )
                    else
                      TextField(
                        controller: _totalPaidCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Total Amount Paid (₹)', border: OutlineInputBorder()),
                        onChanged: (_) => setState(() {}),
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _fuelPriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
