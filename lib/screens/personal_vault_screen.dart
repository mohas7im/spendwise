import 'package:flutter/material.dart';
import 'document_vault_screen.dart';
import 'bank_card_manager_screen.dart';
import 'certificates_screen.dart';
import 'vault_modules/vault_notes_view.dart';
import 'vault_modules/vault_reminders_view.dart';

class PersonalVaultScreen extends StatelessWidget {
  const PersonalVaultScreen({super.key});

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
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Icon(icon, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Personal Vault',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,

      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildVaultTile(
            context: context,
            title: 'Documents',
            subtitle: 'Securely store IDs and files.',
            icon: Icons.folder_special,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentVaultScreen())),
          ),
          _buildVaultTile(
            context: context,
            title: 'Notes',
            subtitle: 'Write secure colored notes.',
            icon: Icons.notes,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VaultNotesView())),
          ),
          _buildVaultTile(
            context: context,
            title: 'Reminders',
            subtitle: 'Never miss bill payments.',
            icon: Icons.alarm,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VaultRemindersView())),
          ),
          _buildVaultTile(
            context: context,
            title: 'Banks & Cards',
            subtitle: 'Manage cards and bank accounts.',
            icon: Icons.account_balance,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BankCardManagerScreen())),
          ),
          _buildVaultTile(
            context: context,
            title: 'Certificates',
            subtitle: 'Educational and professional certs.',
            icon: Icons.workspace_premium,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CertificatesScreen())),
          ),
        ],
      ),
    );
  }
}
