import 'dart:math';
import 'package:flutter/material.dart';

class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  final _amountCtrl = TextEditingController(text: '500000');
  double _interestRate = 10.5;
  double _years = 5;

  double get _emi {
    final p = double.tryParse(_amountCtrl.text) ?? 0;
    if (p <= 0 || _years <= 0) return 0;
    
    final r = _interestRate / 12 / 100;
    final n = _years * 12;
    
    if (r == 0) return p / n;
    
    return (p * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
  }

  double get _totalPayment => _emi * (_years * 12);
  double get _totalInterest => _totalPayment - (double.tryParse(_amountCtrl.text) ?? 0);

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
            Text('EMI Calculator', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
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
                          Text('Monthly EMI', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                          const SizedBox(height: 8),
                          Text('₹${_emi.toStringAsFixed(0)}', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 32, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Interest', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12)),
                                  Text('₹${_totalInterest.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Total Payment', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12)),
                                  Text('₹${_totalPayment.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Loan Amount (₹)', border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Interest Rate (%)'),
                        Text('${_interestRate.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    Slider(
                      value: _interestRate,
                      min: 1,
                      max: 25,
                      divisions: 48,
                      activeColor: Colors.indigo,
                      onChanged: (v) => setState(() => _interestRate = v),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tenure (Years)'),
                        Text('${_years.toStringAsFixed(1)} Yrs', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    Slider(
                      value: _years,
                      min: 0.5,
                      max: 30,
                      divisions: 59,
                      activeColor: Colors.indigo,
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
