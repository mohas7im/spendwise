import 'dart:math';
import 'package:flutter/material.dart';

class LoanAffordabilityScreen extends StatefulWidget {
  const LoanAffordabilityScreen({super.key});

  @override
  State<LoanAffordabilityScreen> createState() => _LoanAffordabilityScreenState();
}

class _LoanAffordabilityScreenState extends State<LoanAffordabilityScreen> {
  final _emiCtrl = TextEditingController(text: '15000');
  final _rateCtrl = TextEditingController(text: '9.5');
  final _yearsCtrl = TextEditingController(text: '10');

  double get _maxLoanAmount {
    final emi = double.tryParse(_emiCtrl.text) ?? 0;
    final yValue = double.tryParse(_yearsCtrl.text) ?? 0;
    if (emi <= 0 || yValue <= 0) return 0;
    
    final rValue = double.tryParse(_rateCtrl.text) ?? 0;
    final r = rValue / 12 / 100;
    final n = yValue * 12;
    
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
                          Text('Maximum Loan You Can Afford', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                          const SizedBox(height: 8),
                          Text('₹${_maxLoanAmount.toStringAsFixed(0)}', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 32, fontWeight: FontWeight.bold)),
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
                    
                    const SizedBox(height: 16),
                    TextField(
                      controller: _rateCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Interest Rate (%)', border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _yearsCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Tenure (Years, e.g. 1.5)', border: OutlineInputBorder()),
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
