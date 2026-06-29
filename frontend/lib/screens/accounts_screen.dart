import 'package:flutter/material.dart';
import '../widgets/common/premium_gradient_card.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy accounts data
    final List<Map<String, dynamic>> accounts = [];

    double totalBalance = accounts.fold(0, (sum, acc) => sum + acc['balance']);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Accounts & Wallets', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add Account coming soon!')));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: PremiumGradientCard(
                builder: (context, textColor, subTextColor) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Net Worth', style: TextStyle(color: subTextColor, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(
                      '₹${totalBalance.toStringAsFixed(0)}',
                      style: TextStyle(color: textColor, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bank Accounts', style: TextStyle(color: subTextColor, fontSize: 11)),
                            Text('2', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Credit Cards', style: TextStyle(color: subTextColor, fontSize: 11)),
                            Text('1', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Wallets', style: TextStyle(color: subTextColor, fontSize: 11)),
                            Text('1', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text('Your Accounts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final acc = accounts[index];
                final isNegative = acc['balance'] < 0;
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: (acc['color'] as Color).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(acc['icon'], color: acc['color'], size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(acc['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              if (acc['number'] != '')
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(acc['number'], style: const TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5)),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isNegative ? '-' : ''}₹${acc['balance'].abs().toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 16,
                                color: isNegative ? Colors.redAccent : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(acc['type'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
