import 'package:flutter/material.dart';
import 'document_vault_screen.dart';
import 'bank_card_manager_screen.dart';
import 'certificates_screen.dart';

// Let's implement PersonalVaultScreen cleanly.
class PersonalVaultScreen extends StatelessWidget {
  const PersonalVaultScreen({super.key});

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
                    Text(
                      'Personal Vault',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const CircleAvatar(
                      backgroundColor: Colors.black12,
                      child: Icon(Icons.security, color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'Your secure vault for all documents, cards, and certificates.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    _buildVaultTile(
                      context: context,
                      title: 'Document Vault',
                      subtitle: 'Aadhaar, PAN, Passports',
                      icon: Icons.folder_special,
                      onTap: () =>
                          _openModal(context, const DocumentVaultScreen()),
                    ),
                    _buildVaultTile(
                      context: context,
                      title: 'Banks & Cards',
                      subtitle: 'Accounts, CC, Debit',
                      icon: Icons.credit_card,
                      onTap: () =>
                          _openModal(context, const BankCardManagerScreen()),
                    ),
                    _buildVaultTile(
                      context: context,
                      title: 'Certificates',
                      subtitle: 'Education, Professional',
                      icon: Icons.workspace_premium,
                      onTap: () =>
                          _openModal(context, const CertificatesScreen()),
                    ),
                    _buildVaultTile(
                      context: context,
                      title: 'Insurance',
                      subtitle: 'Health, Vehicle, Life',
                      icon: Icons.health_and_safety,
                      onTap: () => _openModal(
                        context,
                        const DocumentVaultScreen(initialCategory: 'Insurance'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openModal(BuildContext context, Widget screen) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: screen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVaultTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }
}
