import 'dart:math';
import 'package:flutter/material.dart';
import '../../widgets/common/premium_gradient_card.dart';

class SavingsGrowthScreen extends StatefulWidget {
  const SavingsGrowthScreen({super.key});

  @override
  State<SavingsGrowthScreen> createState() => _SavingsGrowthScreenState();
}

class _SavingsGrowthScreenState extends State<SavingsGrowthScreen> {
  final _initialCtrl = TextEditingController(text: '10000');
  final _monthlyCtrl = TextEditingController(text: '10000');
  final _yearsCtrl = TextEditingController(text: '10');
  final _returnCtrl = TextEditingController(text: '12.0');

  double get _futureValue {
    final p = double.tryParse(_initialCtrl.text) ?? 0;
    final pmt = double.tryParse(_monthlyCtrl.text) ?? 0;
    final yValue = double.tryParse(_yearsCtrl.text) ?? 0;
    
    if (pmt <= 0 || yValue <= 0) return p;
    
    final rValue = double.tryParse(_returnCtrl.text) ?? 0;
    final r = rValue / 100 / 12;
    final n = yValue * 12;
    
    if (r == 0) return p + (pmt * n);
    
    final fvInitial = p * pow(1 + r, n);
    final fvContributions = pmt * ((pow(1 + r, n) - 1) / r);
    return fvInitial + fvContributions;
  }
  
  double get _totalInvested {
    final p = double.tryParse(_initialCtrl.text) ?? 0;
    final yValue = double.tryParse(_yearsCtrl.text) ?? 0;
    return p + ((double.tryParse(_monthlyCtrl.text) ?? 0) * (yValue * 12));
  }

  double get _totalInterest => _futureValue - _totalInvested;

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
            Text('Savings Growth', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    PremiumGradientCard(
                      builder: (context, textColor, subTextColor) => Column(
                        children: [
                          Text('Future Value', style: TextStyle(color: subTextColor)),
                          const SizedBox(height: 8),
                          Text('₹${_futureValue.toStringAsFixed(0)}', style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Invested', style: TextStyle(color: subTextColor, fontSize: 12)),
                                  Text('₹${_totalInvested.toStringAsFixed(0)}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Wealth Gained', style: TextStyle(color: subTextColor, fontSize: 12)),
                                  Text('₹${_totalInterest.toStringAsFixed(0)}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: _yearsCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Investment Duration (Years)', border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _returnCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Expected Return Rate (%)', border: OutlineInputBorder()),
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
