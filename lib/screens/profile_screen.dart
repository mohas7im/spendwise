import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'friends_screen.dart';
import 'categories_screen.dart';
import 'buy_coffee_screen.dart';
import 'contact_us_screen.dart';

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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
            const SizedBox(width: 10),
            const Text('About SpendWise', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SpendWise is a personal finance management app designed to help you track your income, expenses, and financial goals.',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text('⚠️ Disclaimer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 8),
              Text(
                'This app is a Beta version provided for personal finance tracking and informational purposes only. The developer (Hashim) is NOT responsible for any financial loss, income loss, or financial inaccuracies caused by the use of this application. Please verify all important financial information with your financial institution.',
                style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.6),
              ),
              SizedBox(height: 16),
              Text('Version: 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
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
      body: Column(
        children: [
          // ─── Scrollable Content ───────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
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
                          width: 90,
                          height: 90,
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
                          child: const Icon(Icons.edit, color: Colors.white, size: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _showEditProfileSheet,
                    child: Column(
                      children: [
                        Text(_name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text(_email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Preferences
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

                  const SizedBox(height: 20),

                  // Financial Setup
                  _buildSectionHeader('Financial Setup'),
                  _buildSettingTile(context, icon: Icons.group_outlined, title: 'Friends', subtitle: 'Manage your connected friends', trailing: const Icon(Icons.chevron_right, color: Colors.grey), onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) => const FriendsScreen()));
                  }),
                  _buildSettingTile(context, icon: Icons.category_outlined, title: 'Custom Categories', subtitle: 'Manage your expense categories', trailing: const Icon(Icons.chevron_right, color: Colors.grey), onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) => const CategoriesScreen()));
                  }),

                  const SizedBox(height: 20),

                  // About
                  _buildSectionHeader('About'),
                  _buildSettingTile(
                    context,
                    icon: Icons.support_agent,
                    title: 'Contact Us',
                    subtitle: 'Support, feedback, and emails',
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ContactUsScreen()));
                    },
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.info_outline,
                    title: 'About SpendWise',
                    subtitle: 'Disclaimer & app information',
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: _showAboutDialog,
                  ),

                  const SizedBox(height: 20),

                  // Logout
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),

          // ─── Pinned Footer (always visible) ──────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.12))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Developed by Hashim', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('v1.0.0 · github.com/mohas7im', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) => const BuyCoffeeScreen()));
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('☕', style: TextStyle(fontSize: 15)),
                      const SizedBox(width: 6),
                      Text('Buy me a coffee', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
      margin: const EdgeInsets.only(bottom: 10),
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
