import 'dart:math';
import 'package:flutter/material.dart';

class SavingsGrowthScreen extends StatefulWidget {
  const SavingsGrowthScreen({super.key});

  @override
  State<SavingsGrowthScreen> createState() => _SavingsGrowthScreenState();
}

class _SavingsGrowthScreenState extends State<SavingsGrowthScreen> {
  final _initialCtrl = TextEditingController(text: '10000');
  final _monthlyCtrl = TextEditingController(text: '5000');
  double _returnRate = 12.0;
  double _years = 10;

  double get _futureValue {
    final p = double.tryParse(_initialCtrl.text) ?? 0;
    final pmt = double.tryParse(_monthlyCtrl.text) ?? 0;
    
    final r = _returnRate / 100 / 12;
    final n = _years * 12;
    
    if (r == 0) return p + (pmt * n);
    
    final fvInitial = p * pow(1 + r, n);
    final fvContributions = pmt * ((pow(1 + r, n) - 1) / r);
    return fvInitial + fvContributions;
  }
  
  double get _totalInvested {
    final p = double.tryParse(_initialCtrl.text) ?? 0;
    final pmt = double.tryParse(_monthlyCtrl.text) ?? 0;
    return p + (pmt * _years * 12);
  }

  double get _totalInterest => _futureValue - _totalInvested;

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
            Text('Savings Growth', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
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
                          Text('Future Value', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                          const SizedBox(height: 8),
                          Text('₹${_futureValue.toStringAsFixed(0)}', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 32, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Invested', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12)),
                                  Text('₹${_totalInvested.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Wealth Gained', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12)),
                                  Text('₹${_totalInterest.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    TextField(
                      controller: _initialCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Initial Investment (₹)', border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _monthlyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Monthly Contribution (₹)', border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Expected Return Rate (%)'),
                        Text('${_returnRate.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    Slider(
                      value: _returnRate,
                      min: 1,
                      max: 30,
                      divisions: 58,
                      activeColor: Colors.teal,
                      onChanged: (v) => setState(() => _returnRate = v),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Investment Period (Years)'),
                        Text('${_years.toStringAsFixed(1)} Yrs', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    Slider(
                      value: _years,
                      min: 1,
                      max: 40,
                      divisions: 39,
                      activeColor: Colors.teal,
                      onChanged: (v) => setState(() => _years = v),
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
