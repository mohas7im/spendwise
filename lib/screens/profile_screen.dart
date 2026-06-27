import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'income_salary_screen.dart';
import 'friends_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Alex Morgan';
  String _email = 'alex.morgan@example.com';
  String _avatarUrl = 'https://i.pravatar.cc/300?img=11';

  void _showEditProfileSheet() {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);
    final avatarController = TextEditingController(text: _avatarUrl);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Profile', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email Address', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: avatarController,
                decoration: InputDecoration(labelText: 'Avatar Image URL', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setState(() {
                      _name = nameController.text;
                      _email = emailController.text;
                      _avatarUrl = avatarController.text;
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            GestureDetector(
              onTap: _showEditProfileSheet,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(_avatarUrl),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: Theme.of(context).primaryColor, width: 3),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _showEditProfileSheet,
              child: Column(
                children: [
                  Text(_name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Text(_email, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
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
                activeThumbColor: Theme.of(context).primaryColor,
              ),
            ),
            _buildSettingTile(context, icon: Icons.notifications_outlined, title: 'Notifications', trailing: const Icon(Icons.chevron_right, color: Colors.grey)),

            const SizedBox(height: 24),
            _buildSectionHeader('Financial Setup'),
            _buildSettingTile(context, icon: Icons.account_balance_wallet_outlined, title: 'Income & Salary', subtitle: 'Manage company salary and freelance income', trailing: const Icon(Icons.chevron_right, color: Colors.grey), onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => const IncomeSalaryScreen()));
            }),
            _buildSettingTile(context, icon: Icons.group_outlined, title: 'Friends', subtitle: 'Manage your connected friends', trailing: const Icon(Icons.chevron_right, color: Colors.grey), onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => const FriendsScreen()));
            }),

            const SizedBox(height: 24),
            
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
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
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
