import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import 'income_salary_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: NetworkImage('https://i.pravatar.cc/300?img=11'),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Theme.of(context).primaryColor, width: 3),
              ),
            ),
            const SizedBox(height: 16),
            Text('Alex Morgan', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Text('alex.morgan@example.com', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),

            // Settings Sections
            _buildSectionHeader('Preferences'),
            _buildSettingTile(
              context,
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              trailing: Switch(
                value: isDark,
                onChanged: (value) => themeProvider.toggleTheme(value),
                activeColor: Theme.of(context).primaryColor,
              ),
            ),
            _buildSettingTile(context, icon: Icons.notifications_outlined, title: 'Notifications', trailing: const Icon(Icons.chevron_right, color: Colors.grey)),

            const SizedBox(height: 24),
            _buildSectionHeader('Financial Setup'),
            _buildSettingTile(context, icon: Icons.account_balance_wallet_outlined, title: 'Income & Salary', subtitle: 'Manage company salary and freelance income', trailing: const Icon(Icons.chevron_right, color: Colors.grey), onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => const IncomeSalaryScreen()));
            }),
            _buildSettingTile(context, icon: Icons.pie_chart_outline, title: 'Budget Rules', subtitle: 'Configure 50/30/20 preferences', trailing: const Icon(Icons.chevron_right, color: Colors.grey)),
            _buildSettingTile(context, icon: Icons.category_outlined, title: 'Custom Categories', trailing: const Icon(Icons.chevron_right, color: Colors.grey)),

            const SizedBox(height: 24),
            _buildSectionHeader('Account'),
            _buildSettingTile(context, icon: Icons.security_outlined, title: 'Security', trailing: const Icon(Icons.chevron_right, color: Colors.grey)),
            _buildSettingTile(context, icon: Icons.help_outline, title: 'Help & Support', trailing: const Icon(Icons.chevron_right, color: Colors.grey)),
            const SizedBox(height: 16),
            
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, {required IconData icon, required String title, String? subtitle, required Widget trailing, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)) : null,
        trailing: trailing,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
