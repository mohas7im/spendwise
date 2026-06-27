import 'dart:math';
import 'package:flutter/material.dart';

class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  final _amountCtrl = TextEditingController(text: '500000');
  final _rateCtrl = TextEditingController(text: '10.5');
  final _yearsCtrl = TextEditingController(text: '5');

  double get _emi {
    final p = double.tryParse(_amountCtrl.text) ?? 0;
    final yValue = double.tryParse(_yearsCtrl.text) ?? 0;
    if (p <= 0 || yValue <= 0) return 0;
    
    final rValue = double.tryParse(_rateCtrl.text) ?? 0;
    final r = rValue / 12 / 100;
    final n = yValue * 12;
    
    if (r == 0) return p / n;
    
    return (p * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
  }

  double get _totalPayment {
    final yValue = double.tryParse(_yearsCtrl.text) ?? 0;
    return _emi * (yValue * 12);
  }
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
                    
                    const SizedBox(height: 16),
                    TextField(
                      controller: _rateCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Interest Rate (%) - up to 50%', border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _yearsCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Tenure (Years, e.g. 1.5 for 18 months)', border: OutlineInputBorder()),
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
