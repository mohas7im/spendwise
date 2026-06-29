import 'package:flutter/material.dart';
import '../widgets/common/premium_gradient_card.dart';

class BuyCoffeeScreen extends StatefulWidget {
  const BuyCoffeeScreen({super.key});

  @override
  State<BuyCoffeeScreen> createState() => _BuyCoffeeScreenState();
}

class _BuyCoffeeScreenState extends State<BuyCoffeeScreen> {
  double _selectedAmount = 100;
  final _customAmountController = TextEditingController();

  void _processPayment() {
    double amount = _selectedAmount;
    if (_selectedAmount == 0) {
      amount = double.tryParse(_customAmountController.text) ?? 0;
    }
    
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    // Dummy payment
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thank you! Redirecting to payment gateway for ₹${amount.toStringAsFixed(0)}...'),
        backgroundColor: Colors.green,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support the Developer', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Text('☕', style: const TextStyle(fontSize: 64)),
            ),
            const SizedBox(height: 32),
            Text('Buy me a coffee!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'If you enjoy using SpendWise, consider supporting my work to keep the updates coming!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 48),

            // Amount selector
            Row(
              children: [
                _buildAmountOption(100),
                const SizedBox(width: 16),
                _buildAmountOption(250),
                const SizedBox(width: 16),
                _buildAmountOption(500),
              ],
            ),
            const SizedBox(height: 16),
            
            // Custom amount
            GestureDetector(
              onTap: () => setState(() => _selectedAmount = 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: _selectedAmount == 0 ? Theme.of(context).primaryColor : Colors.grey.withValues(alpha: 0.2), width: 2),
                  borderRadius: BorderRadius.circular(16),
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    const Text('₹', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _customAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Custom Amount',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onTap: () => setState(() => _selectedAmount = 0),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),
            
            SizedBox(
              width: 200,
              child: PremiumGradientCard(
                builder: (context, textColor, subTextColor) {
                  return InkWell(
                    onTap: _processPayment,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      child: Text(
                        'Pay Now',
                        style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountOption(double amount) {
    final isSelected = _selectedAmount == amount;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedAmount = amount;
          _customAmountController.clear();
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A1A) : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '₹${amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
