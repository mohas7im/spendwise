import 'package:flutter/material.dart';
import 'document_vault_screen.dart';
import 'bank_card_manager_screen.dart';
import 'certificates_screen.dart';
import 'calculator_hub_screen.dart'; // We'll keep the list of calculators from here, or we can copy it. Wait, I should probably copy the calculator lists into this file or rename it.

// Let's implement FinanceHubScreen cleanly.
class FinanceHubScreen extends StatelessWidget {
  const FinanceHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Finance Hub', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const CircleAvatar(
                      backgroundColor: Colors.black12,
                      child: Icon(Icons.security, color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('Your central command for all financial tools, documents, and banking.', style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 16),
              
              _buildSectionTitle(context, 'Personal Vault'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildHubCard(
                      context: context,
                      title: 'Document Vault',
                      subtitle: 'Aadhaar, PAN, Passports',
                      icon: Icons.folder_special,
                      color: Colors.blue,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentVaultScreen())),
                    ),
                    _buildHubCard(
                      context: context,
                      title: 'Banks & Cards',
                      subtitle: 'Accounts, CC, Debit',
                      icon: Icons.credit_card,
                      color: Colors.purple,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BankCardManagerScreen())),
                    ),
                    _buildHubCard(
                      context: context,
                      title: 'Certificates',
                      subtitle: 'Education, Professional',
                      icon: Icons.workspace_premium,
                      color: Colors.orange,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CertificatesScreen())),
                    ),
                    _buildHubCard(
                      context: context,
                      title: 'Insurance',
                      subtitle: 'Health, Vehicle, Life',
                      icon: Icons.health_and_safety,
                      color: Colors.green,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentVaultScreen(initialCategory: 'Insurance'))),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Financial Tools'),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    _buildToolTile(context, 'Expense & Group', 'Split bills, Trips, Groups', Icons.group_work, Colors.teal, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculatorHubScreen())); // Fallback to old screen or refactor
                    }),
                    _buildToolTile(context, 'Loan & EMI', 'Home, Auto, Personal Loans', Icons.account_balance, Colors.indigo, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculatorHubScreen()));
                    }),
                    _buildToolTile(context, 'Vehicle & Fuel', 'Mileage, Trip costs', Icons.local_gas_station, Colors.deepOrange, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculatorHubScreen()));
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }

  Widget _buildHubCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildToolTile(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
