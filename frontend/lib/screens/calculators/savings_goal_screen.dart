import 'dart:math';
import 'package:flutter/material.dart';
import '../../widgets/common/premium_gradient_card.dart';

class SavingsGoalScreen extends StatefulWidget {
  const SavingsGoalScreen({super.key});

  @override
  State<SavingsGoalScreen> createState() => _SavingsGoalScreenState();
}

class _SavingsGoalScreenState extends State<SavingsGoalScreen> {
  final _goalCtrl = TextEditingController(text: '1000000');
  final _currentCtrl = TextEditingController(text: '50000');
  final _yearsCtrl = TextEditingController(text: '5');
  final _returnCtrl = TextEditingController(text: '8.0');

  double get _monthlyRequired {
    final goal = double.tryParse(_goalCtrl.text) ?? 0;
    final current = double.tryParse(_currentCtrl.text) ?? 0;
    final yValue = double.tryParse(_yearsCtrl.text) ?? 0;
    if (goal <= 0 || yValue <= 0) return 0;
    
    // Future value of current savings
    final rValue = double.tryParse(_returnCtrl.text) ?? 0;
    final r = rValue / 100 / 12;
    final n = yValue * 12;
    
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: const Duration(milliseconds: 250),
      curve: Curves.fastOutSlowIn,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.fastOutSlowIn,
        height: (MediaQuery.of(context).size.height * 0.92 - bottomInset).clamp(300.0, double.infinity),
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
                    PremiumGradientCard(
                      builder: (context, textColor, subTextColor) => Column(
                        children: [
                          Text('Monthly Savings Required', style: TextStyle(color: subTextColor)),
                          const SizedBox(height: 8),
                          Text('₹${_monthlyRequired.toStringAsFixed(0)}', style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold)),
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
                    
                    const SizedBox(height: 16),
                    TextField(
                      controller: _yearsCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Time to Goal (Years, e.g. 1.5)', border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _returnCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Expected Annual Return (%)', border: OutlineInputBorder()),
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
