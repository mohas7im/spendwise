import 'dart:math';
import 'package:flutter/material.dart';

class SavingsGoalScreen extends StatefulWidget {
  const SavingsGoalScreen({super.key});

  @override
  State<SavingsGoalScreen> createState() => _SavingsGoalScreenState();
}

class _SavingsGoalScreenState extends State<SavingsGoalScreen> {
  final _goalCtrl = TextEditingController(text: '1000000');
  final _currentCtrl = TextEditingController(text: '50000');
  double _years = 5;
  double _returnRate = 8.0;

  double get _monthlyRequired {
    final goal = double.tryParse(_goalCtrl.text) ?? 0;
    final current = double.tryParse(_currentCtrl.text) ?? 0;
    if (goal <= 0 || _years <= 0) return 0;
    
    // Future value of current savings
    final r = _returnRate / 100 / 12;
    final n = _years * 12;
    
    final fvCurrent = current * pow(1 + r, n);
    final remainingGoal = goal - fvCurrent;
    
    if (remainingGoal <= 0) return 0;
    
    if (r == 0) return remainingGoal / n;
    
    // PMT formula: P = (FV * r) / ((1 + r)^n - 1)
    final pmt = (remainingGoal * r) / (pow(1 + r, n) - 1);
    return pmt;
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
            Text('Savings Goal Calculator', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.green, Colors.green.shade700]),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          const Text('Monthly Savings Required', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 8),
                          Text('₹${_monthlyRequired.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    TextField(
                      controller: _goalCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Target Goal Amount (₹)', border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _currentCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Current Savings (₹)', border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Time to Goal (Years)'),
                        Text('${_years.toStringAsFixed(1)} Yrs', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    Slider(
                      value: _years,
                      min: 0.5,
                      max: 30,
                      divisions: 59,
                      activeColor: Colors.green,
                      onChanged: (v) => setState(() => _years = v),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Expected Annual Return (%)'),
                        Text('${_returnRate.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    Slider(
                      value: _returnRate,
                      min: 1,
                      max: 20,
                      divisions: 38,
                      activeColor: Colors.green,
                      onChanged: (v) => setState(() => _returnRate = v),
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
