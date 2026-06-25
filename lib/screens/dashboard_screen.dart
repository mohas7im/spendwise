import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/dummy_data_service.dart';
import '../models/transaction.dart';
import '../main.dart'; // for ThemeProvider
import '../widgets/balance_section.dart';
import '../widgets/action_buttons.dart';
import '../widgets/transaction_card.dart';
import 'profile_screen.dart';
import 'split_calculator_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<TransactionModel> transactions = DummyDataService.getDummyTransactions();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 120.0), // Extra bottom padding for floating navbar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                      },
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome Back,', style: Theme.of(context).textTheme.bodyMedium),
                        Text('Jacob Simmons', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                      ],
                    )
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                      onPressed: () => themeProvider.toggleTheme(!isDark),
                    ),
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none, size: 20),
                        onPressed: () {},
                      ),
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            
            // Balance Section (Dark Mode style maintained)
            const BalanceSection(),
            const SizedBox(height: 16),
            
            // Split Bill Button
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SplitCalculatorScreen())),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt_long, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 12),
                        Text('Split Bill Calculator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).primaryColor)),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).primaryColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // AI Insights Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFF2A2A2A), shape: BoxShape.circle),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'You may exceed your dining budget by \$420 this month. Try cooking more at home.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Spending by Category
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Spending by Category', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(onPressed: () {}, child: const Text('See all')),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildCategoryCard(context, 'Food', '\$842', '🍲'),
                  const SizedBox(width: 12),
                  _buildCategoryCard(context, 'Rent', '\$1,200', '🏠'),
                  const SizedBox(width: 12),
                  _buildCategoryCard(context, 'Transport', '\$324', '🚕'),
                  const SizedBox(width: 12),
                  _buildCategoryCard(context, 'Shopping', '\$456', '🛒'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Grouped Recent Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Transactions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(onPressed: () {}, child: const Text('See all')),
              ],
            ),
            const SizedBox(height: 16),
            
            // "Today" Group
            const Text('Today', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 12),
            TransactionCard(transaction: transactions.isNotEmpty ? transactions[0] : DummyDataService.getDummyTransactions()[0]),
            if (transactions.length > 1) TransactionCard(transaction: transactions[1]),
            
            const SizedBox(height: 16),
            // "Yesterday" Group
            const Text('Yesterday', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 12),
            if (transactions.length > 2) TransactionCard(transaction: transactions[2]),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String amount, String emoji) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}


