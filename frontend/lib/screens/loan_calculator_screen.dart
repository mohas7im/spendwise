import 'package:flutter/material.dart';
import 'dart:math';

enum InterestType { simple, compound, reducing, flat }
enum CalcMode { emi, interestRate }

class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _tenureController = TextEditingController();
  final _emiInputController = TextEditingController(); // For when calculating interest rate

  InterestType _interestType = InterestType.reducing;
  CalcMode _calcMode = CalcMode.emi;

  double _emiOutput = 0.0;
  double _rateOutput = 0.0;
  double _totalInterest = 0.0;
  double _totalPayment = 0.0;

  void _calculate() {
    double p = double.tryParse(_principalController.text) ?? 0;
    int months = int.tryParse(_tenureController.text) ?? 0;

    if (p <= 0 || months <= 0) return;

    setState(() {
      if (_calcMode == CalcMode.emi) {
        double rAnnual = double.tryParse(_rateController.text) ?? 0;
        if (rAnnual <= 0) return;
        double rMonthly = (rAnnual / 12) / 100;

        switch (_interestType) {
          case InterestType.reducing:
            _emiOutput = (p * rMonthly * pow(1 + rMonthly, months)) / (pow(1 + rMonthly, months) - 1);
            _totalPayment = _emiOutput * months;
            _totalInterest = _totalPayment - p;
            break;
          case InterestType.flat:
          case InterestType.simple:
            _totalInterest = p * (rAnnual / 100) * (months / 12);
            _totalPayment = p + _totalInterest;
            _emiOutput = _totalPayment / months;
            break;
          case InterestType.compound:
            double years = months / 12;
            _totalPayment = p * pow(1 + (rAnnual / 100), years);
            _totalInterest = _totalPayment - p;
            _emiOutput = _totalPayment / months;
            break;
        }
      } else {
        // Calculate Interest Rate based on EMI
        double emiIn = double.tryParse(_emiInputController.text) ?? 0;
        if (emiIn <= 0 || (emiIn * months) <= p) return;

        _totalPayment = emiIn * months;
        _totalInterest = _totalPayment - p;
        _emiOutput = emiIn;

        switch (_interestType) {
          case InterestType.flat:
          case InterestType.simple:
          case InterestType.compound: // Simplified approximation for all non-reducing
            _rateOutput = (_totalInterest / p) / (months / 12) * 100;
            break;
          case InterestType.reducing:
            // Binary search to find the monthly interest rate
            double low = 0.0;
            double high = 1.0; // 100% per month is way too high but safe upper bound
            double mid = 0.0;
            for (int i = 0; i < 60; i++) {
              mid = (low + high) / 2;
              double guessedEmi = (p * mid * pow(1 + mid, months)) / (pow(1 + mid, months) - 1);
              if (guessedEmi > emiIn) {
                high = mid;
              } else {
                low = mid;
              }
            }
            _rateOutput = mid * 12 * 100; // Convert monthly decimal to annual percentage
            break;
        }
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
            
            // Mode Toggle
            Center(
              child: SegmentedButton<CalcMode>(
                segments: const [
                  ButtonSegment(value: CalcMode.emi, label: Text('Find EMI')),
                  ButtonSegment(value: CalcMode.interestRate, label: Text('Find Interest Rate')),
                ],
                selected: {_calcMode},
                onSelectionChanged: (Set<CalcMode> newSelection) {
                  setState(() {
                    _calcMode = newSelection.first;
                    _calculate();
                  });
                },
              ),
            ),
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
                  child: _calcMode == CalcMode.emi
                    ? TextField(
                        controller: _rateController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Interest % (p.a.)', border: OutlineInputBorder()),
                        onChanged: (_) => _calculate(),
                      )
                    : TextField(
                        controller: _emiInputController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Known EMI (₹)', border: OutlineInputBorder()),
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
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  if (_calcMode == CalcMode.emi) ...[
                    const Text('Monthly EMI', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text('₹${_emiOutput.toStringAsFixed(0)}', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  ] else ...[
                    const Text('Estimated Interest Rate (p.a.)', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text('${_rateOutput.toStringAsFixed(2)}%', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  ],
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
