import 'package:flutter/material.dart';
import 'dart:math';

enum InterestType { simple, compound, reducing, flat }

class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _tenureController = TextEditingController();

  InterestType _interestType = InterestType.reducing;

  double _emi = 0.0;
  double _totalInterest = 0.0;
  double _totalPayment = 0.0;

  void _calculate() {
    double p = double.tryParse(_principalController.text) ?? 0;
    double rAnnual = double.tryParse(_rateController.text) ?? 0;
    int months = int.tryParse(_tenureController.text) ?? 0;

    if (p <= 0 || rAnnual <= 0 || months <= 0) return;

    double rMonthly = (rAnnual / 12) / 100;
    
    setState(() {
      switch (_interestType) {
        case InterestType.reducing:
          // Standard EMI Formula: P * r * (1 + r)^n / ((1 + r)^n - 1)
          _emi = (p * rMonthly * pow(1 + rMonthly, months)) / (pow(1 + rMonthly, months) - 1);
          _totalPayment = _emi * months;
          _totalInterest = _totalPayment - p;
          break;
        case InterestType.flat:
        case InterestType.simple:
          // Simple/Flat: Interest = P * R * T (in years)
          _totalInterest = p * (rAnnual / 100) * (months / 12);
          _totalPayment = p + _totalInterest;
          _emi = _totalPayment / months;
          break;
        case InterestType.compound:
          // Compound annually, but paid monthly? This is rare for simple loans but let's calculate total amount.
          // A = P(1 + r/n)^(nt). Assuming compounded yearly.
          double years = months / 12;
          _totalPayment = p * pow(1 + (rAnnual / 100), years);
          _totalInterest = _totalPayment - p;
          _emi = _totalPayment / months; // simplistic monthly division
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Interest Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Calculate your loan payments before borrowing.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            
            // Inputs
            TextField(
              controller: _principalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Loan Amount (Principal) ₹', border: OutlineInputBorder()),
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Interest % (p.a.)', border: OutlineInputBorder()),
                    onChanged: (_) => _calculate(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _tenureController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Tenure (Months)', border: OutlineInputBorder()),
                    onChanged: (_) => _calculate(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Interest Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: InterestType.values.map((t) => ChoiceChip(
                label: Text(t.name.toUpperCase()),
                selected: _interestType == t,
                onSelected: (val) {
                  if (val) {
                    setState(() {
                      _interestType = t;
                      _calculate();
                    });
                  }
                },
              )).toList(),
            ),
            const SizedBox(height: 32),

            // Outputs
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('Monthly EMI', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('₹${_emi.toStringAsFixed(0)}', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Interest', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('₹${_totalInterest.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Total Payment', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('₹${_totalPayment.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
