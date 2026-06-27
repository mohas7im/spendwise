import 'dart:math';
import 'package:flutter/material.dart';

class LoanAffordabilityScreen extends StatefulWidget {
  const LoanAffordabilityScreen({super.key});

  @override
  State<LoanAffordabilityScreen> createState() => _LoanAffordabilityScreenState();
}

class _LoanAffordabilityScreenState extends State<LoanAffordabilityScreen> {
  final _emiCtrl = TextEditingController(text: '15000');
  double _interestRate = 9.5;
  double _years = 10;

  double get _maxLoanAmount {
    final emi = double.tryParse(_emiCtrl.text) ?? 0;
    if (emi <= 0 || _years <= 0) return 0;
    
    final r = _interestRate / 12 / 100;
    final n = _years * 12;
    
    if (r == 0) return emi * n;
    
    // P = EMI * ((1+r)^n - 1) / (r * (1+r)^n)
    final num = pow(1 + r, n) - 1;
    final den = r * pow(1 + r, n);
    return emi * (num / den);
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
            Text('Loan Affordability', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.blue, Colors.blue.shade700]),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          const Text('Maximum Loan You Can Afford', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 8),
                          Text('₹${_maxLoanAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    TextField(
                      controller: _emiCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Affordable Monthly EMI (₹)', border: OutlineInputBorder()),
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
                      activeColor: Colors.blue,
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
                      activeColor: Colors.blue,
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
